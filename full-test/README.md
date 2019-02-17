Complete TEST Nuvla Deployment
==============================

This directory contains a Docker compose file that describes a complete
Nuvla deployment for TEST purposes.

It configures traefik as a load balancer and router between the
backend services.  The deployment includes:

 - **es**: Elasticsearch database. Not accessible externally.
 
 - **zk**: Zookeeper for job processing. Not accessible externally.
 
 - **api**: Nuvla API server. Accessible externally on port 8200 to
   allow for bootstrapping the service. It is also accessible through
   the traefik endpoint on the `/api*` paths. Paths not starting with
   `/api/` will be redirected to `/api/cloud-entry-point`.
   
 - **ui**: Nuvla browser user interface. Serves the static content of
   the user interface. Accessible through traefik on the `/*`
   paths. Paths that do not start with `/ui/` will be redirected to
   `/ui/`.
   
 - **job**: Engine for asynchronous process of jobs. **Not currently
   active.**
   
 - **proxy**: Traefik load balancer and router. Deployed Nuvla service
   accessible on port 80. The web interface for traefik is available
   on port 8080. This is **not** a secure configuration for
   production.

This deployment is **not suitable for production** because of the
following settings:

 - HTTP (not HTTPS) is used for external access to the service.
 - The traefik web interface (port 8080) is exposed.
 - The API server (port 8200) is directly exposed.

These settings are, however, useful for testing. 

Starting
--------

This can be started with the command:

```sh
docker-compose up -d
```

You can view the API server logs by running the command:

```sh
docker-compose logs -f api
```

The logs will indicate when the API server on port 8200 is available.
This is normally the last service to come up.

The full Nuvla deployment can be accessed from
`http://nuvla.example.org/`, using your actual host name
(e.g. localhost if running locally).

Bootstrapping
-------------

The database will be empty, with no users or any other resources. To
bootstrap the server by creating a super user, use the following
procedure.

Create a hashed password value for the super user:

```sh
echo -n "plaintext-password" | \
  sha512sum | \
  cut -d ' ' -f 1 | \
  tr '[:lower:]' '[:upper:]'
```

Create a file named `user-template-super.json` that contains the
following:

```json
{
    "userTemplate" : {
        "href" : "user-template/direct",
        "username" : "super",
        "password" : "${hashed_password}",
        "emailAddress" : "super@example.com",
        "state" : "ACTIVE",
        "isSuperUser" : true
    }
}
```

replacing `${hashed_password}` with the value you generated above.

Create the super user via the CIMI server:

```sh
curl -XPOST \
     -H 'nuvla-authn-info:internal ADMIN' \
     -H 'content-type:application/json' \
     -d@user-template-super.json \
     http://nuvla.example.org:8200/api/user
```

You will now be able to log into server as the `super` user:

```sh
curl -XPOST \
     -d href=session-template/internal \
     -d username=super \
     -d password=${plaintext_password} \
     http://nuvla.example.org/api/session
```

replacing `${plaintext_password}` with the original plaintext value of
your password.

You can then configure your server normally via the API.

Stopping
--------

To stop the server, simply do the following:

```sh
docker-compose down -v
```

This should stop the containers and remove the containers and any
volumes that were created.
