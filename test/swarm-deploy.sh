#!/bin/bash
set -e

cleanup() {
    $DM_BIN rm -y "$($DM_BIN ls -q)"
}

trap cleanup ERR

action_err_msg="Action required: deploy|terminate"
ACTION=${1:?$action_err_msg}
SWSIZE=${2:-1}

DM_VER=v0.16.1
DM_BIN=$HOME/docker-machine

if [ ! -f "$DM_BIN" ]; then
    base=https://github.com/docker/machine/releases/download/$DM_VER
    curl -L $base/docker-machine-"$(uname -s)"-"$(uname -m)" >"$DM_BIN"
fi
chmod +x "$DM_BIN"

if [ ! -f "$HOME"/.ssh/id_rsa ]; then
    yes y | ssh-keygen -q -t rsa -N '' -f "$HOME"/.ssh/id_rsa &>/dev/null
fi

MNAME=dockermachine-$(date +%s)
CREATE_CMD="create --driver exoscale 
    --exoscale-ssh-user root 
    --exoscale-ssh-key $HOME/.ssh/id_rsa
    --exoscale-api-key ${EXOSCALE_API_KEY} 
    --exoscale-api-secret-key ${EXOSCALE_API_SECRET} 
    --exoscale-availability-zone CH-GVA-2 
    --exoscale-instance-profile Large 
    --exoscale-security-group slipstream_managed"

deploy() {
    swsize=${1:-1}
    echo "::: Provisioning master: $MNAME"
    $DM_BIN $CREATE_CMD --exoscale-image 'Linux Ubuntu 16.04 LTS 64-bit' "$MNAME"
    ip=$($DM_BIN ip "$MNAME")
    $DM_BIN ssh "$MNAME" "sudo docker swarm init --force-new-cluster --advertise-addr $ip"
    
    if [ "$swsize" -gt 1 ]; then
        joinToken=$($DM_BIN ssh "$MNAME" "sudo docker swarm join-token worker -q" | tr -d '\r')
        for i in $(seq 1 $((swsize - 1))); do
            WNAME=${MNAME}-worker${i}
            echo "::: Provisioning worker: $WNAME"
            $DM_BIN $CREATE_CMD --exoscale-image 'Linux Ubuntu 16.04 LTS 64-bit' "$WNAME"
            $DM_BIN ssh "$WNAME" "sudo docker swarm join --token ${joinToken} ${ip}:2377"
        done
    fi

    $DM_BIN ssh "$MNAME" "sudo docker node ls"

    DSTACK_CMD="docker -H $ip:2376 --tls 
        --tlscacert $HOME/.docker/machine/machines/$MNAME/ca.pem
        --tlskey $HOME/.docker/machine/machines/$MNAME/key.pem
        --tlscert $HOME/.docker/machine/machines/$MNAME/cert.pem
        stack"
    
    STACK_NAME=nuvla
    cd test
    $DSTACK_CMD deploy --compose-file docker-compose.yml $STACK_NAME
    cd -
    $DSTACK_CMD ls
    $DSTACK_CMD services $STACK_NAME
    echo "$ip" > "$HOME"/nuvla-test-host
    echo "$MNAME" > "$HOME"/docker-machine-master
}

terminate() {
    machines=()
    while read m;do machines+=( "$m" );done < <($DM_BIN ls -q)
    if [ "${#machines[@]}" -eq 0 ]; then
        echo "WARNING: no machines to terminate"
    else
        for m in ${machines[@]};do
            $DM_BIN rm -y "$m" &
        done
        wait
    fi
}

if [ "$ACTION" == "deploy" ]; then
    deploy "$SWSIZE"
elif [ "$ACTION" == "terminate" ]; then
    terminate
else
    echo "$action_err_msg"
    exit 1
fi
