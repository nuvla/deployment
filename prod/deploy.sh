#!/bin/bash

set -x
set -e

#
# Environment variables.
#

# Password for Prometheus.
# User by 'Deploy cluster and services monitoring.'.
# NB! Example. Set strong password.
# echo $(htpasswd -nb admin admin) | sed -e s/\\$/\\$\\$/g -e 's/^.*://'
export ADMIN_HASHED_PASSWORD='$apr1$CssftMAJ$ohKj9Jk5JV9iMK07BEedX/'

# SMTP configuration for user email notifications.
# Used by 'Deploy Nuvla core services.'.
# NB! Example. Set your SMTP configuration.
export SMTP_HOST=smtp.gmail.com
export SMTP_PORT=465
export SMTP_SSL=true
export SMTP_USER=mailer@example.com
export SMTP_PASSWORD=password

# Use replication for messages in the streaming platform. The replication
# requires multiple instances of the brokers, hence increases resource
# requirements.
export STREAMS_REPLICATION=false

#
# Deploy traefik.
#

docker network create --driver=overlay traefik-public

cd ../swarm/traefik
./generate-certificates.sh
docker stack deploy -c docker-compose.yml traefik
cd -

#
# Create 'nuvla-backend' attachable network.
#
docker network create --driver=overlay --attachable nuvla-backend

#
# Deploy cluster and services monitoring.
#

cd ../swarm/monitoring
docker stack deploy -c docker-compose.yml prometheus
cd -

#
# Deploy Nuvla's DB layer.
#

cd db
if [ ! -d ./secrets ]
then
  mkdir -p secrets
  echo S3 FAKE KEY > secrets/s3_access_key
  echo S3 FAKE SECRET > secrets/s3_secret_key
fi
docker stack deploy -c docker-compose.yml db
cd -

#
# Deploy event streaming platform and initialise ksqlDB with
# Nuvla related streams and tables.
#

cd streams
./deploy.sh $STREAMS_REPLICATION
cd -

#
# Deploy Nuvla core services.
#

cd core
./deploy.sh
cd -
