# Demonstration Nuvla Deployment

This directory contains a Docker compose file that describes a
complete Nuvla deployment for demonstrations.  This deployment does
not provide any means for handling the long-term persistence of data
and consequently, should not be used for production.

## Prerequisites

If running Docker locally, you'll need to initialize your deployment
to run in swarm mode. Just run the command:

```sh
docker swarm init
```

The `docker stack` commands below should then work.

## Starting

This can be started with the command:

```sh
docker stack deploy -c docker-compose.yml demo
```

> **WARNING**: You must use the stack name "demo", unless you modify
> the `docker-compose.yml` file.

You can view the status of the deployment with:

```sh
docker stack services demo
```

If this is the first time you've run the demo, it make take some time
to download the images and to then start the services.

With the service reference, you can view the logs of any service:

```sh
docker service logs -f demo_api
```

changing the name of the service as necessary.

The browser interface for Nuvla can be accessed from
`https://localhost/` and the API from
`https://localhost/api/cloud-entry-point`.  assuming that you're
running everything locally.  Change "localhost" to your host name when
running remotely.

> **NOTE**: The demonstration deployment uses self-signed
> certificates, so you will have to authorize a security exception in
> your browser or from your command line tool.

## Bootstrapping

If NUVLA_SUPER_PASSWORD env variable is set and super user doesn't
already exist, the super user will be created at the server
startup. The default value is "supeR8-supeR8", but you can use a
different value if you wish.

## Stopping

To stop the server, simply do the following:

```sh
docker stack rm demo
```

This should stop the containers and remove the containers and defined
networks.

The volumes ("demo_esdata", "demo_zkdata", and "demo_zkdatalog") will
remain and will be reused if the demonstration is restarted.  To
remove them,

```sh
docker volume rm demo_esdata demo_zkdata demo_zkdatalog
```

or to remove all unused volumes:

```sh
docker volume prune
```

Be careful with the prune command, as it will remove all unused
volumes from all deployments.

## Manual Clean Up

When running the command to remove the stack, it should asynchonously
delete all the resources associated with the stack. Unfortunately,
there are race conditions in the task management that may cause the
"demo_frontend" network to enter a state where it cannot be deleted.

The discussion around this issue can be found in a [GitHub
issue](https://github.com/moby/moby/issues/32620) and a related
[Gist](https://gist.github.com/dperny/86bb33f195e4a3c27bbc497372652994)
that describes the `network rm` problems.

The only clean workaround is to restart the Docker daemon.

## Deploying demo Nuvla instance with notifications

For demonstration of the notification feature of Nuvla use `docker-compose-notifs.yml`
for the deployment. To configure email notifications, please set the following 
environment variables before launching the deployment.

```
      SMTP_HOST: "${SMTP_HOST}"
      SMTP_PORT: "${SMTP_PORT}"
      SMTP_SSL: "${SMTP_SSL}"
      SMTP_USER: "${SMTP_USER}"
      SMTP_PASSWORD: "${SMTP_PASSWORD}"
```