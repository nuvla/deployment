#!/bin/sh

set -ex

ksql_host=${1:-localhost:8088}
sql=${2}

if [ ! -z "$sql" ]; then
    ./run-ksql-script.sh $ksql_host $sql
else
  # Terminate all queries before dropping tables and streams.
  curl -X POST http://$ksql_host/ksql \
            -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
            -d '{"ksql": "SHOW QUERIES;"}' | \
     jq '.[].queries[].id' | sed -e 's/"//g' | \
     while read s; do \
       echo == terminating query: $s ==; \
       curl -X POST http://$ksql_host/ksql \
               -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
               -d '{"ksql": "TERMINATE '$s';"}'; done

  # Drop all streams.
  curl -X POST http://$ksql_host/ksql \
             -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
             -d '{"ksql": "SHOW STREAMS;"}' | \
     jq '.[].streams[].name' | grep -v KSQL_PROCESSING_LOG | sed -e 's/"//g' | \
     while read s; do \
       echo == dropping stream: $s ==; \
       curl -X POST http://$ksql_host/ksql \
               -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
               -d '{"ksql": "DROP STREAM '$s';"}'; done

  # Drop all tables.
  curl -X POST http://$ksql_host/ksql \
               -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
               -d '{"ksql": "SHOW TABLES;"}' | \
     jq '.[].tables[].name' | sed -e 's/"//g' | \
     while read s; do \
       echo == dropping table: $s ==; \
       curl -X POST http://$ksql_host/ksql \
                 -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
                 -d '{"ksql": "DROP TABLE '$s';"}'; done
fi