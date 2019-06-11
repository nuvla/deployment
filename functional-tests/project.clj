
(def +sixsq-nuvla-api-version+ "2.0.0")

(defproject sixsq.nuvla.deployment/functional-tests "0.0.1-SNAPSHOT"

  :description "test full deployment with clojure library"

  :url "https://github.com/nuvla/deployment"

  :license {:name         "Apache 2.0"
            :url          "http://www.apache.org/licenses/LICENSE-2.0.txt"
            :distribution :repo}

  :plugins [[lein-parent "0.3.5"]]

  :parent-project {:coords  [sixsq.nuvla/parent "6.5.0"]
                   :inherit [:plugins
                             :min-lein-version
                             :managed-dependencies
                             :repositories
                             :deploy-repositories]}

  :pom-location "target/"

  :clean-targets ^{:protect false} ["target" "out"]

  :dependencies
  [[sixsq.nuvla/api ~+sixsq-nuvla-api-version+]
   [environ]]

  :profiles {:provided {:dependencies [[org.clojure/clojure]
                                       [org.clojure/clojurescript]]}
             :test     {:source-paths   ["test"]
                        :resource-paths ["dev-resources"]}})
