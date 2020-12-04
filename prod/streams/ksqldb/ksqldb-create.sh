#!/bin/sh

set -ex

ksql_host=${1:-ksqldb-server:8088}
ksql_file=${2:-./statements.sql}

yum install -yq jq

./wait-for-it.sh -t 60 $ksql_host

while :
do
    res=$(curl -sS http://$ksql_host/healthcheck | jq .isHealthy)
    if [ "$res" == "true" ]
    then
        break
    else
        sleep 1
    fi
done

grep -v -- '^--' $ksql_file | \
    tr '\n' ' ' | sed 's/;/;\'$'\n''/g' | \
    while read stmt; do
    echo '{"ksql":"'"$stmt"'", "streamsProperties": {}}' | \
        curl -sS -X "POST" "http://${ksql_host}/ksql" \
             -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
             -d @- | \
        jq .
    echo "SLEEPING 1 sec ..."
    sleep 1
    done