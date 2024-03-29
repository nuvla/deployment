----------------------------------------------------
--
-- notifications configuration table
-- from notification-method topic
CREATE TABLE NOTIFICATION_METHOD_T
(id VARCHAR PRIMARY KEY,
  method VARCHAR,
  destination VARCHAR,
  acl STRUCT<
    owners ARRAY<VARCHAR>
  >
)
WITH (KAFKA_TOPIC='notification-method',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE STREAM NOTIFICATIONS_S (
    id VARCHAR KEY,
    subs_id VARCHAR,
    subs_name VARCHAR,
    method_ids ARRAY<VARCHAR>,
    subs_description VARCHAR,
    resource_uri VARCHAR,
    resource_name VARCHAR,
    resource_description VARCHAR,
    metric VARCHAR,
    condition VARCHAR,
    condition_value VARCHAR,
    "VALUE" VARCHAR,
    timestamp VARCHAR,
    recovery BOOLEAN
) WITH (
    KAFKA_TOPIC='NOTIFICATIONS_S',
    PARTITIONS=3,
    REPLICAS=3,
    VALUE_FORMAT = 'JSON');

CREATE STREAM NOTIFICATIONS_INDIVIDUAL_S (
    id VARCHAR KEY,
    subs_id VARCHAR,
    subs_name VARCHAR,
    method_id VARCHAR,
    subs_description VARCHAR,
    resource_uri VARCHAR,
    resource_name VARCHAR,
    resource_description VARCHAR,
    metric VARCHAR,
    condition VARCHAR,
    condition_value VARCHAR,
    "VALUE" VARCHAR,
    timestamp VARCHAR,
    recovery BOOLEAN
) WITH (
    KAFKA_TOPIC='NOTIFICATIONS_INDIVIDUAL_S',
    PARTITIONS=3,
    REPLICAS=3,
    VALUE_FORMAT = 'JSON');

INSERT INTO NOTIFICATIONS_INDIVIDUAL_S
SELECT
    id,
    subs_id,
    subs_name,
    EXPLODE(method_ids) as method_id,
    subs_description,
    resource_uri,
    resource_name,
    resource_description,
    metric,
    condition,
    condition_value,
    "VALUE",
    timestamp,
    recovery
FROM NOTIFICATIONS_S
EMIT CHANGES;

--
-- email notifications stream
-- keyed by subscription ID
CREATE STREAM NOTIFICATIONS_EMAIL_S (
    id VARCHAR KEY,
    method VARCHAR,
    destination VARCHAR,
    subs_id VARCHAR,
    subs_name VARCHAR,
    subs_description VARCHAR,
    resource_uri VARCHAR,
    resource_name VARCHAR,
    resource_description VARCHAR,
    metric VARCHAR,
    condition VARCHAR,
    condition_value VARCHAR,
    "VALUE" VARCHAR,
    timestamp VARCHAR,
    recovery BOOLEAN
) WITH (
    KAFKA_TOPIC='NOTIFICATIONS_EMAIL_S',
    PARTITIONS=3,
    REPLICAS=3,
    VALUE_FORMAT = 'JSON');

INSERT INTO NOTIFICATIONS_EMAIL_S
SELECT
     notif.id as id,
     notif.method as method,
     notif.destination as destination,
     ni.subs_id,
     ni.subs_name,
     ni.subs_description,
     ni.resource_uri,
     ni.resource_name,
     ni.resource_description,
     ni.metric,
     ni.condition,
     ni.condition_value,
     ni."VALUE",
     ni.timestamp,
     ni.recovery
FROM NOTIFICATIONS_INDIVIDUAL_S AS ni
JOIN NOTIFICATION_METHOD_T AS notif ON notif.id = ni.method_id
WHERE LCASE(notif.method) = 'email'
EMIT CHANGES;

--
-- slack notifications stream
-- keyed by subscription ID
CREATE STREAM NOTIFICATIONS_SLACK_S (
    id VARCHAR KEY,
    method VARCHAR,
    destination VARCHAR,
    subs_id VARCHAR,
    subs_name VARCHAR,
    subs_description VARCHAR,
    resource_uri VARCHAR,
    resource_name VARCHAR,
    resource_description VARCHAR,
    metric VARCHAR,
    condition VARCHAR,
    condition_value VARCHAR,
    "VALUE" VARCHAR,
    timestamp VARCHAR,
    recovery BOOLEAN
) WITH (
    KAFKA_TOPIC='NOTIFICATIONS_SLACK_S',
    PARTITIONS=3,
    REPLICAS=3,
    VALUE_FORMAT = 'JSON');


INSERT INTO NOTIFICATIONS_SLACK_S
SELECT
     notif.id as id,
     notif.method as method,
     notif.destination as destination,
     ni.subs_id,
     ni.subs_name,
     ni.subs_description,
     ni.resource_uri,
     ni.resource_name,
     ni.resource_description,
     ni.metric,
     ni.condition,
     ni.condition_value,
     ni."VALUE",
     ni.timestamp,
     ni.recovery
FROM NOTIFICATIONS_INDIVIDUAL_S AS ni
JOIN NOTIFICATION_METHOD_T AS notif ON notif.id = ni.method_id
WHERE LCASE(notif.method) = 'slack'
EMIT CHANGES;

--
-- stream with all individual subscriptions
CREATE STREAM SUBSCRIPTION_S
(id VARCHAR KEY,
  name VARCHAR,
  description VARCHAR,
  enabled BOOLEAN,
  acl STRUCT<
    owners ARRAY<VARCHAR>
  >,
  category VARCHAR,
  "method-ids" ARRAY<VARCHAR>,
  "resource-id" VARCHAR,
  "resource-kind" VARCHAR,
  criteria STRUCT<kind VARCHAR,
                  metric VARCHAR,
                  condition VARCHAR,
                  "value" VARCHAR,
                  "window" BIGINT>
)
WITH (KAFKA_TOPIC='subscription',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE TABLE SUBSCRIPTION_T
(id VARCHAR PRIMARY KEY,
  name VARCHAR,
  description VARCHAR,
  enabled BOOLEAN,
  acl STRUCT<
    owners ARRAY<VARCHAR>
  >,
  category VARCHAR,
  "method-ids" ARRAY<VARCHAR>,
  "resource-id" VARCHAR,
  "resource-kind" VARCHAR,
  criteria STRUCT<kind VARCHAR,
                  metric VARCHAR,
                  condition VARCHAR,
                  "value" VARCHAR,
                  "window" BIGINT>
)
WITH (KAFKA_TOPIC='subscription',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

--
-- stream with subscription configurations
CREATE STREAM SUBSCRIPTION_CONFIG_S
(id VARCHAR KEY,
  name VARCHAR,
  description VARCHAR,
  enabled BOOLEAN,
  acl STRUCT<
    owners ARRAY<VARCHAR>
  >,
  category VARCHAR,
  "method-ids" ARRAY<VARCHAR>,
  "resource-id" VARCHAR,
  "resource-kind" VARCHAR,
  criteria STRUCT<kind VARCHAR,
                  metric VARCHAR,
                  condition VARCHAR,
                  "value" VARCHAR,
                  "window" BIGINT>
)
WITH (KAFKA_TOPIC='subscription-config',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

--
-- stream of events
CREATE STREAM EVENT_S
    (id VARCHAR,
     category VARCHAR,
     content STRUCT<
         resource STRUCT<
             href VARCHAR
         >,
         state VARCHAR
     >,
     severity VARCHAR,
     timestamp VARCHAR,
     tags ARRAY<VARCHAR>,
     acl STRUCT<
          owners ARRAY<VARCHAR>
     >
    )
    WITH (KAFKA_TOPIC='event',
          PARTITIONS=3,
          REPLICAS=3,
          VALUE_FORMAT='JSON');
---    WITH (KAFKA_TOPIC='es_nuvla-event',

------------------------------------------------------
-- BlackBox creation.

CREATE STREAM SUBS_CONFIG_BLACKBOX_EVENT_S AS
SELECT
    s.acl->owners[1] as owner,
    *
FROM SUBSCRIPTION_CONFIG_S AS s
WHERE "resource-kind" = 'event'
    AND criteria->"value" = 'application/blackbox'
    AND criteria->metric = 'tag'
    AND criteria->kind = 'string'
    AND criteria->condition = 'is'
EMIT CHANGES;

-- repartitioned by owner
CREATE STREAM SUBS_CONFIG_BLACKBOX_EVENT_BY_OWNER_S AS
SELECT
    s.owner as id,
    s.id as subs_id,
    s.name as name,
    s.description as description,
    s.enabled as enabled,
    s."method-ids" as "method-ids",
    s.criteria as criteria
FROM SUBS_CONFIG_BLACKBOX_EVENT_S AS s
PARTITION BY s.owner;

CREATE TABLE SUBS_CONFIG_BLACKBOX_EVENT_BY_OWNER_T (
  id VARCHAR PRIMARY KEY,
  subs_id VARCHAR,
  name VARCHAR,
  description VARCHAR,
  enabled BOOLEAN,
  "method-ids" ARRAY<VARCHAR>,
  criteria STRUCT<kind VARCHAR,
                  metric VARCHAR,
                  condition VARCHAR,
                  "value" VARCHAR,
                  "window" BIGINT>
) WITH (KAFKA_TOPIC='SUBS_CONFIG_BLACKBOX_EVENT_BY_OWNER_S',
      PARTITIONS=1,
      REPLICAS=1,
      VALUE_FORMAT='JSON');


CREATE STREAM EVENT_BB_CREATED_S (
     id VARCHAR,
     owner VARCHAR,
     href VARCHAR,
     state VARCHAR,
     timestamp VARCHAR
) WITH (KAFKA_TOPIC='EVENT_BB_CREATED_S',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

INSERT INTO EVENT_BB_CREATED_S
SELECT
    e.id as id,
    e.acl->owners[1] as owner,
    e.content->resource->href as href,
    e.content->state as state,
    e.timestamp as timestamp
FROM EVENT_S as e
WHERE e.category = 'user'
    AND ARRAY_CONTAINS(e.tags, 'application/blackbox')
    AND e.content->resource->href LIKE 'data-record/%'
    AND e.content->state = 'created'
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_S
SELECT
     subs_t.id as id,
     AS_VALUE(subs_t.subs_id) as subs_id,
     subs_t.name as subs_name,
     subs_t."method-ids" as method_ids,
     subs_t.description as subs_description,
     CONCAT('api/', bbe.href) as resource_uri,
     'blackbox' as resource_name,
     'blackbox' as resource_description,
     'content-type' as metric,
     subs_t.criteria->condition as condition,
     CAST(subs_t.criteria->"value" as VARCHAR) as condition_value,
     'true' as "VALUE",
     CONCAT(SPLIT(bbe.timestamp, '.')[1], 'Z') as timestamp,
     true as recovery
FROM EVENT_BB_CREATED_S AS bbe
JOIN SUBS_CONFIG_BLACKBOX_EVENT_BY_OWNER_T AS subs_t ON bbe.owner = subs_t.id
EMIT CHANGES;

---------------------------------
-- NuvlaBox.

CREATE STREAM NUVLABOX_S
(updated VARCHAR,
  id VARCHAR,
  name VARCHAR,
  description VARCHAR,
  acl STRUCT<
    "owners" ARRAY<VARCHAR>,
    "view-data" ARRAY<VARCHAR>
  >
)
WITH (KAFKA_TOPIC='es_nuvla-nuvlabox',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE STREAM NUVLABOX_REKYED_S AS
   SELECT
       s.id as id,
       s.name as name,
       s.description as description,
       s.acl as acl
   FROM NUVLABOX_S AS s
   PARTITION BY s.id;

CREATE TABLE NUVLABOX_T
(id VARCHAR PRIMARY KEY,
  name VARCHAR,
  description VARCHAR,
  acl STRUCT<
    "owners" ARRAY<VARCHAR>,
    "view-data" ARRAY<VARCHAR>
  >
)
WITH (KAFKA_TOPIC='NUVLABOX_REKYED_S',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

---------------------------------
-- Telemetry.

--
-- NB telemetry stream
-- from es_nuvla-nuvlabox-status topic
-- NB! 'load' is a registered KW in ksqlDB and needs to be quoted.
CREATE STREAM NB_TELEM_RESOURCES_S (
   id VARCHAR,
   parent VARCHAR,
   online BOOLEAN,
   "online-prev" BOOLEAN,
   resources STRUCT<cpu STRUCT<"load" DOUBLE, "capacity" BIGINT, "topic" VARCHAR>,
                    ram STRUCT<"used" BIGINT, "capacity" BIGINT, "topic" VARCHAR>,
                    disks ARRAY<STRUCT<"used" BIGINT, "capacity" BIGINT, "device" VARCHAR>>>,
   "resources-prev" STRUCT<cpu STRUCT<"load" DOUBLE, "capacity" BIGINT, "topic" VARCHAR>,
                           ram STRUCT<"used" BIGINT, "capacity" BIGINT, "topic" VARCHAR>,
                           disks ARRAY<STRUCT<"used" BIGINT, "capacity" BIGINT, "device" VARCHAR>>>,
   "current-time" VARCHAR,
   acl STRUCT<"owners" ARRAY<VARCHAR>,
              "view-data" ARRAY<VARCHAR>
   >)
WITH (KAFKA_TOPIC='es_nuvla-nuvlabox-status',
   PARTITIONS=3,
   REPLICAS=3,
   VALUE_FORMAT='JSON');

-- re-key by parent which is NB ID
CREATE STREAM NB_TELEM_RESOURCES_REKYED_S (
   id VARCHAR KEY,
   name VARCHAR,
   description VARCHAR,
   online BOOLEAN,
   online_prev BOOLEAN,
   resources STRUCT<cpu STRUCT<"load" DOUBLE, "capacity" BIGINT, "topic" VARCHAR>,
                    ram STRUCT<"used" BIGINT, "capacity" BIGINT, "topic" VARCHAR>,
                    disks ARRAY<STRUCT<"used" BIGINT, "capacity" BIGINT, "device" VARCHAR>>>,
   resources_cpu_load_pers DOUBLE,
   resources_ram_used_pers DOUBLE,
   resources_disk1_used_pers DOUBLE,
   resources_prev STRUCT<cpu STRUCT<"load" DOUBLE, "capacity" BIGINT, "topic" VARCHAR>,
                           ram STRUCT<"used" BIGINT, "capacity" BIGINT, "topic" VARCHAR>,
                           disks ARRAY<STRUCT<"used" BIGINT, "capacity" BIGINT, "device" VARCHAR>>>,
   resources_prev_cpu_load_pers DOUBLE,
   resources_prev_ram_used_pers DOUBLE,
   resources_prev_disk1_used_pers DOUBLE,
   timestamp VARCHAR,
   acl STRUCT<"owners" ARRAY<VARCHAR>,
              "view-data" ARRAY<VARCHAR>
   >
) WITH (KAFKA_TOPIC='NB_TELEM_RESOURCES_REKYED_S',
   PARTITIONS=3,
   REPLICAS=3,
   VALUE_FORMAT='JSON');

INSERT INTO NB_TELEM_RESOURCES_REKYED_S
SELECT
    parent as id,
    nb.name as name,
    nb.description as description,
    online,
    "online-prev" as online_prev,
    resources,
    CAST((resources->cpu->"load" * 100) / resources->cpu->"capacity" AS DOUBLE) as resources_cpu_load_pers,
    CAST((resources->ram->"used" * 100) / resources->ram->"capacity" AS DOUBLE) as resources_ram_used_pers,
    CAST((resources->disks[1]->"used" * 100) / resources->disks[1]->"capacity" AS DOUBLE) as resources_disk1_used_pers,
    "resources-prev" as resources_prev,
    CAST(("resources-prev"->cpu->"load" * 100) / "resources-prev"->cpu->"capacity" AS DOUBLE) as resources_prev_cpu_load_pers,
    CAST(("resources-prev"->ram->"used" * 100) / "resources-prev"->ram->"capacity" AS DOUBLE) as resources_prev_ram_used_pers,
    CAST(("resources-prev"->disks[1]->"used" * 100) / "resources-prev"->disks[1]->"capacity" AS DOUBLE) as resources_prev_disk1_used_pers,
    "current-time" as timestamp,
    tlm.acl as acl
FROM NB_TELEM_RESOURCES_S as tlm
JOIN NUVLABOX_T as nb ON tlm.parent = nb.id
PARTITION BY parent
EMIT CHANGES;

----------------------------------
--
-- Subscription to NB state change
CREATE TABLE SUBS_NB_STATE_T (
 "resource-id" VARCHAR PRIMARY KEY,
 subs_id VARCHAR,
 owner VARCHAR
) WITH (KAFKA_TOPIC='SUBS_NB_STATE_T',
   PARTITIONS=3,
   REPLICAS=3,
   VALUE_FORMAT='JSON');

CREATE OR REPLACE TABLE SUBS_NB_STATE_T
AS SELECT
    "resource-id",
    LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
    LATEST_BY_OFFSET(acl->owners[1]) AS owner
FROM SUBSCRIPTION_S
WHERE
    "resource-kind" = 'nuvlabox'
    AND criteria->kind = 'boolean'
    AND criteria->metric = 'state'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_S
SELECT
    subs.subs_id as id,
    AS_VALUE(subs.subs_id) as subs_id,
    subs_t.name as subs_name,
    subs_t."method-ids" as method_ids,
    subs_t.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB online' as metric,
    CAST((nb_tlm.online = true AND nb_tlm.online_prev = false) as VARCHAR) as condition,
    '' as condition_value,
    '' as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.online = true AND nb_tlm.online_prev = false) as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_STATE_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN SUBSCRIPTION_T AS subs_t ON subs_t.id = subs.subs_id
WHERE
    subs_t.enabled = true
    AND subs_t.category = 'notification'
    AND subs_t."resource-kind" = 'nuvlabox'
    AND (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND ((nb_tlm.online = true AND nb_tlm.online_prev = false)
          OR (nb_tlm.online = false AND nb_tlm.online_prev = true))
EMIT CHANGES;

--------------------------------------
--
-- Subscription to NB load > threshold
CREATE TABLE SUBS_NB_LOAD_ABOVE_T (
 "resource-id" VARCHAR PRIMARY KEY,
 subs_id VARCHAR,
 owner VARCHAR
) WITH (KAFKA_TOPIC='SUBS_NB_LOAD_ABOVE_T',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE OR REPLACE TABLE SUBS_NB_LOAD_ABOVE_T
AS SELECT
    "resource-id",
    LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
    LATEST_BY_OFFSET(acl->owners[1]) AS owner
FROM SUBSCRIPTION_S
WHERE
    "resource-kind" = 'nuvlabox'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'load'
    AND criteria->condition = '>'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_S
SELECT
    subs.subs_id as id,
    AS_VALUE(subs.subs_id) as subs_id,
    subs_t.name as subs_name,
    subs_t."method-ids" as method_ids,
    subs_t.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB load %' as metric,
    subs_t.criteria->condition as condition,
    CAST(subs_t.criteria->"value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_cpu_load_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->cpu->"load" > nb_tlm.resources->cpu->"load") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_LOAD_ABOVE_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN SUBSCRIPTION_T AS subs_t ON subs_t.id = subs.subs_id
WHERE
    subs_t.enabled = true
    AND subs_t.category = 'notification'
    AND subs_t."resource-kind" = 'nuvlabox'
    AND (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND ((nb_tlm.resources_prev_cpu_load_pers <= CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_cpu_load_pers > CAST(subs_t.criteria->"value" AS INTEGER))
        OR
        (nb_tlm.resources_cpu_load_pers < CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_prev_cpu_load_pers >= CAST(subs_t.criteria->"value" AS INTEGER)))
EMIT CHANGES;

--------------------------------------
--
-- Subscription to NB load < threshold
CREATE TABLE SUBS_NB_LOAD_BELOW_T (
  "resource-id" VARCHAR PRIMARY KEY,
  subs_id VARCHAR,
  owner VARCHAR
) WITH (KAFKA_TOPIC='SUBS_NB_LOAD_BELOW_T',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE OR REPLACE TABLE SUBS_NB_LOAD_BELOW_T
AS SELECT
    "resource-id",
    LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
    LATEST_BY_OFFSET(acl->owners[1]) AS owner
FROM SUBSCRIPTION_S
WHERE
    "resource-kind" = 'nuvlabox'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'load'
    AND criteria->condition = '<'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_S
SELECT
    subs.subs_id as id,
    AS_VALUE(subs.subs_id) as subs_id,
    subs_t.name as subs_name,
    subs_t."method-ids" as method_ids,
    subs_t.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB load %' as metric,
    subs_t.criteria->condition as condition,
    CAST(subs_t.criteria->"value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_cpu_load_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->cpu->"load" < nb_tlm.resources->cpu->"load") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_LOAD_BELOW_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN SUBSCRIPTION_T AS subs_t ON subs_t.id = subs.subs_id
WHERE
    subs_t.enabled = true
    AND subs_t.category = 'notification'
    AND subs_t."resource-kind" = 'nuvlabox'
    AND (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND ((nb_tlm.resources_prev_cpu_load_pers >= CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_cpu_load_pers < CAST(subs_t.criteria->"value" AS INTEGER))
        OR
        (nb_tlm.resources_cpu_load_pers > CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_prev_cpu_load_pers <= CAST(subs_t.criteria->"value" AS INTEGER)))
EMIT CHANGES;

-------------------------------------
--
-- Subscription to NB ram > threshold
CREATE TABLE SUBS_NB_RAM_ABOVE_T (
  "resource-id" VARCHAR PRIMARY KEY,
  subs_id VARCHAR,
  owner VARCHAR
) WITH (KAFKA_TOPIC='SUBS_NB_RAM_ABOVE_T',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE OR REPLACE TABLE SUBS_NB_RAM_ABOVE_T
AS SELECT
    "resource-id",
    LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
    LATEST_BY_OFFSET(acl->owners[1]) AS owner
FROM SUBSCRIPTION_S
WHERE
    "resource-kind" = 'nuvlabox'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'ram'
    AND criteria->condition = '>'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_S
SELECT
    subs.subs_id as id,
    AS_VALUE(subs.subs_id) as subs_id,
    subs_t.name as subs_name,
    subs_t."method-ids" as method_ids,
    subs_t.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB ram %' as metric,
    subs_t.criteria->condition as condition,
    CAST(subs_t.criteria->"value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_ram_used_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->ram->"used" > nb_tlm.resources->ram->"used") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_RAM_ABOVE_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN SUBSCRIPTION_T AS subs_t ON subs_t.id = subs.subs_id
WHERE
    subs_t.enabled = true
    AND subs_t.category = 'notification'
    AND subs_t."resource-kind" = 'nuvlabox'
    AND (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND ((nb_tlm.resources_prev_ram_used_pers <= CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_ram_used_pers > CAST(subs_t.criteria->"value" AS INTEGER))
        OR
        (nb_tlm.resources_ram_used_pers < CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_prev_ram_used_pers >= CAST(subs_t.criteria->"value" AS INTEGER)))
EMIT CHANGES;

-------------------------------------
--
-- Subscription to NB ram < threshold
CREATE TABLE SUBS_NB_RAM_BELOW_T (
 "resource-id" VARCHAR PRIMARY KEY,
 subs_id VARCHAR,
 owner VARCHAR
) WITH (KAFKA_TOPIC='SUBS_NB_RAM_BELOW_T',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE OR REPLACE TABLE SUBS_NB_RAM_BELOW_T
AS SELECT
    "resource-id",
    LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
    LATEST_BY_OFFSET(acl->owners[1]) AS owner
FROM SUBSCRIPTION_S
WHERE
    "resource-kind" = 'nuvlabox'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'ram'
    AND criteria->condition = '<'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_S
SELECT
    subs.subs_id as id,
    AS_VALUE(subs.subs_id) as subs_id,
    subs_t.name as subs_name,
    subs_t."method-ids" as method_ids,
    subs_t.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB ram %' as metric,
    subs_t.criteria->condition as condition,
    CAST(subs_t.criteria->"value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_ram_used_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->ram->"used" < nb_tlm.resources->ram->"used") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_RAM_BELOW_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN SUBSCRIPTION_T AS subs_t ON subs_t.id = subs.subs_id
WHERE
    subs_t.enabled = true
    AND subs_t.category = 'notification'
    AND subs_t."resource-kind" = 'nuvlabox'
    AND (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND ((nb_tlm.resources_prev_ram_used_pers >= CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_ram_used_pers < CAST(subs_t.criteria->"value" AS INTEGER))
        OR
        (nb_tlm.resources_ram_used_pers > CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_prev_ram_used_pers <= CAST(subs_t.criteria->"value" AS INTEGER)))
EMIT CHANGES;

-------------------------------------
--
-- Subscription to NB disk > threshold
CREATE TABLE SUBS_NB_DISK_ABOVE_T (
 "resource-id" VARCHAR PRIMARY KEY,
 subs_id VARCHAR,
 owner VARCHAR
) WITH (KAFKA_TOPIC='SUBS_NB_DISK_ABOVE_T',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE OR REPLACE TABLE SUBS_NB_DISK_ABOVE_T
AS SELECT
    "resource-id",
    LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
    LATEST_BY_OFFSET(acl->owners[1]) AS owner
FROM SUBSCRIPTION_S
WHERE
    "resource-kind" = 'nuvlabox'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'disk'
    AND criteria->condition = '>'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_S
SELECT
    subs.subs_id as id,
    AS_VALUE(subs.subs_id) as subs_id,
    subs_t.name as subs_name,
    subs_t."method-ids" as method_ids,
    subs_t.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB disk %' as metric,
    subs_t.criteria->condition as condition,
    CAST(subs_t.criteria->"value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_disk1_used_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->disks[1]->"used" > nb_tlm.resources->disks[1]->"used") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_DISK_ABOVE_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN SUBSCRIPTION_T AS subs_t ON subs_t.id = subs.subs_id
WHERE
    subs_t.enabled = true
    AND subs_t.category = 'notification'
    AND subs_t."resource-kind" = 'nuvlabox'
    AND (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND ((nb_tlm.resources_prev_disk1_used_pers <= CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_disk1_used_pers > CAST(subs_t.criteria->"value" AS INTEGER))
        OR
        (nb_tlm.resources_disk1_used_pers < CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_prev_disk1_used_pers >= CAST(subs_t.criteria->"value" AS INTEGER)))
EMIT CHANGES;

--------------------------------------
--
-- Subscription to NB disk < threshold
CREATE TABLE SUBS_NB_DISK_BELOW_T (
  "resource-id" VARCHAR PRIMARY KEY,
  subs_id VARCHAR,
  owner VARCHAR
) WITH (KAFKA_TOPIC='SUBS_NB_DISK_BELOW_T',
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

CREATE OR REPLACE TABLE SUBS_NB_DISK_BELOW_T
AS SELECT
    "resource-id",
    LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
    LATEST_BY_OFFSET(acl->owners[1]) AS owner
FROM SUBSCRIPTION_S
WHERE
    "resource-kind" = 'nuvlabox'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'disk'
    AND criteria->condition = '<'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_S
SELECT
    subs.subs_id as id,
    AS_VALUE(subs.subs_id) as subs_id,
    subs_t.name as subs_name,
    subs_t."method-ids" as method_ids,
    subs_t.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB disk %' as metric,
    subs_t.criteria->condition as condition,
    CAST(subs_t.criteria->"value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_disk1_used_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->disks[1]->"used" < nb_tlm.resources->disks[1]->"used") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_DISK_BELOW_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN SUBSCRIPTION_T AS subs_t ON subs_t.id = subs.subs_id
WHERE
    subs_t.enabled = true
    AND subs_t.category = 'notification'
    AND subs_t."resource-kind" = 'nuvlabox'
    AND (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND ((nb_tlm.resources_prev_disk1_used_pers >= CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_disk1_used_pers < CAST(subs_t.criteria->"value" AS INTEGER))
        OR
        (nb_tlm.resources_disk1_used_pers > CAST(subs_t.criteria->"value" AS INTEGER)
           AND nb_tlm.resources_prev_disk1_used_pers <= CAST(subs_t.criteria->"value" AS INTEGER)))
EMIT CHANGES;
