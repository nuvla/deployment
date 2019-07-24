#!/usr/bin/env bash

set -ex

nuvla_endpoint="https://localhost"
nuvla_stack_name=${1:-demo}

# we have to login first
session_template='{
    "template": {
        "href": "session-template/password",
        "username": "super",
        "password": "supeR8-supeR8"
    }
}'

export COOKIES_FILE=$(pwd)/cookies

curl -XPOST --fail \
    ${nuvla_endpoint}/api/session \
    -H content-type:application/json \
    -H accept:application/json \
    -c ${COOKIES_FILE} -k \
    -d "${session_template}"

user=$(curl --fail -XGET \
        ${nuvla_endpoint}/api/user \
        -H accept:application/json \
        -b ${COOKIES_FILE} -k | jq -r .resources[].id)

nb_template='{
    "owner": "'${user}'"
}'

# Add nuvlabox
export NUVLABOX_UUID=$(curl -XPOST --fail \
                        ${nuvla_endpoint}/api/nuvlabox \
                        -H content-type:application/json \
                        -H accept:application/json \
                        -b ${COOKIES_FILE} -k \
                        -d "${nb_template}" | jq -r '."resource-id"')

docker network create localhost_nuvlabox --attachable

CONTAINER_ID=`docker inspect $(docker service ps ${nuvla_stack_name}_proxy --format '{{json .}}' | jq -r .ID) | jq -r .[].Status.ContainerStatus.ContainerID`

docker network connect --alias local-nuvla-endpoint localhost_nuvlabox $CONTAINER_ID

# Deploy NuvlaBox
docker-compose -f ${TRAVIS_BUILD_DIR}/docker-compose.localhost.yml up -d



