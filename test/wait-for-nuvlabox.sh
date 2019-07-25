#!/usr/bin/env bash

set -ex

export compose_file=${TRAVIS_BUILD_DIR}/docker-compose.localhost.yml
export system_manager=$(docker-compose -f ${compose_file} ps -q system-manager)

timeout 180 bash -c -- "while true
do
    status=$(docker inspect ${system_manager} | jq -r .[].State.Health.Status)
    if [[ \"${status}\" == \"healthy\" ]]
    then
        break
    fi
    echo 'INFO: waiting for NuvlaBox System Manager to become healthy. Current status is '${status}
    docker-compose -f ${compose_file} logs --tail=20
    sleep 3
done"

cookies_file=${COOKIES_FILE:-cookies}
nb_uuid=${NUVLABOX_UUID:?"Can not run this without the NB ID"}
nuvla_endpoint=${nuvla_endpoint:-"https://localhost"}

nb=$(curl --fail -XGET \
        ${nuvla_endpoint}/api/${nb_uuid} \
        -H accept:application/json \
        -b ${COOKIES_FILE} -k)

if [[ "$(echo $nb | jq -r .state)" != "COMMISSIONED" ]]
then
    echo "ERROR: NB is not commissioned in Nuvla"
    exit 1
fi

nb_status_id=$(echo $nb | jq -r '."nuvlabox-status"')

nb_status=$(curl --fail -XGET \
        ${nuvla_endpoint}/api/${nb_status_id} \
        -H accept:application/json \
        -b ${COOKIES_FILE} -k)

if [[ "$(echo $nb_status | jq -r .status)" != "OPERATIONAL" ]]
then
    echo "ERROR: NB status is not OPERATIONAL in Nuvla"
    exit 1
fi
