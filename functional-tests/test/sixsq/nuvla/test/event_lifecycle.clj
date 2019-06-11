(ns sixsq.nuvla.test.event-lifecycle
  (:require
    [clojure.test :refer [is]]
    [clojure.core.async :refer [<!!]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]))


(def example-event
  {:id            "123"
   :resource-type "event"
   :created       "2015-01-16T08:20:00.00Z"
   :updated       "2015-01-16T08:20:00.00Z"

   :timestamp     "2015-01-10T08:20:00.00Z"
   :content       {:resource {:href "Run/45614147-aed1-4a24-889d-6365b0b1f2cd"}
                   :state    "Started"}
   :category      "state"
   :severity      "medium"

   :acl           {:owners   ["user/my-user"]
                   :edit-acl ["group/nuvla-admin"]}})


(defn strip-fields [m]
  (dissoc m :id :created :updated :acl :operations))


(defn tests
  []

  ;; add a new event resource
  (let [response (<!! (api/add context/client :event example-event))]
    (is (= 201 (:status response)))
    (is (re-matches #"event/.+" (:resource-id response)))

    ;; read the event back
    (let [event-id   (:resource-id response)
          read-event (<!! (api/get context/client event-id))]
      (is (= (strip-fields example-event) (strip-fields read-event)))

      ;; events cannot be edited
      (let [edit-resp (<!! (api/edit context/client event-id read-event))]
        (is (instance? Exception edit-resp)))

      ;; delete the event and ensure that it is gone
      (let [delete-resp (<!! (api/delete context/client event-id))]
        (is (= 200 (:status delete-resp)))
        (is (re-matches #"event/.+" (:resource-id delete-resp)))
        (let [get-resp (<!! (api/get context/client event-id))]
          (is (instance? Exception get-resp))
          (is (= 404 (:status (ex-data get-resp)))))))))

