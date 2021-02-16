#!/bin/bash -xe

docker stack rm nuvla
docker stack rm streams
docker stack rm db
docker stack rm prometheus
docker stack rm traefik
docker volume rm prometheus_grafana prometheus_prometheus
docker network rm nuvla-backend traefik-public
