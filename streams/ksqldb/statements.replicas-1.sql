--
-- NB! Force PARTITIONS=1 due to https://github.com/DarioBalinzo/kafka-connect-elasticsearch-source/issues/33

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
      PARTITIONS=1,
      REPLICAS=1,
      VALUE_FORMAT='JSON');

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
    PARTITIONS=1,
    REPLICAS=1,
    VALUE_FORMAT = 'JSON');

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
    PARTITIONS=1,
    REPLICAS=1,
    VALUE_FORMAT = 'JSON');

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
  "method-id" VARCHAR,
  "resource-id" VARCHAR,
  "resource-kind" VARCHAR,
  criteria STRUCT<kind VARCHAR,
                  metric VARCHAR,
                  condition VARCHAR,
                  "value" VARCHAR,
                  "window" BIGINT>
)
WITH (KAFKA_TOPIC='subscription',
      PARTITIONS=1,
      REPLICAS=1,
      VALUE_FORMAT='JSON');

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
      PARTITIONS=1,
      REPLICAS=1,
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
      PARTITIONS=1,
      REPLICAS=1,
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
   PARTITIONS=1,
   REPLICAS=1,
   VALUE_FORMAT='JSON');

-- re-key by parent which is NB ID
-- due to: only T-to-T join on foreign key is supported.
CREATE STREAM NB_TELEM_RESOURCES_REKYED_S AS
SELECT
    parent as id,
    nb.name as name,
    nb.description as description,
    online,
    "online-prev" as online_prev,
    resources,
    (resources->cpu->"load" * 100) / resources->cpu->"capacity" as resources_cpu_load_pers,
    (resources->ram->"used" * 100) / resources->ram->"capacity" as resources_ram_used_pers,
    (resources->disks[1]->"used" * 100) / resources->disks[1]->"capacity" as resources_disk1_used_pers,
    "resources-prev" as resources_prev,
    ("resources-prev"->cpu->"load" * 100) / "resources-prev"->cpu->"capacity" as resources_prev_cpu_load_pers,
    ("resources-prev"->ram->"used" * 100) / "resources-prev"->ram->"capacity" as resources_prev_ram_used_pers,
    ("resources-prev"->disks[1]->"used" * 100) / "resources-prev"->disks[1]->"capacity" as resources_prev_disk1_used_pers,
    "current-time" as timestamp,
    tlm.acl as acl
FROM NB_TELEM_RESOURCES_S as tlm
JOIN NUVLABOX_T as nb ON tlm.parent = nb.id
PARTITION BY parent
EMIT CHANGES;
