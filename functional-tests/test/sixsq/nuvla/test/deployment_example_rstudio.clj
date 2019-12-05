(ns sixsq.nuvla.test.deployment-example-rstudio
  (:require
    [clojure.core.async :refer [<!!]]
    [clojure.string :as str]
    [clojure.test :refer [is]]
    [environ.core :refer [env]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]
    [sixsq.nuvla.test.deployment-utils :as depl]
    [sixsq.nuvla.test.module-utils :as module]))


(defn tests
  [cred-id]

  (let [examples-root (env :examples-root)]

    (module/add-module (str/join "/" [examples-root "example-rstudio"]))

    (when-let [module-id (module/get-module-by-path "examples/rstudio")]

      (let [depl          {:parent cred-id
                           :module {:href module-id}}
            {:keys [status resource-id]} (<!! (api/add context/client :deployment depl))
            deployment-id resource-id]

        (is (= 201 status))
        (is (re-matches #"deployment/.+" deployment-id))

        (depl/do-action deployment-id "start")

        (depl/wait-for-state deployment-id "STARTED")

        (depl/verify-state deployment-id "STARTED")

        ;; wait for deployment parameters to become available
        (when-let [dps (depl/wait-for-dps deployment-id ["hostname" "tcp.8787" "password"])]
          (let [hostname (get dps "hostname")
                port     (get dps "tcp.8787")
                password (get dps "password")]

            (println "rstudio password: " password)

            (depl/check-url "RSTUDIO" (format "http://%s:%s" hostname port))))

        (depl/do-action deployment-id "stop")

        (depl/wait-for-state deployment-id "STOPPED")

        (depl/verify-state deployment-id "STOPPED")

        ;; delete the deployment
        (let [{:keys [status]} (<!! (api/delete context/client deployment-id))]
          (is (= 200 status))))

      ;; delete the module
      (let [{:keys [status]} (<!! (api/delete context/client module-id))]
        (is (= 200 status))))))
