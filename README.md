# Nuvla Deployments

This repository contains the definitions for the deployment of the
Nuvla platform.  See the README in each of the subdirectories for
detailed information about each deployment.

## Artifacts

 - Docker deployment files. See the archives published in the
   [nuvla/deployment releases
   area](https://github.com/nuvla/deployment/releases).

## Release Process

**Before** trying to release the code, you must add the following to
your `~/.m2/settings.xml` file:

    <servers>
      <server>
        <id>github</id>
        <username>github-username</username>
        <privateKey>github-token</privateKey>
      </server>
    </servers>

replacing the username and privateKey values with your own.

Update the `CHANGELOG.md` file **before** releasing the code.  Provide
a good descriptions of the updates contained in the release.

Ensure that the **current snapshot version** is the one that you want
to tag, keeping in mind the guidelines for semantic versioning. Update
the version in the `pom.xml` file if necessary.

This repository uses `mvn` to perform the release and to upload the
artifacts to GitHub.  Although this uses the standard maven releases
plugin, the full process can be run with:

    ./release.sh

If there are any failures, you'll need to rollback and clean up.  In
this case, fix the problem and try again.

If there are no problems when releasing, check that GitHub releases
area to be sure that the artifacts have been uploaded.

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
