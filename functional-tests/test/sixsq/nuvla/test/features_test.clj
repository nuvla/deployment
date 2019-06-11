(ns sixsq.nuvla.test.features-test
  (:require
    [clojure.test :refer [deftest]]
    [sixsq.nuvla.test.cloud-entry-point :as cep]
    [sixsq.nuvla.test.context :as context]
    [sixsq.nuvla.test.event-lifecycle :as event-lifecycle]
    [sixsq.nuvla.test.login :as login]
    [sixsq.nuvla.test.logout :as logout]))


(deftest check-features

  (when context/client

    (cep/tests)

    (login/tests)

    (event-lifecycle/tests)

    (logout/tests)

    ))

