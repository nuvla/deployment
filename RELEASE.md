# Release Process

Release of deployment repository is managed by [Release Please](https://github.com/google-github-actions/release-please-action).
This tool allow to:
1. Automate CHANGELOG generation
2. The creation of GitHub releases
3. Version bumps for the project

It does so by parsing the git history, looking for Conventional Commit messages, and creating release PRs.

