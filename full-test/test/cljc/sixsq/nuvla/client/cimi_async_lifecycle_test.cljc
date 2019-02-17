(ns sixsq.nuvla.client.cimi-async-lifecycle-test
  "Runs lifecycle tests for CIMI resources against a live server. If no user
   credentials are provided, the lifecycle tests are 'no-ops'. To run these
   tests (typically from the REPL), do the following:

   ```clojure
   (require '[sixsq.nuvla.client.cimi-async-lifecycle-test :as t] :reload)
   (in-ns 'sixsq.nuvla.client.cimi-async-lifecycle-test)
   (def ^:dynamic *server-info* (set-server-info \"username\" \"password\" \"https://nuv.la/\"))
   (run-tests)
   ```

   **NOTE**: The value for \"my-server-root\" must end with a slash!
   "
  #?(:cljs (:require-macros [cljs.core.async.macros :refer [go]]))
  (:require
    [clojure.core.async :refer #?(:clj  [chan <! >! go <!!]
                                  :cljs [chan <! >!])]
    [clojure.test :refer [#?(:cljs async) are deftest is run-tests testing]]
    [kvlt.core]
    [sixsq.nuvla.client.authn :as authn]

    [sixsq.nuvla.client.api :as cimi]
    [sixsq.nuvla.client.async :as i]
    [buddy.core.hash :as ha]
    [buddy.core.codecs :as co]
    [clojure.string :as str]
    [sixsq.nuvla.client.impl.utils.json :as json]
    [sixsq.nuvla.client.impl.utils.http-async :as http-async]))

;; silence the request/response debugging
(kvlt.core/quiet!)

(def example-event
  {:id            "123"
   :resource-type "event"
   :created       "2015-01-16T08:20:00.0Z"
   :updated       "2015-01-16T08:20:00.0Z"

   :timestamp     "2015-01-10T08:20:00.0Z"
   :content       {:resource {:href "Run/45614147-aed1-4a24-889d-6365b0b1f2cd"}
                   :state    "Started"}
   :type          "state"
   :severity      "medium"

   :acl           {:owner {:type      "USER"
                           :principal "loomis"}
                   :rules [{:right     "ALL"
                            :type      "USER"
                            :principal "loomis"}
                           {:right     "ALL"
                            :type      "ROLE"
                            :principal "ADMIN"}]}})


(defn random-string
  []
  (apply str (repeatedly 15 #(rand-nth (vec "abcdefghijklmnopqrstuvwxyz")))))


(def server-endpoint "http://localhost:80/api/cloud-entry-point")


(def admin-username (random-string))


(def admin-password (random-string))


(println (str "CREDENTIALS: '" admin-username "', '" admin-password "'"))


(defn strip-fields [m]
  (dissoc m :id :created :updated :acl :operations))


;; FIXME: Copied from internal authentication namespace of server.
(defn hash-password
  "Hash password exactly as done in SlipStream Java server."
  [password]
  (when password
    (-> (ha/sha512 password)
        co/bytes->hex
        str/upper-case)))


(defn create-admin-user
  [username password]
  (let [hashed-password (hash-password password)
        template (json/edn->json {:template {:href         "user-template/direct"
                                             :username     username
                                             :emailAddress "super@example.com"
                                             :password     hashed-password
                                             :state        "ACTIVE"
                                             :isSuperUser  true}})]
    (http-async/post "http://localhost:8200/api/user" {:body                    template
                                                       :kvlt.platform/insecure? true
                                                       :headers                 {:nuvla-authn-info "internal ADMIN"
                                                                                 :content-type     "application/json"}})))


;;
;; CAUTION: If too many 'is' tests are added, the clojurescript compiler
;; may cause the stack to overflow.  This is apparently related to the issue
;; http://dev.clojure.org/jira/browse/ASYNC-40
;; The immediate solution is to eliminate some of the less useful tests.
;;

(defn features
  ([]
   (features nil))
  ([done]
   (go

     ;; bootstrap the server by creating an admin user
     (let [bootstrap-response (<! (create-admin-user admin-username admin-password))]
       (is (= 201 (:status bootstrap-response)))
       (is (-> bootstrap-response :headers :location)))

     ;; sanity checks for anonymous access
     (let [admin-client (i/instance server-endpoint)
           cep (<! (cimi/cloud-entry-point admin-client))]

       (is (map? cep))
       (is (:base-uri cep))
       (is (:collections cep))
       (is (-> cep :collections :session-template))
       (is (-> cep :collections :session))
       (is (-> cep :collections :user-template))
       (is (-> cep :collections :user))

       ;; try logging in with incorrect credentials
       (let [response (<! (authn/login admin-client {:href     "session-template/internal"
                                                     :username admin-username
                                                     :password (str admin-password "-incorrect")}))]
         (is (instance? #?(:clj Exception :cljs js/Error) response))
         (is (= 403 (:status (ex-data response))))
         (is (false? (<! (authn/authenticated? admin-client)))))

       ;; log into the server with correct credentials
       (let [response (<! (authn/login admin-client {:href     "session-template/internal"
                                                     :username admin-username
                                                     :password admin-password}))]
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
             (is (instance? #?(:clj Exception :cljs js/Error) edit-resp)))

           ;; delete the event and ensure that it is gone
           (let [delete-resp (<! (cimi/delete admin-client event-id))]
             (is (= 200 (:status delete-resp)))
             (is (re-matches #"event/.+" (:resource-id delete-resp)))
             (let [get-resp (<! (cimi/get admin-client event-id))]
               (is (instance? #?(:clj Exception :cljs js/Error) get-resp))
               (is (= 404 (:status (ex-data get-resp))))))))

       ;; logout from the server
       (let [logout-response (<! (authn/logout admin-client))]
         (is (= 200 (:status logout-response)))
         (is (false? (<! (authn/authenticated? admin-client)))))

       ;; try logging out again
       (let [logout-response (<! (authn/logout admin-client))]
         (is (nil? logout-response))
         (is (false? (<! (authn/authenticated? admin-client)))))

       (if done (done))))))

(deftest check-features
  #?(:clj  (<!! (features))
     :cljs (async done (features done))))

