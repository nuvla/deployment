(ns sixsq.nuvla.test.ssh-utils
  (:require
    [clojure.java.shell :refer [sh]]
    [clojure.pprint :refer [pprint]]
    [clojure.string :as str]
    [environ.core :refer [env]]))


(defn try-ssh
  [hostname port]
  "Returns exit code of the SSH command."
  (println (format "trying ssh with root@%s:%s" hostname port))
  (when (and hostname port)
    (let [result (sh "ssh" "-o" "StrictHostKeyChecking=no" "-p" port (format "root@%s" hostname) "ls")]
      (println "SSH RESULT")
      (pprint result)
      result)))


(defn get-ssh-public-key
  []
  (some-> (env :ssh-public-key)
          slurp
          str/trim-newline))


(defn add-ssh-public-key
  [deployment ssh-public-key]
  (let [path                 [:module :content :environmental-variables]
        vkey                 "AUTHORIZED_SSH_KEY"
        env-vars             (get-in deployment path)
        env-vars-map         (zipmap (map :name env-vars) env-vars)
        updated-var          (-> env-vars-map
                                 (get vkey)
                                 (assoc :value ssh-public-key))
        updated-env-vars-map (assoc env-vars-map vkey updated-var)]
    (assoc-in deployment path (vals updated-env-vars-map))))
