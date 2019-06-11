(ns sixsq.nuvla.test.features-test
  (:require
    [clojure.test :refer [deftest testing]]
    [sixsq.nuvla.test.cloud-entry-point :as cep]
    [sixsq.nuvla.test.context :as context]
    [sixsq.nuvla.test.deployment-lifecycle :as deployment-lifecycle]
    [sixsq.nuvla.test.event-lifecycle :as event-lifecycle]
    [sixsq.nuvla.test.login :as login]
    [sixsq.nuvla.test.logout :as logout]))


(defn do-tests
  []

  (testing "cloud-entry-point"
    (cep/tests))

  (testing "login"
    (login/tests))

  (testing "event lifecycle"
    (event-lifecycle/tests))

  (testing "deployment lifecycle"
    (deployment-lifecycle/tests))

  (testing "logout"
    (logout/tests)))


(deftest check-features
  (when context/client
    (do-tests)))

