(ns sixsq.nuvla.test.module-utils
  (:require
    [clojure.core.async :refer [<!!]]
    [clojure.java.shell :refer [sh]]
    [clojure.pprint :refer [pprint]]
    [clojure.test :refer [is]]
    [sixsq.nuvla.client.api :as api]
    [sixsq.nuvla.test.context :as context]))


(defn get-module-by-path
  [path]
  (let [options {:first 0, :last 1, :filter (format "path='%s'" path)}
        {:keys [resources]} (<!! (api/search context/client :module options))]
    (-> resources first :id)))


(defn add-module
  [path]
  "Returns exit code, stdout, and stderr of the command `python
   ${path}/add-module.py`."
  (when path
    (let [script      (format "%s/add-module.py" path)
          current-env (into {} (System/getenv))
          env         (assoc current-env "NUVLA_ENDPOINT" context/python-api-endpoint
                                         "NUVLA_USERNAME" context/nuvla-username
                                         "NUVLA_PASSWORD" context/nuvla-password)
          result      (sh "python" script :env env)]
      (println "RESULT FOR " script)
      (pprint result)
      (is (zero? (:exit result)))
      result)))
