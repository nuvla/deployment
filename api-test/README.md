Service Deployment for API Tests
================================

This directory contains a Docker compose file that describes starts
Elasticsearch and Zookeeper servers for running the full set of API
unit tests.


Starting
--------

This can be started with the command:

```sh
docker-compose up -d
```

Both services run on their standard ports: 9200, 9300 for
Elasticsearch and 2181 for Zookeeper.

Stopping
--------

To stop the servers, simply do the following:

```sh
docker-compose down -v
```

This should stop the containers and remove the containers and any
volumes that were created.
