#!/bin/bash

# NB! The test fails with
#  >>>>> Test failed: unknown topic: SUBS_EVENT_NOTIF_STATE_T
# on the current 6.0.0 due to https://github.com/confluentinc/ksql/issues/5314
# Proposed workaround doesn't work either.

docker run -v $(pwd):/test/ --entrypoint ksql-test-runner confluentinc/cp-ksqldb-cli:6.0.0 \
     -i /test/test/input.json -s /test/statements.sql -o /test/test/output.json
