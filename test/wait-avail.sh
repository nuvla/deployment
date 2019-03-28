#!/bin/bash

set -ex

endpoint=${1:?"Endpoint required: http[s]://host[:port][/resource]"}
wait_min_max=${2:-2}
time_max=$(( $(date +%s) + $(($wait_min_max * 60)) ))
cmd="curl -k -L --connect-timeout 5 --max-time 10 -sfS $endpoint"
set +e
$cmd
rc=$?
set -e
while [ "$rc" -ne 0 -a "$(date +%s)" -lt "$time_max" ]; do
    sleep 5
    set +e
    $cmd
    rc=$?
    set -e
done
[ "$rc" -ne 0 ] && echo "ERROR: failed conecting to $endpoint"
exit $rc
