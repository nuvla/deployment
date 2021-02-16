#!/bin/sh

# Assumes four nodes docker swarm cluster.

LABELS=( "frontend" "worker-job" "worker-streams" "worker-db" )
NODES=$( docker node ls --format '{{ .Hostname }}' )

i=0
for N in ${NODES}
do
    set -x
    docker node update --label-add type=${LABELS[$i]} ${N}
    set +x
    i=$(($i + 1))
done
