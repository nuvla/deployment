#!/bin/bash

set -e

docker run --network nuvla-backend -v $(pwd):/nuvla -w /nuvla --rm -u root \
        --entrypoint ./ksqldb-cleanup.sh confluentinc/cp-ksqldb-cli:6.1.0 \
        ksqldb-server:8088
