(ns sixsq.nuvla.test.features-test
    (:require
      [clojure.core.async :refer [chan <! >! go <!!]]
      [clojure.test :refer [are deftest is run-tests testing]]
      [environ.core :refer [env]]
      [kvlt.core :as kvlt]
      [sixsq.nuvla.client.authn :as authn]

      [sixsq.nuvla.client.api :as cimi]
      [sixsq.nuvla.client.async :as i]))


;; silence the request/response debugging
(kvlt/quiet!)


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


(def nuvla-username (env :nuvla-username "super"))


(def nuvla-password (env :nuvla-password "supeR8-supeR8"))


(def nuvla-host (env :nuvla-host "localhost"))


(def nuvla-insecure (env :nuvla-insecure "TRUE"))


(def server-endpoint (str "https://" nuvla-host "/api/cloud-entry-point"))


(def options (when (= "TRUE" nuvla-insecure) {:insecure? true}))


(defn strip-fields [m]
      (dissoc m :id :created :updated :acl :operations))


(deftest check-features

         ;; sanity checks for anonymous access
         (let [admin-client (i/instance server-endpoint options)
               cep (<! (cimi/cloud-entry-point admin-client))]

              (is (map? cep))
              (is (:base-uri cep))
              (is (:collections cep))
              (is (-> cep :collections :session-template))
              (is (-> cep :collections :session))
              (is (-> cep :collections :user-template))
              (is (-> cep :collections :user))

              ;; try logging in with incorrect credentials
              (let [response (<! (authn/login admin-client {:href     "session-template/password"
                                                            :username nuvla-username
                                                            :password (str nuvla-password "-incorrect")}))]
                   (is (instance? Exception response))
                   (is (= 403 (:status (ex-data response))))
                   (is (false? (<! (authn/authenticated? admin-client)))))

              ;; log into the server with correct credentials
              (let [response (<! (authn/login admin-client {:href     "session-template/password"
                                                            :username nuvla-username
                                                            :password nuvla-password}))]
                   (is (= 201 (:status response)))
                   (is (re-matches #"session/.+" (:resource-id response)))
                   (is (true? (<! (authn/authenticated? admin-client)))))

              ;; search for events (tests assume that real account with lots of events is used)
              #_(let [events (<! (cimi/search admin-client :event {:first 10 :last 20}))]
                     (is (= 11 (count (:events events))))
                     (is (pos? (:count events))))

              ;; add a new event resource
              (let [response (<! (cimi/add admin-client :event example-event))]
                   (is (= 201 (:status response)))
                   (is (re-matches #"event/.+" (:resource-id response)))

                   ;; read the event back
                   (let [event-id (:resource-id response)
                         read-event (<! (cimi/get admin-client event-id))]
                        (is (= (strip-fields example-event) (strip-fields read-event)))

                        ;; events cannot be edited
                        (let [edit-resp (<! (cimi/edit admin-client event-id read-event))]
                             (is (instance? Exception edit-resp)))

                        ;; delete the event and ensure that it is gone
                        (let [delete-resp (<! (cimi/delete admin-client event-id))]
                             (is (= 200 (:status delete-resp)))
                             (is (re-matches #"event/.+" (:resource-id delete-resp)))
                             (let [get-resp (<! (cimi/get admin-client event-id))]
                                  (is (instance? Exception get-resp))
                                  (is (= 404 (:status (ex-data get-resp))))))))

              ;; logout from the server
              (let [logout-response (<! (authn/logout admin-client))]
                   (is (= 200 (:status logout-response)))
                   (is (false? (<! (authn/authenticated? admin-client)))))

              ;; try logging out again
              (let [logout-response (<! (authn/logout admin-client))]
                   (is (nil? logout-response))
                   (is (false? (<! (authn/authenticated? admin-client)))))))

