# Nuvla Deployments

[![Build Status](https://github.com/nuvla/deployment/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/nuvla/deployment/actions/workflows/main.yml)

This repository contains the definitions for the deployment of the Nuvla platform.

The most popular deployment definitions are:
 1. [**Test deployment**](https://github.com/nuvla/deployment/tree/master/test): great to quickly deploy a Nuvla deployment on a single machine for testing or evaluation
 2. [**Production deployment**](https://github.com/nuvla/deployment/tree/master/prod): (work in progress) to deploy a production deployment, where the stateful services are
    persisted and services can be distributed across a multi-node cluster.

Another popular deployment is [**Docker Swarm**](https://github.com/nuvla/deployment/tree/master/swarm), which is needed to host the Nuvla service and provide a target infrastructure
on which to deploy.

For more deployment scenarios, feel free to explore the other README files present in the different subdirectories for
detailed information.

## Artifacts

 - Docker deployment files. See the archives published in the
   [nuvla/deployment releases
   area](https://github.com/nuvla/deployment/releases).

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

Copyright &copy; 2019-2024, SixSq SA

## License

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License.  You may
obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.
