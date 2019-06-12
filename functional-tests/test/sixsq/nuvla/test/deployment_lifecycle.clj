(ns sixsq.nuvla.test.deployment-lifecycle
  (:require
    [clojure.test :refer [is]]
    [clojure.core.async :refer [<!!]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]
    [environ.core :refer [env]]
    [clj-ssh.ssh :as ssh]))


(def isg
  {:name        "test infrastructure service group"
   :description "infrastructure service group for deployment tests"})


(def component
  {:author                  "sixsq"
   :commit                  "initial commit"
   :architecture            "arm64"
   :image                   {:repository "nuvla"
                             :image-name "example-ubuntu"
                             :tag        "latest"}
   :cpus                    0.75
   :memory                  1024
   :environmental-variables [{:name        "AUTHORIZED_SSH_KEY"
                              :description "public SSH key for accessing root account"
                              :required    true}]
   :ports                   [{:protocol    "tcp"
                              :target-port 22}]
   :urls                    [["ssh" "ssh://root@${hostname}:${tcp.22}"]]
   :restart-policy          {:condition "any"}})


(def module
  {:name                      "Ubuntu SSHD"
   :description               "example Ubuntu 18.04 image allowing access via SSH public/private key pair"
   :logo-url                  "https://nuv.la/images/modules-logos/ubuntu.svg"
   :subtype                   "component"
   :path                      "examples/ubuntu"
   :parent-path               "examples"
   :data-accept-content-types ["application/octet-stream"]
   :content                   component})


(defn dp-value
  [dp-name dp-list]
  (->> dp-list
       (filter (fn [m] (= dp-name (:name m))))
       first
       :value))


(defn tests
  []

  ;; check that the correct variables are in the environment
  (let [docker-cert-path (env :docker-cert-path)
        docker-host      (env :nuvla-host)]

    (is docker-cert-path)
    (is docker-host)

    (when (and docker-cert-path docker-host)

      (let [swarm-ca   (slurp (str docker-cert-path "/ca.pem"))
            swarm-cert (slurp (str docker-cert-path "/cert.pem"))
            swarm-key  (slurp (str docker-cert-path "/key.pem"))]

        ;; start by adding an infrastructure service group
        (let [{:keys [status resource-id] :as response} (<!! (api/add context/client :infrastructure-service-group isg))
              isg-id resource-id]
          (is (= 201 status))
          (is (re-matches #"infrastructure-service-group/.+" isg-id))

          ;; ensure that the group exists
          (let [{:keys [id]} (<!! (api/get context/client isg-id))]
            (is (= isg-id id)))

          ;; create the swarm service resource
          (let [docker-url (format "https://%s:2376" docker-host)
                tpl        {:name        "test swarm cluster"
                            :description "swarm cluster for deployment tests"
                            :acl         {:owners ["group/nuvla-admin"]}
                            :template    (merge {:href "infrastructure-service-template/generic"}
                                                {:parent   isg-id
                                                 :subtype  "docker"
                                                 :endpoint docker-url
                                                 :state    "STARTED"})}

                {:keys [status resource-id]} (<!! (api/add context/client :infrastructure-service tpl))
                swarm-id   resource-id]

            (is (= 201 status))
            (is (re-matches #"infrastructure-service/.+" swarm-id))

            ;; create the credential for the swarm cluster
            (let [tpl     {:name        "swarm credential"
                           :description "swarm credential for tests"
                           :template    {:href   "credential-template/infrastructure-service-swarm"
                                         :parent swarm-id
                                         :ca     swarm-ca
                                         :cert   swarm-cert
                                         :key    swarm-key}}

                  {:keys [status resource-id] :as response} (<!! (api/add context/client :credential tpl))
                  cred-id resource-id]

              (is (= 201 status))
              (is (re-matches #"credential/.+" cred-id))

              ;; create a module to deploy
              (let [{:keys [status resource-id]} (<!! (api/add context/client :module module))
                    module-id resource-id]

                (is (= 201 status))
                (is (re-matches #"module/.+" resource-id))

                (let [{:keys [id]} (<!! (api/get context/client module-id))]
                  (is (= module-id id)))

                ;; create a deployment
                (let [depl          {:credential-id cred-id
                                     :module        {:href module-id}}
                      {:keys [status resource-id]} (<!! (api/add context/client :deployment depl))
                      deployment-id resource-id]

                  (is (= 201 status))
                  (is (re-matches #"deployment/.+" deployment-id))

                  ;; update the environmental variables to set the public SSH key
                  (let [{:keys [id] :as deployment} (<!! (api/get context/client deployment-id))]
                    (is (= deployment-id id)))

                  ;; start the deployment
                  (let [{:keys [status]} (<!! (api/operation context/client deployment-id "start"))]
                    (is (= 202 status)))

                  ;; wait for deployment to enter the "STARTED" state
                  (loop [index 0]
                    (let [{:keys [state] :as deployment} (<!! (api/get context/client deployment-id))]
                      (if (or (> index 24) (#{"STARTED" "ERROR"} state))
                        true
                        (do
                          (println "waiting for STARTED: " deployment-id " " state)
                          (Thread/sleep 5000)
                          (recur (inc index))))))

                  (let [{:keys [state] :as deployment} (<!! (api/get context/client deployment-id))]
                    (println "current state: " deployment-id " " state)
                    (is (= "STARTED" state)))

                  ;; wait for deployment parameters to become available
                  (loop [index 0]
                    (let [f        "deployment/href='%s' and (name='hostname' or name='tcp.22')"
                          options  {:first 0, :last 10, :filter (format f deployment-id)}
                          {:keys [resources]} (<!! (api/search context/client :deployment-parameter options))
                          _        (println resources)
                          hostname (dp-value "hostname" resources)
                          port     (dp-value "tcp.22" resources)]
                      (if (or (> index 24) (and hostname port))
                        (do
                          (let [agent (ssh/ssh-agent {})]
                            (let [session (ssh/session agent hostname {:strict-host-key-checking :no
                                                                       :port                     port
                                                                       :username                 "root"})]
                              (ssh/with-connection session
                                                   (let [result (ssh/ssh session {:cmd "ls"})]
                                                     (println "SSH response: " result)
                                                     (is (zero? (:exit result))))))))
                        true)
                      (do
                        (println "waiting for hostname and port: " hostname " " port)
                        (Thread/sleep 5000)
                        (recur (inc index)))))

                  ;; stop the deployment
                  (let [{:keys [status]} (<!! (api/operation context/client deployment-id "stop"))]
                    (is (= 202 status)))

                  ;; wait for deployment to enter the "STOPPED" state
                  (loop [index 0]
                    (let [{:keys [state] :as deployment} (<!! (api/get context/client deployment-id))]
                      (if (or (> index 24) (#{"STOPPED" "ERROR"} state))
                        true
                        (do
                          (println "waiting for STOPPED: " deployment-id " " state)
                          (Thread/sleep 5000)
                          (recur (inc index))))))

                  (let [{:keys [state] :as deployment} (<!! (api/get context/client deployment-id))]
                    (println "current state: " deployment-id " " state)
                    (is (= "STOPPED" state)))

                  ;; delete the deployment
                  (let [{:keys [status]} (<!! (api/delete context/client deployment-id))]
                    (is (= 200 status)))))))))))) )
