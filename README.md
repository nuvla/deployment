# NuvlaBox Engine

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)](https://github.com/nuvlabox/deployment/graphs/commit-activity)


[![CI](https://img.shields.io/travis/com/nuvlabox/deployment?style=for-the-badge&logo=travis-ci&logoColor=white)](https://travis-ci.com/nuvlabox/deployment)
[![GitHub issues](https://img.shields.io/github/issues/nuvlabox/deployment?style=for-the-badge&logo=github&logoColor=white)](https://GitHub.com/nuvlabox/deployment/issues/)
[![GitHub release](https://img.shields.io/github/release/nuvlabox/deployment?style=for-the-badge&logo=github&logoColor=white)](https://github.com/nuvlabox/deployment/releases/tag/1.1.0)
[![GitHub release](https://img.shields.io/github/release-date/nuvlabox/deployment?logo=github&logoColor=white&style=for-the-badge)](https://github.com/nuvlabox/deployment/releases)


![logo](https://media.sixsq.com/hubfs/SixSq_General/nuvlabox_logo_red_on_transparent_2500px.png)

This repository container the definitions for the installation of the NuvlaBox Engine.

For further details, go to the [online documentation](https://docs.nuvla.io/docs/dave/nuvlabox.html).

## Artifacts

In this repository you will find three different compose files:
 - **docker-compose.yml**: this is meant for a production NuvlaBox Engine installation, 
 where `nuvla.io` is the default Nuvla endpoint
 
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

 1. login into https://nuvla.io or your Nuvla installation
 2. create a `nuvlabox` resource and save the UUID
 3. simply `export NUVLABOX_UUID=` UUID you saved, **or** paste that UUID in the `docker-compose.yml` file, under the NUVLABOX_UUID environment variable
 4. If you are using your own Nuvla installation also `export NUVLA_ENDPOINT=` IP of the local Nuvla instance, **or** paste that IP in the `docker-compose.yml` file, under the NUVLA_ENDPOINT environment variable 
 5. install the NuvlaBox Engine
    ```bash
    $ docker-compose up --abort-on-container-exit
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


## Copyright

Copyright &copy; 2019, SixSq Sàrl
