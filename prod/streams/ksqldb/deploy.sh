#!/bin/bash

set -e

STREAMS_REPLICATION=$1

STATEMENTS=./statements.sql

STATEMENTS_DIR=../../../streams/ksqldb

if [ "$STREAMS_REPLICATION" == "false" ]
then
  STATEMENTS_CHOICE=statements.replicas-1.sql
else
  STATEMENTS_CHOICE=statements.sql
fi

cp $STATEMENTS_DIR/$STATEMENTS_CHOICE $STATEMENTS
cp $STATEMENTS_DIR/statements_*.sql .

for sf in $STATEMENTS statements_*.sql; do
    docker run --network nuvla-backend -v $(pwd):/nuvla -w /nuvla --rm -u root \
            --entrypoint ./ksqldb-create.sh confluentinc/cp-ksqldb-cli:6.0.0 \
            ksqldb-server:8088 $STATEMENTS
done
