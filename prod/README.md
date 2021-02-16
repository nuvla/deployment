Production Nuvla Deployment
===========================

This directory contains a Docker compose and configuration files that
facilitate the deployment of a production Nuvla server. See the "Nuvla
Deployment" section of the [Nuvla
documentation](https://docs.nuvla.io/dave) for information on how
to use these.

See [deploy.sh](deploy.sh) for an example of steps for deployment of a
fully functional Nuvla server.

## Prerequisites

* Docker Swarm cluster of 4 nodes.
    * Minimal settings per node: 4 CPU / 8 GB RAM / 50 GB Disk
* Labeled nodes
    * one node for running Nuvla front-end and back-end layers:
        * `docker node update --label-add type=frontend <node1>`
    * one node for running Nuvla async layer:
        * `docker node update --label-add type=worker-job <node2>`
    * one node for running Nuvla streaming layer:
        * `docker node update --label-add type=worker-streams <node3>`
    * one node for running Nuvla DB layer:
        * `docker node update --label-add type=worker-db <node4>`
* Run the following on the node(s) labeled `workers-db`

```
sysctl -w vm.max_map_count=262144
cat >> /etc/sysctl.conf<<EOF
vm.max_map_count=262144
EOF
```

*HINT:* Use the following environment variables when working on the
cluster remotely. Set _HOST_ and _TLS-CERTS_ accordingly. _TLS-CERTS_
directory must contain user certificates to access the docker swarm
endpoint: ca.pem, cert.pem, key.pem.

```
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=~/.docker/<TLS-CERTS>
export DOCKER_HOST=<HOST>:2376
```

## Elasticsearch backup to S3

If you want to backup Elasticsearch to S3, you can make S3 key and
secret available for the installation. For details see
[db/README.md](db/README.md).