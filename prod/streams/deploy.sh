#!/bin/bash

set -ex

STREAMS_REPLICATION=$1

if [ "$STREAMS_REPLICATION" == "false" ]
then
    docker stack deploy -c docker-compose.single.yml streams
    export NUM_BROKERS=1
else
    docker stack deploy -c docker-compose.replicated.yml streams
    export NUM_BROKERS=3
fi

#
# All Kafka brokers must be running before creation of streams.
#

WAIT_SEC=30
WAITFORIT_end_ts=$(($(date +%s) + $WAIT_SEC))
while :
do
    N_BRKS=$(docker run --rm --network nuvla-backend --entrypoint zookeeper-shell \
        confluentinc/cp-zookeeper:6.0.0 zookeeper1:2181 ls /brokers/ids | \
        awk -F, '/^\[.*\]/ {print NF}')
    if [[ $N_BRKS -ge $NUM_BROKERS ]]
    then
        break
    fi
    if [[ $(($WAITFORIT_end_ts - $(date +%s))) -le 0 ]]
    then
        echo "Not all brokers are running after $WAIT_SEC sec. Exit."
        exit 1
    fi
    echo "Waiting $WAIT_SEC for $NUM_BROKERS brokers to stand up. Current brokers: $N_BRKS"
    sleep 2
done

cd ksqldb
./deploy.sh $STREAMS_REPLICATION
cd -
