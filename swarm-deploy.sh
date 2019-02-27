#!/bin/bash
set -e

CSIZE=${1:-1}

yes y | ssh-keygen -q -t rsa -N ''  -f ~/.ssh/id_rsa 2>&1 > /dev/null

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

ls -alR $HOME/.docker/machine/machines/
sudo chown -R `id -u`: $HOME/.docker/machine/machines/

$DCMD ssh $MNAME "sudo docker node ls" 

DSTACK_CMD="docker -H $ip:2376 --tls 
    --tlscacert $HOME/.docker/machine/machines/$MNAME/ca.pem
    --tlskey $HOME/.docker/machine/machines/$MNAME/key.pem
    --tlscert $HOME/.docker/machine/machines/$MNAME/cert.pem
    stack"

STACK_NAME=full-test
$DSTACK_CMD deploy --compose-file $STACK_NAME/docker-compose.yml $STACK_NAME
$DSTACK_CMD ls
$DSTACK_CMD services $STACK_NAME
$DSTACK_CMD rm $STACK_NAME

$DCMD rm -y `$DCMD ls -q`
