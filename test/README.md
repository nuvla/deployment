Complete TEST Nuvla Deployment
==============================

This directory contains a Docker compose file that describes a complete
Nuvla deployment for TEST purposes.

It configures traefik as a load balancer and router between the
backend services.  The deployment includes:

 - **es**: Elasticsearch database.
 
 - **zk**: Zookeeper for job processing.
 
 - **api**: Nuvla API server. It is accessible through the HTTPS
   traefik endpoint on the `/api*` paths. Paths not starting with
   `/api/` will be redirected to `/api/cloud-entry-point`.
   
 - **ui**: Nuvla browser user interface. Serves the static content of
   the user interface. Accessible through the HTTPS traefik on the `/`
   and `/ui*` paths. Unknown '/ui*' paths will be redirected to the
   `index.html` file.
   
 - **job-\***: Engine for asynchronous processing of jobs. Job
   executor, distributor, and cleanup containers are started as part
   of the deployment.
   
 - **proxy**: Traefik load balancer and router. Deployed Nuvla service
   accessible on port 443 with a self-signed certificate. The web
   interface for traefik is available on port 8080 via HTTP.

A single network `*_test-net` is created for the deployment. You can
attach test containers to this network to debug individual services.
For example, the command:

    docker run -it --network nuvla_test-net  ubuntu:16.04

will attach an ubuntu machine to the network. The network prefix
corresponds to the stack name (see below).

Prerequisites
-------------

If running Docker locally, you'll need to initialize your deployment
to run in swarm mode. Just run the command:

```sh
docker swarm init
```

The `docker stack` commands below should then work.

Starting
--------

This can be started with the command:

```sh
docker stack deploy -c docker-compose.yml nuvla
```

The stack name "nuvla" can be anything.  If you change it, adapt the
commands below.

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

**The default super password should not be used for long-lived
deployments!**

Stopping
--------

To stop the server, simply do the following:

```sh
docker stack rm nuvla
```

This should stop the containers and remove the containers and
networks.

The volumes ("nuvla_esdata", "nuvla_zkdata", and "nuvla_zkdatalog")
will remain and will be reused if the test deployment is restarted
with the same name. To remove them,

```sh
docker volume rm nuvla_esdata nuvla_zkdata nuvla_zkdatalog
```

or to remove all unused volumes:

```sh
docker volume prune
```

Be careful with the prune command, as it will remove all unused
volumes from all deployments.

**NOTE: Because of the problem described below, you may want to simply
redeploy the stack for updates rather than stopping and starting the
stack.**

Clean Up Problems
-----------------

When running the command to remove the stack, it should asynchonously
delete all the resources associated with the stack. Unfortunately,
there are race conditions in the clean up that often cause the
nuvla_api container to remain defined (but not running).  This in turn
causes the nuvla_test-net network deletion to fail. Worse, it ends in
a state where the network can be listed but not deleted. Grrr...

The discussion around this issue can be found in a [GitHub
issue](https://github.com/moby/moby/issues/32620) and a related
[Gist](https://gist.github.com/dperny/86bb33f195e4a3c27bbc497372652994)
that describes the `network rm` problems.

The only clean workaround is to restart the Docker daemon.

Although it will leave dangling network definitions, you can just use
a different name for a new deployment to avoid the restart.
