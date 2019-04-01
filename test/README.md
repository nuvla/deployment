Complete TEST Nuvla Deployment
==============================

This directory contains a Docker compose file that describes a complete
Nuvla deployment for TEST purposes.

It configures traefik as a load balancer and router between the
backend services.  The deployment includes:

 - **es**: Elasticsearch database. Not accessible externally.
 
 - **zk**: Zookeeper for job processing. Not accessible externally.
 
 - **api**: Nuvla API server. It is also accessible through the
   traefik endpoint on the `/api*` paths. Paths not starting with
   `/api/` will be redirected to `/api/cloud-entry-point`.
   
 - **ui**: Nuvla browser user interface. Serves the static content of
   the user interface. Accessible through traefik on the `/*`
   paths. Paths that do not start with `/ui/` will be redirected to
   `/ui/`.
   
 - **job-\***: Engine for asynchronous processing of jobs. Job
   executor, distributor, and cleanup containers are started as part
   of the deployment.  These are accessible only internally.
   
 - **proxy**: Traefik load balancer and router. Deployed Nuvla service
   accessible on port 443 with a self-signed certificate. The web
   interface for traefik is available on port 8080 via HTTP. This is
   **not** a secure configuration for production.

Prerequisites
-------------

If running Docker locally, you'll need to initialize your deployment
to run in swarm mode. Just run the command:

```sh
docker swarm init
```

The `docker stack` commands below should then work.

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

**The default super password should not be used for long-lived
  deployments!**

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

