(ns sixsq.nuvla.test.cloud-entry-point
  (:require
    [clojure.core.async :refer [<!!]]
    [clojure.test :refer [is]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]))


(defn tests
  []
  (let [cep (<!! (api/cloud-entry-point context/client))]
    (is (map? cep))
    (is (:base-uri cep))
    (is (:collections cep))
    (when-let [collections (:collections cep)]
      (is (:session-template collections))
      (is (:session collections))
      (is (:user-template collections))
      (is (:user collections))
      (is (:module collections))
      (is (:deployment collections))
      (is (:deployment-parameter collections)))))
