# Release Process

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
