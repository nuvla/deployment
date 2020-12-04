#!/bin/bash

set -ex

STREAMS_REPLICATION=$1

if [ "$STREAMS_REPLICATION" == "false" ]
then
    docker stack deploy -c docker-compose.single.yml streams
else
    docker stack deploy -c docker-compose.replicated.yml streams
fi
cd ksqldb
./deploy.sh $STREAMS_REPLICATION
cd -
