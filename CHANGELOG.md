# Changelog

## [2.1.0] - 2019-07-24

Release contains support for applications which contain multiple
containers. This is provided by the api, ui, and job components of
the release.

The release also contains prototype support for external authentication
mechanisms. The resources are available from the API, but the UI 
does not yet support these mechanisms.

All updated components contain minor bug fixes.

### Changed

  - Update to nuvla/api:4.2.0
  - Update to nuvla/ui:2.4.0
  - Update to nuvla/job:2.3.0

## [2.0.0] - 2019-05-26

Production release of Nuvla platform. This release allows users to 
manage container-based components across Docker Swarm infrastructures,
manage data, and deploy and use NuvlaBox resources at the edge.

### Changed

  - Update api-server, ui, and job engine which support newer schemas
    for resources related to deployments and modules.
  - Switch to using a customized container for Elasticsearch that allows
    for database backups via S3. 
  - Update to nuvla/ui:2.1.1 that provides fixes for the edge control
    workflow.
  - Update to nuvla/ui:2.1.0 that provides the edge control page and
    other improvements.
  - Update to latest version of nuvla/api:3.1.0 that provides some 
    improvements related to management of nuvlabox resources.
  - Update to latest release of job-engine that allows authentication 
    between services via headers rather than a shared password.
  - Update to nuvla/api:3.0.0, which contains numerous fixes and support
    for the NuvlaBox (not backwards compatible)
  - Update to nuvla/ui:2.0.1, which contains many usability and bug fixes
  - Update to nuvla/api:2.2.0, which contains a new template for user
    invitations.

## [1.0.0] - 2019-05-21

### Changed
  - Update to nuvla/ui:2.0.0, with numerous improvements and bug fixes.
  - Update to nuvla/api:2.1.0, with notification resources and bug fixes.
  - Updated test deployment to use auto-generated SSL and session certificates.
  - Simplify test deployment to use a single network, allowing the stack deploy
    name to be changed.
  - Use named volumes for the test deployment to allow state to be saved
    between updates and re-deployments.

## [0.9.0] - 2019-04-17

### Changed

  - Initial release to test deployment process.

 
