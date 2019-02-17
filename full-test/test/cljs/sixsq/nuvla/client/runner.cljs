(ns sixsq.nuvla.client.runner
  (:require
    [doo.runner :refer-macros [doo-tests]]
    [sixsq.nuvla.client.cimi-async-lifecycle-test]))


(doo-tests
  'sixsq.nuvla.client.cimi-async-lifecycle-test)
