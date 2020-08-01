(ns sixsq.nuvla.test.deployment-utils
  (:require
    [clj-http.client :as http]
    [clojure.core.async :refer [<!!]]
    [clojure.test :refer [is]]
    [environ.core :refer [env]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]))


(defn verify-state
  [deployment-id desired-state]
  (let [{:keys [state] :as deployment} (<!! (api/get context/client deployment-id))]
    (println (format "current/desired state for %s: %s/%s" deployment-id state desired-state))
    (is (= desired-state state))))


(defn wait-for-state
  [deployment-id desired-state & [sleep-ms]]
  (loop [index 0]
    (let [{:keys [state] :as deployment} (<!! (api/get context/client deployment-id))]
      (if (or (> index 24) (#{desired-state "ERROR"} state))
        true
        (do
          (println (format "waiting for %s for deployment %s: %s" desired-state deployment-id state))
          (Thread/sleep (or sleep-ms 5000))
          (recur (inc index)))))))


(defn wait-for-dps
  [deployment-id dps & [sleep-ms]]
  (loop [index 0]
    (let [options {:first 0, :last 100, :filter (format "parent='%s'" deployment-id)}
          {:keys [resources]} (<!! (api/search context/client :deployment-parameter options))
          dps-map (select-keys (->> resources
                                    (map (juxt :name :value))
                                    (remove (fn [[_ v]] (nil? v)))
                                    (into {}))
                               dps)]
      (if (= (count dps) (count dps-map))
        dps-map
        (if (> index 24)
          (do
            (is false "timeout waiting for hostname and port")
            nil)
          (do
            (println "waiting... parameters currently available: " (keys dps-map))
            (Thread/sleep (or sleep-ms 5000))
            (recur (inc index))))))))


(defn check-url
  [tag url]
  (loop [index 0]
    (let [result (try
                   (http/get url {:throw-exceptions false, :insecure? true})
                   (catch Exception _
                     nil))]
      (println tag " HTTP RESULT: " url " " (:status result))
      (if (or (> index 50) (= 200 (:status result)))
        (do
          (is (= 200 (:status result)))
          (is (:body result)))
        (do
          (Thread/sleep 5000)
          (recur (inc index)))))))


(defn do-action
  [deployment-id action]
  (let [{:keys [status]} (<!! (api/operation context/client deployment-id action))]
    (is (= 202 status))))
