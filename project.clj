(defproject onyx-redis "0.7.10"
  :description "Onyx plugin for redis"
  :url "FIX ME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.7.0"]
                 [org.onyxplatform/onyx "0.7.10"]
                 [com.taoensso/carmine "2.12.0" :exclusions [com.taoensso/timbre]]]
  :profiles {:dev {:dependencies []
                   :plugins []}})
