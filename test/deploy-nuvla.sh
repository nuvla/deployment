#!/usr/bin/env bash

stack_name=${1:-demo}

git clone https://github.com/nuvla/deployment.git

cd deployment/demo

docker swarm init

docker stack deploy --compose-file docker-compose.yml ${stack_name}

