Demonstration Nuvla Deployment
==============================

This directory contains a Docker compose file that describes a
complete Nuvla deployment for demonstrations.  This deployment does
not provide any means for handling the long-term persistence of data
and consequently, should not be used for production.

Prerequisites
-------------

If running Docker locally, you'll need to initialize your deployment
to run in swarm mode. Just run the command:

```sh
docker swarm init
```

The `docker stack` commands below should then work.

If you are not running locally, make sure your Docker Swarm satisfies
the requirements for a **host** infrastructure.  See the instructions
in the `swarm` directory.

You will need to have a **target** Docker Swarm infrastructure
available when using Nuvla to deploy containers.  See the instructions
in the `swarm` directory.

Setup
-----

The deployment requires session and service certificates.  These must
be generated before you deploy Nuvla. They are made available to the
deployment via Docker "secrets".

To generate the certificates:

```
./generate-certificates.sh
```

This will generate the certificates in the `session` and `traefik`
subdirectories. The server certificate is valid for 14 days. 

Starting
--------

This can be started with the command:

```sh
docker stack deploy nuvla --compose-file docker-compose.yml
```

You can view the status of the deployment with:

```sh
docker stack services nuvla
```

With the service reference, you can view the logs of any service:

```sh
docker service logs -f nuvla_api
```

changing the name of the service as necessary.

The full Nuvla deployment can be accessed from `https://localhost/`,
assuming that your running everything locally.  Change "localhost" to
your host name when running remotely.

Bootstrapping
-------------

If NUVLA_SUPER_PASSWORD env variable is set and super user doesn't
already exist, the super user will be created at the server
startup. The default value is "supeR8-supeR8", but you can use a
different value if you wish.

Stopping
--------

To stop the server, simply do the following:

```sh
docker stack rm nuvla
```

This should stop the containers and remove the containers and any
volumes that were created.

**NOTE: Because of the problem described below, you may want to simply
redeploy the stack for updates rather than stopping and starting the
stack.**

Clean Up Problems
-----------------

When running the command to remove the stack, it should asynchonously
delete all the resources associated with the stack. Unfortunately,
there are race conditions in the clean up that often cause the
nuvla_api container to remain defined (but not running).  This in turn
causes the nuvla_frontend network deletion to fail. Worse, it ends in
a state where it can be listed but not deleted. Grrr...

The discussion around this issue can be found in a [GitHub
issue](https://github.com/moby/moby/issues/32620) and a related
[Gist](https://gist.github.com/dperny/86bb33f195e4a3c27bbc497372652994)
that describes the `network rm` problems.

The only workaround seems to be to restart the Docker daemon to return
to a clean state.

