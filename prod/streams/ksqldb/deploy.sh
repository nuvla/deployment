#!/bin/bash

set -e

docker run --network nuvla-backend -v $(pwd):/nuvla -w /nuvla --rm -u root \
        --entrypoint ./ksqldb-create.sh confluentinc/cp-ksqldb-cli:6.0.0
