#!/bin/bash

set -e

docker run --network nuvla-backend -v $(pwd):/nuvla -w /nuvla --rm \
   confluentinc/cp-ksqldb-cli:6.0.0 ksqldb-create.sh ./ksqldb-create.sh statements.sql
