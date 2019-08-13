(ns sixsq.nuvla.test.deployment-example-centos
  (:require
    [clojure.core.async :refer [<!!]]
    [clojure.string :as str]
    [clojure.test :refer [is]]
    [environ.core :refer [env]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]
    [sixsq.nuvla.test.deployment-utils :as depl]
    [sixsq.nuvla.test.module-utils :as module]
    [sixsq.nuvla.test.ssh-utils :as ssh]))


(defn tests
  [cred-id]

  (let [examples-root (env :examples-root)]

    (module/add-module (str/join "/" [examples-root "example-centos"]))

    (when-let [module-id (module/get-module-by-path "examples/centos")]

      (when-let [ssh-public-key (ssh/get-ssh-public-key)]

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
            (let [hostname (:value (get dps "hostname"))
                  port     (:value (get dps "tcp.22"))]

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
