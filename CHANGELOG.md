# Changelog

## Released

## [2.10.0](https://github.com/nuvla/deployment/compare/v2.9.0...v2.10.0) (2024-10-21)


### Dependencies

* **api-server:** nuvla/api:6.10.0 ([9a3e23d](https://github.com/nuvla/deployment/commit/9a3e23db089af2d9130f8fbf58954c1cce4c2093))
* **job-engine:** nuvla/job:4.6.1 ([9a3e23d](https://github.com/nuvla/deployment/commit/9a3e23db089af2d9130f8fbf58954c1cce4c2093))
* **ui:** nuvla/ui:2.40.0 ([9a3e23d](https://github.com/nuvla/deployment/commit/9a3e23db089af2d9130f8fbf58954c1cce4c2093))

## [2.9.0](https://github.com/nuvla/deployment/compare/v2.8.1...v2.9.0) (2024-09-25)


### Dependencies

* **api-server:** nuvla/api:6.9.0 ([a9099ce](https://github.com/nuvla/deployment/commit/a9099cee70c3050ef3bd736461bbd810691a757f))
* **job-engine:** nuvla/job:4.4.0 ([a9099ce](https://github.com/nuvla/deployment/commit/a9099cee70c3050ef3bd736461bbd810691a757f))
* **ui:** nuvla/ui:2.39.0 ([a9099ce](https://github.com/nuvla/deployment/commit/a9099cee70c3050ef3bd736461bbd810691a757f))


### Configuration

* **traefik:** enable compression for api server ([#100](https://github.com/nuvla/deployment/issues/100)) ([fcbfe60](https://github.com/nuvla/deployment/commit/fcbfe607de916c3381eef9ef09fbccad58f3ffde))

## [2.8.1](https://github.com/nuvla/deployment/compare/v2.8.0...v2.8.1) (2024-04-11)


### Dependencies

* **api:** nuvla/api:6.6.0 ([#99](https://github.com/nuvla/deployment/issues/99)) ([6fd3b4c](https://github.com/nuvla/deployment/commit/6fd3b4cd65ecb3a34268a85215fcbaa7c807bd50))
* **monitoring:** Deprecated es exporter replaced by prometheuscommunity/elasticsearch-exporter:v1.7.0 ([926fc52](https://github.com/nuvla/deployment/commit/926fc5267ef313795b6ed06aa23650e5b662aea7))


### Configuration

* **api:** logback logging ([6fd3b4c](https://github.com/nuvla/deployment/commit/6fd3b4cd65ecb3a34268a85215fcbaa7c807bd50))

## [2.8.0](https://github.com/nuvla/deployment/compare/v2.7.1...v2.8.0) (2024-03-22)


### Dependencies

* **api-server:** nuvla/api:6.5.0 ([ae41833](https://github.com/nuvla/deployment/commit/ae418337a0ba1696b19ec333901fb7a5f179170f))
* **es:** nuvla/es:nuvla/es:8.11.3.0 ([ae41833](https://github.com/nuvla/deployment/commit/ae418337a0ba1696b19ec333901fb7a5f179170f))
* **job-engine:** nuvla/job:4.0.3 ([ae41833](https://github.com/nuvla/deployment/commit/ae418337a0ba1696b19ec333901fb7a5f179170f))
* **ui:** nuvla/ui:2.36.5 ([ae41833](https://github.com/nuvla/deployment/commit/ae418337a0ba1696b19ec333901fb7a5f179170f))

## [2.7.1](https://github.com/nuvla/deployment/compare/v2.7.0...v2.7.1) (2023-12-21)


### Dependencies

* **api-server:** nuvla/api:6.4.1 ([48e68db](https://github.com/nuvla/deployment/commit/48e68db9603926a3ed15f992b2e32bff24c826e0))
* **job-engine:** nuvla/job:3.9.3 ([48e68db](https://github.com/nuvla/deployment/commit/48e68db9603926a3ed15f992b2e32bff24c826e0))
* **ui:** nuvla/ui:2.36.1 ([48e68db](https://github.com/nuvla/deployment/commit/48e68db9603926a3ed15f992b2e32bff24c826e0))

## [2.7.0](https://github.com/nuvla/deployment/compare/v2.6.0...v2.7.0) (2023-12-14)


### Dependencies

* **api-server:** nuvla/api:6.4.0 ([4205099](https://github.com/nuvla/deployment/commit/4205099bba5210cc7dd615928eb13abe9c25bb8a))
* **job-engine:** nuvla/job:3.9.2 ([4205099](https://github.com/nuvla/deployment/commit/4205099bba5210cc7dd615928eb13abe9c25bb8a))
* **ui:** nuvla/ui:2.36.0 ([4205099](https://github.com/nuvla/deployment/commit/4205099bba5210cc7dd615928eb13abe9c25bb8a))


### Configuration

* **monitoring:** Config to scrape Traefik metrics ([2a32a27](https://github.com/nuvla/deployment/commit/2a32a275aef6ceba94f9f1ab9fed0e64751e03bf))
* **traefik:** Export Traefik metrics to Prometheus ([2a32a27](https://github.com/nuvla/deployment/commit/2a32a275aef6ceba94f9f1ab9fed0e64751e03bf))


### Features

* Deployment group public release ([4205099](https://github.com/nuvla/deployment/commit/4205099bba5210cc7dd615928eb13abe9c25bb8a))


### Bug Fixes

* **prod:** ES avoid swapping by memory lock ([#93](https://github.com/nuvla/deployment/issues/93)) ([af9c2ff](https://github.com/nuvla/deployment/commit/af9c2ff8061dcaa982d38abf3bcb1948e039eb01))

## [2.6.0](https://github.com/nuvla/deployment/compare/v2.5.0...v2.6.0) (2023-11-10)


### Dependencies

* **api-server:** nuvla/api:6.3.0 ([5932726](https://github.com/nuvla/deployment/commit/5932726fa7084af0c490168bbebadf352b80a3d8))
* **job-engine:** nuvla/job:3.9.0 ([5932726](https://github.com/nuvla/deployment/commit/5932726fa7084af0c490168bbebadf352b80a3d8))
* **ui:** nuvla/ui:2.35.0 ([5932726](https://github.com/nuvla/deployment/commit/5932726fa7084af0c490168bbebadf352b80a3d8))


### Features

* Values query support; get queries support select parm, select param behavior enhanced ([5932726](https://github.com/nuvla/deployment/commit/5932726fa7084af0c490168bbebadf352b80a3d8))

## [2.5.0](https://github.com/nuvla/deployment/compare/v2.4.0...v2.5.0) (2023-10-27)


### Dependencies

* **api-server:** nuvla/api:6.2.0 ([83bff2c](https://github.com/nuvla/deployment/commit/83bff2c80b15afdbc8dc6a62235d4b5a891d340a))
* **job-engine:** nuvla/job:3.7.0 ([83bff2c](https://github.com/nuvla/deployment/commit/83bff2c80b15afdbc8dc6a62235d4b5a891d340a))
* **ui:** nuvla/ui:2.34.0 ([83bff2c](https://github.com/nuvla/deployment/commit/83bff2c80b15afdbc8dc6a62235d4b5a891d340a))


### Features

* Nuvlaedge heartbeat capability, heartbeat and telemetry decoupling, Refactor NuvlaEdge job execution (pull only) ([83bff2c](https://github.com/nuvla/deployment/commit/83bff2c80b15afdbc8dc6a62235d4b5a891d340a))

## [2.4.0](https://github.com/nuvla/deployment/compare/v2.3.7...v2.4.0) (2023-09-25)


### Dependencies

* **api-server:** nuvla/api:6.1.0 ([8b7799b](https://github.com/nuvla/deployment/commit/8b7799b243fd576210c65ae2520de6dd4bb30cff))
* **job-engine:** nuvla/job:3.7.0 ([8b7799b](https://github.com/nuvla/deployment/commit/8b7799b243fd576210c65ae2520de6dd4bb30cff))
* **ui:** nuvla/ui:2.33.14 ([8b7799b](https://github.com/nuvla/deployment/commit/8b7799b243fd576210c65ae2520de6dd4bb30cff))


### Features

* Deployment group state machine and operational status workflows ([8b7799b](https://github.com/nuvla/deployment/commit/8b7799b243fd576210c65ae2520de6dd4bb30cff))

## [2.3.7](https://github.com/nuvla/deployment/compare/v2.3.6...v2.3.7) (2023-08-24)


### Bug Fixes

* **release:** Fix notify if condition ([ff186d3](https://github.com/nuvla/deployment/commit/ff186d33c38140e4da077d738047a1dcc46e2b6c))
* **release:** Remove bootstrap release-please vars ([ff186d3](https://github.com/nuvla/deployment/commit/ff186d33c38140e4da077d738047a1dcc46e2b6c))

## [2.3.6](https://github.com/nuvla/deployment/compare/2.3.5...v2.3.6) (2023-08-24)


### Configuration

* **elasticsearch:** Send hostname to sniffer to resolve to current IP ([417df57](https://github.com/nuvla/deployment/commit/417df578d87ab7165c8cf2f9c00455c5bf87af03))
* **traefik:** Respond with 503 when no api-server or ui ([417df57](https://github.com/nuvla/deployment/commit/417df578d87ab7165c8cf2f9c00455c5bf87af03))


### Features

* Drive version and generate changelog from git commits messages ([fe4527f](https://github.com/nuvla/deployment/commit/fe4527f893dd6da3066f870a47d8ed4ddd81551c))


### Bug Fixes

* Broken release process replaced by release-please tool ([fe4527f](https://github.com/nuvla/deployment/commit/fe4527f893dd6da3066f870a47d8ed4ddd81551c))
* Remove references of Travis ([fe4527f](https://github.com/nuvla/deployment/commit/fe4527f893dd6da3066f870a47d8ed4ddd81551c))

## [2.3.5] - 2023-08-23

This release update Nuvla components to following versions:

- [nuvla/api-server:6.0.19](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#6019---2023-08-22)
- [nuvla/ui:2.33.12](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#23312---2023-07-28)
- [nuvla/job-engine:3.5.2](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#352---2023-08-22)
- Updates to the following event streaming components: Kafka v3.3.0, ksqlDB v0.25.0

## [2.3.2] - 2023-04-24

### Changed

This release update Nuvla components to following versions:

- [nuvla/api-server:6.0.12](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#6012---2023-04-24)
- [nuvla/ui:2.33.5](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2335---2023-04-24)
- [nuvla/job-engine:3.2.6](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#326---2023-04-24)

- Traefik proxy network to host to get real client IP

## [2.3.1] - 2022-12-20

### Changed

This release update Nuvla components to following versions:

- [nuvla/api-server:6.0.8](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#608---2022-12-19)
- [nuvla/ui:2.32.11](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#23211---2022-12-19)
- [nuvla/job-engine:3.2.4](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#324---2022-12-12)

## [2.3.0] - 2022-08-04

### Changed

This release update Nuvla components to following versions:

- [nuvla/api-server:6.0.2](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#602---2022-08-03)
- [nuvla/ui:2.31.2](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2312---2022-08-03)
- Traefik v1.7 to v2.8 migration

## [2.2.31] - 2022-06-29

### Changed

This release update Nuvla components to following versions:

- [nuvla/api-server:6.0.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#600---2022-06-29)
- [nuvla/ui:2.31.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2310---2022-06-29)
- [nuvla/job-engine:3.0.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#300---2022-06-29)

## [2.2.30] - 2022-05-13

### Changed

This release update Nuvla components to following versions:

- [nuvla/api-server:5.25.2](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5252---2022-05-12)
- [nuvla/ui:2.30.3](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2303---2022-05-13)
- [nuvla/job-engine:2.20.2](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2202---2022-05-12)
- Streams - updated streams for testability.

## [2.2.29] - 2022-05-02

### Changed

This release update Nuvla components to following versions:

- [nuvla/api-server:5.25.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5250---2022-04-29)
- [nuvla/ui:2.30.1](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2301---2022-04-29)
- [nuvla/job-engine:2.20.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2200---2022-04-29)
- [nuvla/kafka-notify:0.6.0](https://github.com/nuvla/kafka-notify/blob/main/CHANGELOG.md)

## [2.2.28] - 2022-03-08

### Changed

This release update Nuvla components to following versions:

- [nuvla/api-server:5.24.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5240---2022-03-07)
- [nuvla/ui:2.29.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2290---2022-03-07)
- [nuvla/job-engine:2.19.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2190---2022-03-08)
- [nuvla/kafka-notify:0.6.0](https://github.com/nuvla/kafka-notify/blob/main/CHANGELOG.md)

### Added

- Add Elasticsearch sniffer and Kafka init env vars to compose files.
- Add Data Records related BlackBox creation notifications via ksqldb

## [2.2.27] - 2022-01-17

This release update Nuvla components to following versions:

- [nuvla/api-server:5.23.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5230---2022-01-14)
- [nuvla/ui:2.27.1](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2271---2022-01-17)

## [2.2.26] - 2021-12-14

This release update Nuvla components to following versions:

- [nuvla/api-server:5.20.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5200---2021-12-09)
- [nuvla/ui:2.26.1](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2261---2021-11-17)

### Changed

- Enable compression for HTTP clients
- Use GHA for build status

## [2.2.25] - 2021-10-29

This release update Nuvla components to following versions:

- [nuvla/api-server:5.18.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5180---2021-10-29)
- [nuvla/ui:2.26.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2260---2021-10-29)
- [nuvla/job-engine:2.18.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2180---2021-10-29)

## [2.2.24] - 2021-10-13

This release update Nuvla components to following versions:

- [nuvla/api-server:5.16.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5160---2021-10-12)
- [nuvla/ui:2.24.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2240---2021-10-13)
- [nuvla/job-engine:2.16.3](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2163---2021-10-13)

## [2.2.23] - 2021-09-14

This release update Nuvla components to following versions:

- [nuvla/ui:2.22.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2220---2021-09-14)

## [2.2.22] - 2021-08-31

This release update Nuvla components to following versions:

- [nuvla/ui:2.21.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2210---2021-08-31)

## [2.2.21] - 2021-08-04

This release update nuvla components to following versions:

- [nuvla/api-server:5.15.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5150---2021-08-04)
- [nuvla/ui:2.20.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2200---2021-08-04)
- [nuvla/job-engine:2.16.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2160---2021-08-04)

### Changed

- Job distributor multi-threaded

## [2.2.20] - 2021-06-04

This release update nuvla components to following versions:

- [nuvla/api-server:5.14.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5140---2021-06-04)
- [nuvla/ui:2.19.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2190---2021-06-04)
- [nuvla/job-engine:2.15.2](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2152---2021-06-01)

### Added

- jobd-nuvlabox-cluster-cleanup

## [2.2.19] - 2021-05-06

This release update nuvla components to following versions:

- [nuvla/api-server:5.13.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5130---2021-05-06)
- [nuvla/ui:2.18.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2180---2021-05-06)
- [nuvla/job-engine:2.15.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2150---2021-05-06)

## [2.2.18] - 2021-04-28

This release update nuvla components to following versions:

- [nuvla/api-server:5.12.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5120---2021-04-09)
- [nuvla/ui:2.17.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2170---2021-04-09)
- [nuvla/job-engine:2.14.1](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2141---2021-04-09)

### Changed

- Monitoring disable alertmanager in the configuration
- Monitoring update Prometheus image to official repo
- Monitoring update Graphana image to official repo
- Upgrade nuvla/es:7.11.1.0

## [2.2.17] - 2021-03-08

This release update nuvla components to following versions:

- [nuvla/api-server:5.11.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5110---2021-03-08)
- [nuvla/ui:2.16.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2160---2021-03-08)
- [nuvla/kafka-notify:0.5.0](https://github.com/nuvla/kafka-notify/blob/main/CHANGELOG.md#050---2021-03-07)

### Changed

- Upgrade nuvla/es:7.7.1.0
- Streams: Temporary workaround for ES to Kafka connector - do not
  transform "resources.net-stats" due
  to [connector issue](https://github.com/DarioBalinzo/kafka-connect-elasticsearch-source/issues/38)
- Streams: ksql statements explode notification methods list per notification
  configuration at a later stage of the streaming pipeline; using the latest
  Confluent images including ksqlDB server 0.15.0.

## [2.2.16] - 2021-02-23

This release update nuvla components to following versions:

- [nuvla/kafka-notify:0.4.3](https://github.com/nuvla/kafka-notify/blob/main/CHANGELOG.md#043---2021-02-22)

### Changed

- ksqlDB queries using online-prev on NB telemetry for conditional alerting.
- Slack alert color and email image are green for NB online.

## [2.2.15] - 2021-02-22

This release update nuvla components to following versions:

- [nuvla/api-server:5.10.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#5100---2021-02-22)
- [nuvla/ui:2.15.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2150---2021-02-22)
- [nuvla/job-engine:2.13.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2130---2021-02-22)

### Added

- Deployment of streaming platform based on Kafka and used for notifications.

### Changed

- Job should use api-insecure because of http use for backend internal
  communication
- Fix: make streams treat NB on/off-line configs separately.
- Bump up kafka-notify versions (patch).
- online-prev attribute on NB status to support conditional alerting.

## [2.2.14] - 2021-02-09

This release update nuvla components to following versions:

- [nuvla/api-server:5.8.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#580---2021-02-09)
- [nuvla/ui:2.13.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2130---2021-02-09)
- [nuvla/job-engine:2.11.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2110---2021-02-09)

### Added

- Job distributor for setting nuvlabox status to offline

## [2.2.12] - 2020-12-10

This release update nuvla components to following versions:

- [nuvla/api-server:5.7.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#570---2020-12-10)
- [nuvla/ui:2.12.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2120---2020-12-10)
- [nuvla/job-engine:2.10.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#2100---2020-12-10)

### Changed

- Release tarball content fix

## [2.2.11] - 2020-12-07

This release update nuvla components to following versions:

- [nuvla/api-server:5.6.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#560---2020-12-07)
- [nuvla/ui:2.11.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2110---2020-12-07)
- [nuvla/job-engine:2.9.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#290---2020-12-07)

### Added

- BUILD - Support Github actions

## [2.2.10] - 2020-11-16

This release update nuvla components to following versions:

- [nuvla/api-server:5.5.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#550---2020-11-16)
- [nuvla/ui:2.10.1](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#2101---2020-11-16)
- [nuvla/job-engine:2.8.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#280---2020-11-16)

### Added

- Job distributor for populating and updating Nuvla DB of vulnerabilities

## [2.2.9] - 2020-10-28

This release update nuvla components to following versions:

- [nuvla/api-server:5.4.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#540---2020-10-28)
- [nuvla/ui:2.9.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#290---2020-10-28)

## [2.2.8] - 2020-10-12

This release update nuvla components to following versions:

- [nuvla/job-engine:2.7.1](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#271---2020-10-12)

## [2.2.7] - 2020-10-09

This release update nuvla components to following versions:

- [nuvla/api-server:5.3.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#530---2020-10-09)
- [nuvla/job-engine:2.7.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#270---2020-10-09)
- [nuvla/ui:2.8.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#280---2020-10-09)

### Changed

- Docker-machine version update v0.16.2 and ubuntu version updated to 18.04

## [2.2.6] - 2020-09-04

This release update nuvla components to following versions:

- [nuvla/api-server:5.2.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#520---2020-09-04)
- [nuvla/job-engine:2.6.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#260---2020-09-04)
- [nuvla/ui:2.7.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#270---2020-09-04)

## [2.2.5] - 2020-08-28

This release update nuvla components to following versions:

- [nuvla/job-engine:2.5.4](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#254---2020-08-28)

## [2.2.4] - 2020-08-03

This release update nuvla components to following versions:

- [nuvla/job-engine:2.5.3](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#253---2020-08-03)

## [2.2.3] - 2020-08-03

This release update nuvla components to following versions:

- [nuvla/job-engine:2.5.2](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#252---2020-08-03)

## [2.2.2] - 2020-08-03

This release update nuvla components to following versions:

- [nuvla/job-engine:2.5.1](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#251---2020-08-03)

## [2.2.1] - 2020-07-31

This release update nuvla components to following versions:

- [nuvla/api-server:5.1.0](https://github.com/nuvla/api-server/blob/master/CHANGELOG.md#510---2020-07-31)
- [nuvla/job-engine:2.5.0](https://github.com/nuvla/job-engine/blob/master/CHANGELOG.md#250---2020-07-31)
- [nuvla/ui:2.6.0](https://github.com/nuvla/ui/blob/master/CHANGELOG.md#260---2020-07-31)

### Changed

- Deployment state job was split into two for "new" and "old" deployments with
  10 and 60 seconds check intervals respectively. This was done to reduce
  unnecessary load on the server and remote COEs. This resulted in two services
  jobd-deployment-state_10 and jobd-deployment-state_60 in the compose files.
- Jobs cleanup executor no longer connects directly to ES DB. Updated test,
  demo and prod compose files by removing ES related param to executor.

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

Alpha support for Kubernetes added to all components. OpenVPN added for NuvlaBox
workflow.
UI got a lot of minors fixes and OCRE page got a PIE chart summary.

### Changed

- Update to nuvla/api:4.2.7
- Update to nuvla/job:2.3.9
- Update to nuvla/ui:2.4.7

## [2.1.7] - 2019-11-13

Api-server bulk delete extended for most resources. VPN support for NuvlaBox
resource was
added by adding credential templates and infrastructure service of subtype VPN.
NuvlaBox
resources name was simplified. This release also fix stale job caused by race
condition.
UI got support for NuvlaBox peripherals. Infrastructure page got a fix to
resolve
inconsistency between pages. Api page got bulk delete support. OCRE page visible
for users
in group/ocre-user. Appstore cards are now ordered by created time. Application
yaml
syntax is checked to show erros and hints messages.

### Changed

- Update to nuvla/api:4.2.6
- Update to nuvla/job:2.3.8
- Update to nuvla/ui:2.4.6

## [2.1.6] - 2019-10-10

Api-server support bulk delete for data-record resource. Session validity was
extended from
1 day to a 1 week. Group resource allow to set acl at creation time. Callbacks
for user
registration are now re-executable. UI allow infrastructure service group to
have more than
one subtype of service. Job-engine use python library (nuvla-api) which support
bulk delete.

### Changed

- Update to nuvla/api:4.2.5
- Update to nuvla/job:2.3.7
- Update to nuvla/ui:2.4.5

## [2.1.5] - 2019-09-18

Release fix in api-server cloud-entry-point base-uri when server port is being
forwarded and
allow users to delete deployment log. This release adds two new job distributors
for module
component and deployment service to create notifications. Docker job
distributors have been
renamed. UI got a new favicon and some dependencies updates and notification
better management.

### Changed

- Update to nuvla/api:4.2.4
- Update to nuvla/job:2.3.6
- Update to nuvla/ui:2.4.4

## [2.1.4] - 2019-09-04

Release allows users to see deployment logs and to get notifications when a new
version of Docker
image is available allowing him to update a module or a running component. A new
voucher report
resource has been added to the server. Job-Engine got some fixes around
deployment state and
NuvlaBox decommission. User can now give a name to Nuvlabox at creation time and
all sub-resources
will get this name to facilitate the identification of the box. UI got some
fixes in styling and
raw textarea allow now users to search and to see the search result highlighted.

### Changed

- Update to nuvla/api:4.2.3
- Update to nuvla/job:2.3.5
- Update to nuvla/ui:2.4.3

## [2.1.3] - 2019-08-07

Release add nuvlabox-peripheral resource and updated the version numbers (v1)
for the other
nuvlabox resources. And other fixes. UI got a refactored sidebar and footer and
support external
authentication redirection. Login modal visible when needed. Job-Engine got some
fixes.
Nuvlabox decommission action delete linked nuvlabox-peripheral.

### Changed

- Update to nuvla/api:4.2.2
- Update to nuvla/job:2.3.4
- Update to nuvla/ui:2.4.2

## [2.1.2] - 2019-07-29

Release resolve deployment related issues job-engine and ui side.
The api fix some issues related to external authentication and resource-metadata
related updates.

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
