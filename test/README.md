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

Starting
--------

This can be started with the command:

```sh
docker stack deploy nuvla
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

If SUPER_PASS env variable is set and super user doesn't already exist,
the super user will be created at the server startup.

DON'T FORGET TO CHANGE THE DEFAULT `SUPER_PASS` PASSWORD.

You can then configure your server normally via the API.

Stopping
--------

To stop the server, simply do the following:

```sh
docker stack rm nuvla
```

This should stop the containers and remove the containers and any
volumes that were created.
