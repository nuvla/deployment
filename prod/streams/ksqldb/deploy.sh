#!/bin/bash

set -e

STREAMS_REPLICATION=$1

STATEMENTS=./statements.sql

if [ "$STREAMS_REPLICATION" == "false" ]
then
  STATEMENTS_CHOICE=../../../streams/ksqldb/statements.replicas-1.sql
else
  STATEMENTS_CHOICE=../../../streams/ksqldb/statements.sql
fi

cp $STATEMENTS_CHOICE $STATEMENTS

docker run --network nuvla-backend -v $(pwd):/nuvla -w /nuvla --rm -u root \
        --entrypoint ./ksqldb-create.sh confluentinc/cp-ksqldb-cli:6.0.0 \
        ksqldb-server:8088 $STATEMENTS
