#!/bin/sh

set -ex

ksql_host=${1:-ksqldb-server:8088}
ksql_file=./statements.sql

grep -v -- '^--' $ksql_file | \
    tr '\n' ' ' | sed 's/;/;\'$'\n''/g' | \
    while read stmt; do
    echo '{"ksql":"'"$stmt"'", "streamsProperties": {}}' | \
        curl -sS -X "POST" "http://${ksql_host}/ksql" \
             -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
             -d @- | \
        jq
    echo "SLEEPING 1 sec ..."
    sleep 1
    done
