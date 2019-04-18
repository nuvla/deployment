# Docker Swarm Infrastructures

This directory contains files that support the deployment of Docker
Swarm infrastructures for Nuvla.

There are two types of Docker Swarm infrastructures:

 - **target**: A Docker Swarm infrastructure that will be **managed**
   by Nuvla.  This is a basic deployment of Swarm with Minio/NFS for
   data management and Prometheus for monitoring. Persistent volumes
   are needed for the data management.

 - **host**: A Docker Swarm infrastructure that will **host** a Nuvla
   deployment. This is a basic deployment of Swarm with Prometheus for
   monitoring. Persistent volumes are needed to back the Elasticsearch
   database.

Before starting, review the entire deployment procedure. You may need
to make changes to the provided Docker Compose files, e.g. in the NFS
configuration.

Follow these steps to deploy a compatible Docker Swarm infrastructure: 

 1. Deploy a vanilla Docker Swarm cluster using the installation
    method that you prefer.  See the Docker tutorial on [creating a
    swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)
    to understand how to do this.

 2. If you are deploying a **target** infrastructure, then be sure
    that all nodes have the NFS client software installed.  If you use
    one of the Swarm nodes (e.g. the master) as the NFS server, be
    sure that the NFS daemon is installed there.

 3. Create a public overlay network with the command `docker network
    create --driver=overlay traefik-public`. 

 4. Deploy the `traefik` compose file with `docker stack deploy -c
    traefik.yml traefik`.

 5. Deploy prometheus for monitoring with `docker stack deploy -c
    prometheus.yml prometheus`.

 6. If you are deploying a **target** infrastructure, then deploy
    minio with `docker stack deploy -c minio.yml minio`.

After this, you should be able to connect to port 3000 of the master
with a browser and see the prometheus monitoring page.  If you've not
changed the username/password, they are "admin", "admin".
