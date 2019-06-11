(ns sixsq.nuvla.test.context
  (:require
    [environ.core :refer [env]]
    [kvlt.core :as kvlt]
    [sixsq.nuvla.client.sync :as nuvla-client]))


;; silence the request/response debugging
(kvlt/quiet!)


(def nuvla-username (env :nuvla-username "super"))


(def nuvla-password (env :nuvla-password "supeR8-supeR8"))


(def nuvla-host (env :nuvla-host "localhost"))


(def nuvla-insecure (env :nuvla-insecure "TRUE"))


(def server-endpoint (str "https://" nuvla-host "/api/cloud-entry-point"))


(def options (when (= "TRUE" nuvla-insecure) {:insecure? true}))


(def client (nuvla-client/instance server-endpoint options))
