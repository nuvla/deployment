#!/bin/bash
set -e

env

CSIZE=${1:-1}

set -x
ls -al ~/.ssh
ssh-keygen -t rsa -N ''
ls -al ~/.ssh
set +x

MNAME=dockermachine-${TRAVIS_BUILD_ID}
DCMD="docker run --rm --name docker-machine 
    -v $HOME/.docker/machine:/root/.docker/machine 
    -v $HOME/.ssh:/root/.ssh/ 
    nuvla/job-docker-machine-client:test"
CREATE_CMD="create --driver exoscale 
    --exoscale-ssh-user root 
    --exoscale-ssh-key /root/.ssh/id_rsa 
    --exoscale-api-key ${EXOSCALE_API_KEY} 
    --exoscale-api-secret-key ${EXOSCALE_API_SECRET} 
    --exoscale-availability-zone CH-GVA-2 
    --exoscale-instance-profile Large 
    --exoscale-security-group slipstream_managed"
$DCMD $CREATE_CMD --exoscale-image 'Linux Ubuntu 16.04 LTS 64-bit' $MNAME 
ip=$($DCMD ip $MNAME)
$DCMD ssh $MNAME "sudo docker swarm init --force-new-cluster --advertise-addr $ip"

if [ $CSIZE -gt 1 ]; then
    joinToken=$($DCMD ssh $MNAME "sudo docker swarm join-token worker -q" | tr -d '\r')
    for i in `seq 1 $(($CSIZE - 1))`; do
        WNAME=${MNAME}-worker${i}
        echo "::: Provisioning worker: $WNAME"
        $DCMD $CREATE_CMD --exoscale-image 'Linux Ubuntu 16.04 LTS 64-bit' $WNAME
        $DCMD ssh $WNAME "sudo docker swarm join --token ${joinToken} ${ip}:2377"
    done
fi

$DCMD ssh $MNAME "sudo docker node ls" 
