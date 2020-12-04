Production Nuvla Deployment
===========================

This directory contains a Docker compose and configuration files that
facilitate the deployment of a production Nuvla server. See the "Nuvla
Deployment" section of the [Nuvla
documentation](https://docs.nuvla.io/dave) for information on how
to use these.

See `deploy.sh` for an example of steps for deployment of fully  
functional Nuvla server.

Prerequisites:

* Docker Swarm cluster of 3 nodes.
    * Minimal settings: 4 CPU / 8 GB RAM / 50 GB Disk
* Labeled nodes
    * one node for running Nuvla front-end and back-end layers:
        * `docker node update --label-add type=frontend <node1>`
    * one node for running Nuvla async workers layer:
        * `docker node update --label-add type=worker-job <node2>`
    * one node for running Nuvla DB layer:
        * `docker node update --label-add type=worker-db <node3>`
