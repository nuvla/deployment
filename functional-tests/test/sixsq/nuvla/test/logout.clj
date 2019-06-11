(ns sixsq.nuvla.test.logout
  (:require
    [clojure.test :refer [is]]
    [clojure.core.async :refer [<!!]]
    [sixsq.nuvla.client.authn :as authn]
    [sixsq.nuvla.test.context :as context]
    [clojure.tools.logging :as log]))


(defn tests
  []

  ;; expect that the user is authenticated already
  (is (true? (<!! (authn/authenticated? context/client))))

  ;; logout from the server
  (let [logout-response (<!! (authn/logout context/client))]
    (log/error logout-response)
    (is (= 200 (:status logout-response)))
    (is (false? (<!! (authn/authenticated? context/client)))))

  ;; try logging out again
  (let [logout-response (<!! (authn/logout context/client))]
    (is (nil? logout-response))
    (is (false? (<!! (authn/authenticated? context/client))))))

