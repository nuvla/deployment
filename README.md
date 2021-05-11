# NuvlaBox Engine

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)](https://github.com/nuvlabox/deployment/graphs/commit-activity)
[![GitHub issues](https://img.shields.io/github/issues/nuvlabox/deployment?style=for-the-badge&logo=github&logoColor=white)](https://GitHub.com/nuvlabox/deployment/issues/)
[![GitHub release](https://img.shields.io/github/release/nuvlabox/deployment?style=for-the-badge&logo=github&logoColor=white)](https://github.com/nuvlabox/deployment/releases/tag/1.1.0)
[![GitHub release](https://img.shields.io/github/release-date/nuvlabox/deployment?logo=github&logoColor=white&style=for-the-badge)](https://github.com/nuvlabox/deployment/releases)

![CI Build](https://github.com/nuvlabox/deployment/actions/workflows/main.yml/badge.svg)
![CI Release](https://github.com/nuvlabox/deployment/actions/workflows/release.yml/badge.svg)
![CI Test](https://github.com/nuvlabox/deployment/actions/workflows/test.yml/badge.svg)


This repository container the definitions for the installation of the NuvlaBox Engine.

For further details, go to the [online documentation](https://docs.nuvla.io/docs/dave/nuvlabox.html).

## Artifacts

In this repository you will find three different compose files:
 - **docker-compose.yml**: this is meant for a production NuvlaBox Engine installation, 
 where `nuvla.io` is the default Nuvla endpoint
 
 - **docker-compose.*.yml**: these are optional peripheral managers

## Releasing 

To trigger an automatic release of the NuvlaBox Engine, simply run:

```bash
./trigger-release.sh VERSION
```

where `VERSION` is the tag version to be released, with semantic versioning (e.g. 1.0.0).

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
    $ docker-compose -p nuvlabox -f docker-compose.yml up
    ```
    NOTE: add `-f docker-compose.usb.yml -f ... `, to the command above, in order to add the auto peripheral discovery components

## Copyright

Copyright &copy; 2019, SixSq Sàrl
