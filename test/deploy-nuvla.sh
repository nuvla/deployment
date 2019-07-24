#!/usr/bin/env bash

git clone https://github.com/nuvla/deployment.git

cd deployment/demo

docker swarm init

docker stack deploy --compose-file docker-compose.yml nuvla

