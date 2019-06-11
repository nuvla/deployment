(ns sixsq.nuvla.test.logout
  (:require
    [clojure.test :refer [is]]
    [sixsq.nuvla.client.authn :as authn]
    [sixsq.nuvla.test.context :as context]))


(defn tests
  []

  ;; logout from the server
  (let [logout-response (authn/logout context/client)]
    (is (= 200 (:status logout-response)))
    (is (false? (authn/authenticated? context/client))))

  ;; try logging out again
  (let [logout-response (authn/logout context/client)]
    (is (nil? logout-response))
    (is (false? (authn/authenticated? context/client)))))

