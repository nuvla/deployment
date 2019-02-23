(def +version+ "0.0.1-SNAPSHOT")

(defproject sixsq.nuvla.deployment/full-test "0.0.1-SNAPSHOT"

  :description "test full deployment with clojure library"

  :url "https://github.com/nuvla/clojure-library"

  :license {:name         "Apache 2.0"
            :url          "http://www.apache.org/licenses/LICENSE-2.0.txt"
            :distribution :repo}

  :plugins [[lein-parent "0.3.2"]
            [lein-doo "0.1.8"]]

  :parent-project {:coords  [sixsq.nuvla/parent "6.1.5"]
                   :inherit [:plugins
                             :min-lein-version
                             :managed-dependencies
                             :repositories
                             :deploy-repositories]}

  :pom-location "target/"

  :clean-targets ^{:protect false} ["target" "out"]

  :doo {:verbose true
        :debug   true}

  :dependencies
  [[buddy/buddy-core]
   [buddy/buddy-hashers]
   [org.clojure/data.json]
   [sixsq.nuvla/clojure-library "0.0.1-SNAPSHOT"]]

  :cljsbuild {:builds [{:id           "test"
                        :source-paths ["test/cljc" "test/cljs"]
                        :compiler     {:main          'sixsq.nuvla.client.runner
                                       :output-to     "target/clienttest.js"
                                       :output-dir    "target"
                                       :optimizations :whitespace}}]}

  :profiles {:provided {:dependencies [[org.clojure/clojure]
                                       [org.clojure/clojurescript]]}
             :test     {:aot            :all
                        :source-paths   ["test/cljc"]
                        :resource-paths ["dev-resources"]}}

  :aliases {"test" ["do"
                    ["test"]
                    #_["with-profiles" "test" ["doo" "nashorn" "test" "once"]]]})
