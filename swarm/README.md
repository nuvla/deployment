# Docker Swarm Infrastructures

This directory contains files that support the deployment of Docker
Swarm infrastructures for Nuvla.

There are two types of Docker Swarm infrastructures:

 - **target**: A Docker Swarm infrastructure on which Nuvla will
   **deploy** containers.  This is a basic deployment of Swarm with
   Minio/NFS for data access and Prometheus for monitoring. Persistent
   volumes are needed for data storage for production.

 - **host**: A Docker Swarm infrastructure that will **host** a Nuvla
   deployment. This is a basic deployment of Swarm with Prometheus for
   monitoring. Persistent volumes are needed to back the Elasticsearch
   database for production.

Before starting, review the entire deployment procedure. You may need
to make changes to the provided Docker Compose files, e.g. in the NFS
configuration.

The following sections describe each step of the deployment and
configuration of a target or host Docker Swarm infrastructure.

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
use a different cloud driver or other customization that you require.

If you want to use the `swarm-deploy-exoscale.sh` script (or a variant
of it) to deploy your Docker Swarm infrastructure, first clone this
repository to a convenient Linux/Unix machine.

Descend into the `swarm` subdirectory and copy `env-example.sh` to
`env.sh`. Edit this file, changing the values of the variables to
customize your installation. Afterwards, run:

    source env.sh

to set all of the environmental variables for the Swarm management
script. 

The command to use to create cluster is:

    ./swarm-deploy-exoscale.sh deploy 3

This creates a cluster with one master and two workers (three nodes in
total). If you do not provide the second argument, it defaults to one.

Note that `docker-machine` uses SSH to communicate with the virtual
machines of the cluster. By default the key `${HOME}/.ssh/id_rsa` will
be used (or created if it does not exist). If you want to use a
different key, then set the environmental variable `SSH_KEY`.

**WARNING**: Use an SSH key **WITHOUT** a password. If you use one
with a password, you will be prompted for the password, repeatedly. To
generate a new SSH key without a password just set SSH_KEY to a file
that does not exist.

You will want to note the IP addresses of the Docker Swarm master and
workers (if any). You can recover these IP addresses by running the
command `docker-machine ls` if necessary.

## NFS

If you are deploying a **target** infrastructure, then be sure that
**all** nodes have the NFS client software installed.

This can be done, for example on Ubuntu, by accessing the nodes as
`root` via SSH and running the command:

    apt-get update
    apt-get install nfs-kernel-server

(Note: this actually installs the server as well; easier than just
installing the client alone.)

If you use one of the Swarm nodes (e.g. the master) as the NFS server,
be sure that the NFS daemon is installed there.

On the NFS server, create the directory that will be shared with all
nodes of the Swarm cluster.  The commands to do this on Ubuntu are:

    NFS_SHARE='/nfs-root'
    mkdir ${NFS_SHARE}
    chown nobody:nogroup ${NFS_SHARE}
    chmod 777 ${NFS_SHARE}
    echo -e "${NFS_SHARE} *(ro,sync,no_subtree_check)" >> /etc/exports
    exportfs -a
    systemctl enable nfs-kernel-server
    systemctl restart nfs-kernel-server

Note that this configuration allows any node within the cluster to
mount the volumes.  If the network is open to nodes outside the
cluster, you may want to provide an explicit list of allowed hosts.

## Create Public Network

The various components (both Nuvla components and other required
components) will use an "external" network when making services
available outside of the Docker Swarm cluster. 

Create a public overlay network with the command:

    docker network create --driver=overlay traefik-public

The name "traefik-public" is hardcoded in many of the docker-compose
files. If you want to use a different name, you'll need to update
those files.

## Deploy Traefik

Traefik is a general router and load balancer. You can deploy it
(again for use by other components) with the command:

    cd traefik
    docker stack deploy -c traefik.yml traefik

If you want to change the name of the public network, the compose file
must be modified.

## Monitoring

Having an overview of the activity on the Docker Swarm cluster is
extremely helpful in understanding the overall load and for diagnosing
any problems that arise. We recommend using Prometheus to monitor the
cluster.

To deploy Prometheus with the standard configuration, run the command:

    cd monitoring
    docker stack deploy -c docker-compose.yml prometheus

The service will be available at the URL `http://master-ip:3000/`. 

## Minio (S3)

The data management services rely on the availability of an
S3-compatible service on the **target** Docker Swarm
infrastructures. Minio is a container-based implementation that can
expose NFS volumes via the S3 protocol.

For **target** infrastructures, you can deploy Minio with:

    cd minio
    docker stack deploy -c docker-compose.yml minio

The service will be available at the URL `http://master-ip:9000/`. The
default username/password will be admin/admin, if you've not changed
them in the configuration.
