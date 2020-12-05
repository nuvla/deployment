#!/bin/bash

set -ex

./generate-certificates.sh

if [ "$STREAMS_REPLICATION" == "true" ]
then
  export KAFKA_BOOTSTRAP_SERVERS=kafka1:9092,kafka2:9093,kafka3:9094
fi
docker stack deploy -c docker-compose.yml nuvla
