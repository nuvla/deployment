(ns sixsq.nuvla.test.deployment-manual-ubuntu
  (:require
    [clojure.core.async :refer [<!!]]
    [clojure.test :refer [is]]
    [environ.core :refer [env]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]
    [sixsq.nuvla.test.deployment-utils :as depl]
    [sixsq.nuvla.test.ssh-utils :as ssh]))


(def component
  {:author                  "sixsq"
   :commit                  "initial commit"
   :architectures           ["arm64"]
   :image                   {:repository "nuvla"
                             :image-name "example-ubuntu"
                             :tag        "latest"}
   :cpus                    0.25
   :memory                  512
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
   :path                      "examples/ubuntu-new-module"
   :parent-path               "examples"
   :data-accept-content-types ["application/octet-stream"]
   :content                   component})


(defn tests
  [cred-id]

  (when-let [ssh-public-key (ssh/get-ssh-public-key)]

    (let [{:keys [status resource-id]} (<!! (api/add context/client :module module))
          module-id resource-id]

      (is (= 201 status))
      (is (re-matches #"module/.+" resource-id))

      (when (and (= 201 status) module-id)

        (let [depl          {:parent cred-id
                             :module {:href module-id}}
              {:keys [status resource-id]} (<!! (api/add context/client :deployment depl))
              deployment-id resource-id]

          (is (= 201 status))
          (is (re-matches #"deployment/.+" deployment-id))

          ;; update the environmental variables to set the public SSH key
          (let [{:keys [id] :as deployment} (<!! (api/get context/client deployment-id))]

            (is (= deployment-id id))

            (let [updated-deployment (ssh/add-ssh-public-key deployment ssh-public-key)]
              (let [result (<!! (api/edit context/client deployment-id updated-deployment))]
                (is (map? result)))))

          (depl/do-action deployment-id "start")

          (depl/wait-for-state deployment-id "STARTED")

          (depl/verify-state deployment-id "STARTED")

          ;; wait for deployment parameters to become available
          (when-let [dps (depl/wait-for-dps deployment-id ["hostname" "tcp.22"])]
            (let [hostname (get dps "hostname")
                  port     (get dps "tcp.22")]

              (loop [index 0]
                (let [result (ssh/try-ssh hostname port)]
                  (if (or (> index 5) (= 0 (:exit result)))
                    (is (= 0 (:exit result)))
                    (do
                      (Thread/sleep 5000)
                      (recur (inc index))))))))

          (depl/do-action deployment-id "stop")

          (depl/wait-for-state deployment-id "STOPPED")

          (depl/verify-state deployment-id "STOPPED")

          ;; delete the deployment
          (let [{:keys [status]} (<!! (api/delete context/client deployment-id))]
            (is (= 200 status))))

        ;; delete the module
        (let [{:keys [status]} (<!! (api/delete context/client module-id))]
          (is (= 200 status)))))))
