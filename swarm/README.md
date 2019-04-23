# Docker Swarm Infrastructures

This directory contains files that support the deployment of Docker
Swarm infrastructures for Nuvla.

There are two types of Docker Swarm infrastructures:

 - **target**: A Docker Swarm infrastructure on which Nuvla will
   **deploy** containers.  This is a basic deployment of Swarm with
   Minio/NFS for data management and Prometheus for
   monitoring. Persistent volumes are needed for the data management.

 - **host**: A Docker Swarm infrastructure that will **host** a Nuvla
   deployment. This is a basic deployment of Swarm with Prometheus for
   monitoring. Persistent volumes are needed to back the Elasticsearch
   database.

Before starting, review the entire deployment procedure. You may need
to make changes to the provided Docker Compose files, e.g. in the NFS
configuration.

The following sections describe each step of the deployment procedure.

## Docker Swarm Cluster

Deploy a vanilla Docker Swarm cluster using the installation method
that you prefer.

See the Docker tutorial on [creating a
swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)
to understand how to do this.

You may also want to look at using `docker-machine`, which automates
the deployment of a Docker Swarm cluster on a cloud
infrastructure. The script `deploy-swarm-exoscale.sh` will use
`docker-machine` to deploy a Swarm cluster on the
[Exoscale](https://exoscale.ch) cloud. This script can be modified to
suit your needs. 

If you want to use the `swarm-deploy-exoscale.sh` script (or a variant
of it) to deploy your Docker Swarm infrastructure, the command to use
is:

    ./swarm-deploy-exoscale.sh deploy 3

This creates a cluster with one master and two workers. If you do not
provide the second argument, it defaults to one.

Note that `docker-machine` uses SSH to communicate with the virtual
machines of the cluster. By default the key `${HOME}/.ssh/id_rsa` will
be used (or created if it does not exist). If you want to use a
different key, then set the environmental variable `SSH_KEY`.

**WARNING**: Use an SSH key **WITHOUT** a password. If you use one
with a password, you will be prompted for the password, repeatedly. To
generate a password just set SSH_KEY to a file that does not exist.

You will want to note the IP addresses of the Docker Swarm master and
workers (if any). You can recover these IP addresses by running the
command `docker-machine ls`. 

## NFS

If you are deploying a **target** infrastructure, then be sure that
**all** nodes have the NFS client software installed. This can be
done, for example on Ubuntu, with the command:

    apt-get update
    apt-get install nfs-kernel-server

(Note: this actually installs the server as well; easier than just
installing the client alone.)

If you use one of the Swarm nodes (e.g. the master) as the NFS server,
be sure that the NFS daemon is installed there.

## Create Public Network

The various components (both Nuvla components and other required
components) will use an "external" network when making services
available outside of the Docker Swarm cluster. 

Create a public overlay network with the command:

    docker network create --driver=overlay traefik-public

The namee "traefik-public" is hardcoded in many of the docker-compose
files. If you want to use a different name, you'll need to updates
those files.

## Deploy Traefik

Traefik is a general router and load balancer. You can deploy it
(again for use by other components) with the command:

    docker stack deploy -c traefik.yml traefik

The compose file must be modified, if you want to change the name of
the public network.

## Monitor

Having an overview of the activity on the Docker Swarm cluster is
extremely helpful in understanding the overall load and for diagnosing
any problems that arise. We recommend using Prometheus to monitor the
cluster.

To deploy Prometheus with the standard configuration, run the command:

    cd monitor
    docker stack deploy -c docker-compose.yml prometheus

The service will be available at the URL `http://master-ip:3000/`. 

## Minio (S3)

The data management services rely on the availability of an
S3-compatible service on the **target** infrastructures. Minio is a
container-based implementation that can expose NFS volumes via the S3
protocol.

For **target** infrastructures, you can deploy Minio with:

    docker stack deploy -c docker-compose.yml minio

The service will be available at the URL `http://master-ip:9000/`. The
default username/password will be admin/admin, if you've not changed
them in the configuration.
