# Changelog

## Unreleased

  - Deployment state job was split into two for "new" and "old" deployments with
    10 and 60 seconds check intervals respectively. This was done to reduce
    unnecessary load on the server and remote COEs.

## [2.2.0] - 2020-07-06

This release update nuvla components to following versions:
  - [nuvla/api-server:5.0.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#500---2020-07-06)
  - [nuvla/job-engine:2.4.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#240---2020-07-06)
  - [nuvla/ui:2.5.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#250---2020-07-06)

### Added

  - Job distributor jobd-usage-report

### Updated

  - Job executor entrypoint changed

## [2.1.17] - 2020-05-12

This release update nuvla components to following versions:
  - [nuvla/api-server:4.2.16](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#4216---2020-05-12)
  - [nuvla/job-engine:2.3.16](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2316---2020-05-11)
  - [nuvla/ui:2.4.15](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2415---2020-05-12)


## [2.1.16] - 2020-04-14

This release update nuvla components to following versions:
  - [nuvla/api-server:4.2.14](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#4214---2020-04-14)
  - [nuvla/job-engine:2.3.15](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2315---2020-04-14)
  - [nuvla/ui:2.4.13](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2413---2020-04-14)

## [2.1.15] - 2020-03-27

This release update nuvla components to following versions:
  - [nuvla/api-server:4.2.13](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#4213---2020-03-27)
  - [nuvla/job-engine:2.3.14](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2314---2020-03-27)
  - [nuvla/ui:2.4.12](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2412---2020-03-27)

## [2.1.13] - 2020-03-06

This release add support for private registries in all Nuvla components.
A new `nuvlabox-release` resource have been added to assist NuvlaBox creation.
NuvlaBox got new actions as check-api and reboot and new attributes to support 
data-gateway. Deployment resource got data workflow attribute deprecated and 
been replaced by `data-records-filter` attribute.

### Added

  - Job distributor jobd-nuvlabox-releases

### Updated

  - Functional tests - wait for deployment params to have a value
  - Update to nuvla/api:4.2.12
  - Update to nuvla/ui:2.4.11
  - Update to nuvla/job:2.3.13

## [2.1.12] - 2020-02-07

This release fix credential acl for NuvlaBox to allow viewers to check the 
credential at deployment time. NuvlaBox agent is able to push labels as 
tags at commission time. NuvlaBox schema got a new attribute to register 
the endpoint of data gateway. User is able to set NuvlaBox location. 
NuvlaBox status got schema update to add topic raw-sample. Voucher resource 
got country mapping and a new resource which is voucher discipline.
UI display NuvlaBox location on a Map and allow user to move them.

## [2.1.11] - 2020-01-23

This release add a new check operation on credential of infrastructure services.
UI warn user before dangerous actions and deployment modal checks credentials 
before launch. Job engine got a default timeout for bash commands of 2 minutes 
for connectors. To know more check changelog for each component updated.

### Changed

  - Update to nuvla/api:4.2.9
  - Update to nuvla/ui:2.4.9
  - Update to nuvla/job:2.3.12

## [2.1.10] - 2020-01-10

Share a NuvlaBox is now easier and acls are propagated to NuvlaBox subresources. 
Kubernetes connector support environment variables substitution and support 
Kubernetes logging on UI. UI got new login and sign up pages. 

### Changed

  - Update to nuvla/api:4.2.8
  - Update to nuvla/ui:2.4.8
  - Update to nuvla/job:2.3.11

## [2.1.9] - 2019-12-09

Patch release to fix an issue in stopping docker application from job engine.

### Changed

  - Update to nuvla/api:4.2.7
  - Update to nuvla/job:2.3.10
  - Update to nuvla/ui:2.4.7

## [2.1.8] - 2019-12-09

Alpha support for Kubernetes added to all components. OpenVPN added for NuvlaBox workflow. 
UI got a lot of minors fixes and OCRE page got a PIE chart summary.

### Changed

  - Update to nuvla/api:4.2.7
  - Update to nuvla/job:2.3.9
  - Update to nuvla/ui:2.4.7

## [2.1.7] - 2019-11-13

Api-server bulk delete extended for most resources. VPN support for NuvlaBox resource was 
added by adding credential templates and infrastructure service of subtype VPN. NuvlaBox 
resources name was simplified. This release also fix stale job caused by race condition.
UI got support for NuvlaBox peripherals. Infrastructure page got a fix to resolve 
inconsistency between pages. Api page got bulk delete support. OCRE page visible for users
in group/ocre-user. Appstore cards are now ordered by created time. Application yaml 
syntax is checked to show erros and hints messages.

### Changed

  - Update to nuvla/api:4.2.6
  - Update to nuvla/job:2.3.8
  - Update to nuvla/ui:2.4.6

## [2.1.6] - 2019-10-10

Api-server support bulk delete for data-record resource. Session validity was extended from 
1 day to a 1 week. Group resource allow to set acl at creation time. Callbacks for user 
registration are now re-executable. UI allow infrastructure service group to have more than 
one subtype of service. Job-engine use python library (nuvla-api) which support bulk delete. 

### Changed

  - Update to nuvla/api:4.2.5
  - Update to nuvla/job:2.3.7
  - Update to nuvla/ui:2.4.5

## [2.1.5] - 2019-09-18

Release fix in api-server cloud-entry-point base-uri when server port is being forwarded and 
allow users to delete deployment log. This release adds two new job distributors for module 
component and deployment service to create notifications. Docker job distributors have been 
renamed. UI got a new favicon and some dependencies updates and notification better management.

### Changed

  - Update to nuvla/api:4.2.4
  - Update to nuvla/job:2.3.6
  - Update to nuvla/ui:2.4.4


## [2.1.4] - 2019-09-04

Release allows users to see deployment logs and to get notifications when a new version of Docker 
image is available allowing him to update a module or a running component. A new voucher report 
resource has been added to the server. Job-Engine got some fixes around deployment state and 
NuvlaBox decommission. User can now give a name to Nuvlabox at creation time and all sub-resources 
will get this name to facilitate the identification of the box. UI got some fixes in styling and 
raw textarea allow now users to search and to see the search result highlighted.

### Changed

  - Update to nuvla/api:4.2.3
  - Update to nuvla/job:2.3.5
  - Update to nuvla/ui:2.4.3

## [2.1.3] - 2019-08-07

Release add nuvlabox-peripheral resource and updated the version numbers (v1) for the other 
nuvlabox resources. And other fixes. UI got a refactored sidebar and footer and support external 
authentication redirection. Login modal visible when needed. Job-Engine got some fixes. 
Nuvlabox decommission action delete linked nuvlabox-peripheral.

### Changed

  - Update to nuvla/api:4.2.2
  - Update to nuvla/job:2.3.4
  - Update to nuvla/ui:2.4.2

## [2.1.2] - 2019-07-29

Release resolve deployment related issues job-engine and ui side. 
The api fix some issues related to external authentication and resource-metadata related updates.

### Changed

  - Update to nuvla/api:4.2.1
  - Update to nuvla/job:2.3.3
  - Update to nuvla/ui:2.4.1

## [2.1.1] - 2019-07-25

Release contains a minor patch in job component.

### Changed

  - Update to nuvla/job:2.3.2

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
  - Update to nuvla/job:2.3.1

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

 
