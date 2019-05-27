# NuvlaBox Engine

This repository container the definitions for the installation of a NuvlaBox (via the NuvlaBox Engine).

## Artifacts

In this repository you will find three different compose files:
 - **docker-compose.yml**: this is meant for a production NuvlaBox Engine installation, 
 where `nuvla.io` is the default Nuvla endpoint
 
 - **docker-compose.onpremise.yml**: this is meant for demonstration purposes, where 
 there is a Nuvla deployment running on a machine, which is only reachable via the local network
 
 - **docker-compose.localhost.yml**: this is meant for testing purposes, where Nuvla is 
 running on the same machine that will install the NuvlaBox Engine
 
## Deploying

### Prerequisites 

To install the NuvlaBox Engine, you'll need:
 - *Docker (version 18 or higher)*
 - *Docker Compose (version 1.23.2 or higher)*
 
The NuvlaBox Engine will, during bootstrap, double check for other requirements (like 
Docker Swarm), but you'll be automatically prompted in case some of these are not met.


### Production Deployment

_**artifact:** docker-compose.yml_

In this scenario, we assume you are using Nuvla at https://nuvla.io.

 1. login into https://nuvla.io
 2. create a `nuvlabox` resource and save the UUID
 3. simply `export NUVLABOX_UUID=` UUID you saved, **or** paste that UUID in the `docker-compose.yml` file, under the NUVLABOX_UUID environment variable
 4. install the NuvlaBox Engine
    ```bash
    $ docker-compose up --abort-on-container-exit
    ```


### On-premise Deployment

_**artifact:** docker-compose.onpremise.yml_

In this scenario, we assume there is a Nuvla deployment running in a separate machine, 
reachable via the local network.

 1. login into your local Nuvla instance, as instructed in https://github.com/nuvla/deployment/tree/master/demo
 2. create a `nuvlabox-record` and save the UUID
 3. simply `export NUVLABOX_UUID=` UUID you saved, **or** paste that UUID in the `docker-compose.onpremise.yml` file, under the NUVLABOX_UUID environment variable
 4. also `export NUVLA_ENDPOINT=` IP of the local Nuvla instance, **or** paste that IP 
 in the `docker-compose.onpremise.yml` file, under the NUVLA_ENDPOINT environment variable
 5. install the NuvlaBox Engine
    ```bash
    $ docker-compose -f docker-compose.onpremise.yml up --abort-on-container-exit
    ```
    

### Test Deployment

_**artifact:** docker-compose.localhost.yml_

In this scenario, we assume you already have a Nuvla deployment running on your machine.

 1. double check your local Nuvla deployment is up and running
    ```bash
    $ docker stack ls
    
    NAME                SERVICES            ORCHESTRATOR
    nuvla               7                   Swarm
    ```
    ```bash
    $ docker stack ps nuvla -f 'desired-state=running'
    
    ID                  NAME                            IMAGE                                                 NODE                    DESIRED STATE       CURRENT STATE            ERROR               PORTS
    jbnuz172zv90        nuvla_job-dist-jobs-cleanup.1   nuvla/job:2.0.0                                       linuxkit-025000000001   Running             Running 43 seconds ago                       
    rs52vxbv8mxz        nuvla_job-executor.1            nuvla/job:2.0.0                                       linuxkit-025000000001   Running             Running 45 seconds ago                       
    t684lthjs4le        nuvla_zk.1                      zookeeper:3.4                                         linuxkit-025000000001   Running             Running 2 minutes ago                        
    5q9xh8wxv8ep        nuvla_es.1                      docker.elastic.co/elasticsearch/elasticsearch:7.0.0   linuxkit-025000000001   Running             Running 2 minutes ago                        
    jbon8zz91smr        nuvla_proxy.1                   traefik:1.7                                           linuxkit-025000000001   Running             Running 2 minutes ago                        
    uc0wz9tl7e1c        nuvla_ui.1                      nuvla/ui:0.0.2                                        linuxkit-025000000001   Running             Running 3 minutes ago                        
    oefzrm9dlkig        nuvla_api.1                     nuvladev/api:nuvlabox-record                          linuxkit-025000000001   Running             Running 2 minutes ago        
    
    ```
    
 2. because the NuvlaBox containers will need to reach out to the Nuvla containers, they all need 
 to be in the same network, so let's create a dedicated one, and attach `nuvla_proxy` to it
 
    ```bash
    $ docker network create localhost_nuvlabox --attachable
    ```
    ```bash
    $ CONTAINER_ID=`docker inspect $(docker service ps nuvla_proxy --format '{{json .}}' | jq -r .ID) | jq -r .[].Status.ContainerStatus.ContainerID`

    $ docker network connect --alias local-nuvla-endpoint localhost_nuvlabox $CONTAINER_ID
    ```
    
 3. login into your localhost Nuvla, as instructed in https://github.com/nuvla/deployment/tree/master/demo
 4. create a `nuvlabox-record` and save the UUID
 5. simply `export NUVLABOX_UUID=` UUID you saved, **or** paste that UUID in the `docker-compose.localhost.yml` file, under the NUVLABOX_UUID environment variable
 6. install the NuvlaBox Engine
    ```bash
    $ docker-compose -f docker-compose.localhost.yml up --abort-on-container-exit
    ```


## Contributing

### Source Code Changes

To contribute code to this repository, please follow these steps:

 1. Create a branch from master with a descriptive, kebab-cased name
    to hold all your changes.

 2. Follow the developer guidelines concerning formatting, etc. when
    modifying the code.
   
 3. Once the changes are ready to be reviewed, create a GitHub pull
    request.  With the pull request, provide a description of the
    changes and links to any relevant issues (in this repository or
    others). 
   
 4. Ensure that the triggered CI checks all pass.  These are triggered
    automatically with the results shown directly in the pull request.

 5. Once the checks pass, assign the pull request to the repository
    coordinator (who may then assign it to someone else).

 6. Interact with the reviewer to address any comments.

When the reviewer is happy with the pull request, he/she will "squash
& merge" the pull request and delete the corresponding branch.

### Testing

Add appropriate tests that verify the changes or additions you make to
the source code.

### Code Formatting

This repository contains mostly Docker container descriptions and bash
scripts. When modifying a file, keep the style of the existing code.

## Copyright

Copyright &copy; 2019, SixSq Sàrl
