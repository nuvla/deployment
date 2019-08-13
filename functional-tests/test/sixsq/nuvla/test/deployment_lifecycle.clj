(ns sixsq.nuvla.test.deployment-lifecycle
  (:require
    [clojure.core.async :refer [<!!]]
    [clojure.test :refer [is]]
    [environ.core :refer [env]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]
    [sixsq.nuvla.test.deployment-example-centos :as centos]
    [sixsq.nuvla.test.deployment-example-jupyter :as jupyter]
    [sixsq.nuvla.test.deployment-example-rstudio :as rstudio]
    [sixsq.nuvla.test.deployment-example-ubuntu :as ubuntu]
    [sixsq.nuvla.test.deployment-manual-ubuntu :as manual]))


(def isg
  {:name        "test infrastructure service group"
   :description "infrastructure service group for deployment tests"})


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

              ;; sequentially execute all the example deployments
              (manual/tests cred-id)
              (ubuntu/tests cred-id)
              (centos/tests cred-id)
              (rstudio/tests cred-id)
              (jupyter/tests cred-id)

              )))))))
