-- noinspection SqlDialectInspectionForFile

-- noinspection SqlNoDataSourceInspectionForFile

--
-- NB! Force PARTITIONS=1 due to https://github.com/DarioBalinzo/kafka-connect-elasticsearch-source/issues/33

----------------------------------------------------
--
-- notifications configuration table
-- from notification-method topic
CREATE TABLE NOTIFICATION_METHOD_T (
    id VARCHAR PRIMARY KEY,
    method VARCHAR,
    destination VARCHAR,
    acl STRUCT<
      owners ARRAY<VARCHAR>
    >
) WITH (KAFKA_TOPIC='notification-method',
        PARTITIONS=1,
        REPLICAS=1,
        VALUE_FORMAT='JSON');

CREATE STREAM NOTIFICATIONS_S (
    id VARCHAR KEY,
    subs_id VARCHAR,
    subs_name VARCHAR,
    method_ids ARRAY<VARCHAR>,
    subs_description VARCHAR,
    template VARCHAR,
    trigger_resource_path VARCHAR,
    trigger_resource_name VARCHAR,
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
    PARTITIONS=1,
    REPLICAS=1,
    VALUE_FORMAT = 'JSON');

CREATE STREAM NOTIFICATIONS_INDIVIDUAL_S AS
SELECT
    id,
    subs_id,
    subs_name,
    EXPLODE(method_ids) as method_id,
    subs_description,
    template,
    trigger_resource_path,
    trigger_resource_name,
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
    template VARCHAR,
    trigger_resource_path VARCHAR,
    trigger_resource_name VARCHAR,
    resource_uri VARCHAR,
    resource_name VARCHAR,
    resource_description VARCHAR,
    metric VARCHAR,
    condition VARCHAR,
    condition_value VARCHAR,
    "VALUE" VARCHAR,
    timestamp VARCHAR,
    recovery BOOLEAN
) WITH (KAFKA_TOPIC='NOTIFICATIONS_EMAIL_S',
        PARTITIONS=1,
        REPLICAS=1,
        VALUE_FORMAT = 'JSON');

INSERT INTO NOTIFICATIONS_EMAIL_S
SELECT
    notif.id as id,
    notif.method as method,
    notif.destination as destination,
    ni.subs_id,
    ni.subs_name,
    ni.subs_description,
    ni.template,
    ni.trigger_resource_path,
    ni.trigger_resource_name,
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
    template VARCHAR,
    trigger_resource_path VARCHAR,
    trigger_resource_name VARCHAR,
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


INSERT INTO NOTIFICATIONS_SLACK_S
SELECT
    notif.id as id,
    notif.method as method,
    notif.destination as destination,
    ni.subs_id,
    ni.subs_name,
    ni.subs_description,
    ni.template,
    ni.trigger_resource_path,
    ni.trigger_resource_name,
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
-- mqtt notifications stream
-- keyed by subscription ID
CREATE STREAM NOTIFICATIONS_MQTT_S (
    id VARCHAR KEY,
    method VARCHAR,
    destination VARCHAR,
    subs_id VARCHAR,
    subs_name VARCHAR,
    subs_description VARCHAR,
    template VARCHAR,
    trigger_resource_path VARCHAR,
    trigger_resource_name VARCHAR,
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
    KAFKA_TOPIC='NOTIFICATIONS_MQTT_S',
    PARTITIONS=1,
    REPLICAS=1,
    VALUE_FORMAT = 'JSON');


INSERT INTO NOTIFICATIONS_MQTT_S
SELECT
    notif.id as id,
    notif.method as method,
    notif.destination as destination,
    ni.subs_id,
    ni.subs_name,
    ni.subs_description,
    ni.template,
    ni.trigger_resource_path,
    ni.trigger_resource_name,
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
WHERE LCASE(notif.method) = 'mqtt'
EMIT CHANGES;

---------------------------------
--- NuvlaBox

CREATE TABLE NUVLAEDGE_T (
    id VARCHAR PRIMARY KEY,
    name VARCHAR,
    description VARCHAR,
    tags ARRAY<VARCHAR>,
    acl STRUCT<
      "owners" ARRAY<VARCHAR>,
      "view-data" ARRAY<VARCHAR>
    >
) WITH (KAFKA_TOPIC='nuvlabox',
      PARTITIONS=1,
      REPLICAS=1,
      VALUE_FORMAT='JSON');

---------------------------------
--- Telemetry

---
--- NB telemetry stream
--- from nuvlabox-status topic
--- NB! 'load' is a registered KW in ksqlDB and needs to be quoted.
CREATE STREAM NUVLAEDGE_STATUS_S (
   id VARCHAR,
   parent VARCHAR,
   online BOOLEAN,
   "online-prev" BOOLEAN,
   network STRUCT<"default-gw" VARCHAR>,
   resources STRUCT<cpu STRUCT<"load" DOUBLE, "capacity" BIGINT>,
                    ram STRUCT<"used" BIGINT, "capacity" BIGINT>,
                    "net-stats" ARRAY<STRUCT<"interface" VARCHAR, "bytes-transmitted" BIGINT, "bytes-received" BIGINT>>,
                    disks ARRAY<STRUCT<"used" BIGINT, "capacity" BIGINT, "device" VARCHAR>>>,
   "resources-prev" STRUCT<cpu STRUCT<"load" DOUBLE, "capacity" BIGINT>,
                           ram STRUCT<"used" BIGINT, "capacity" BIGINT>,
                           "net-stats" ARRAY<STRUCT<"interface" VARCHAR, "bytes-transmitted" BIGINT, "bytes-received" BIGINT>>,
                           disks ARRAY<STRUCT<"used" BIGINT, "capacity" BIGINT, "device" VARCHAR>>>,
   "current-time" VARCHAR,
   updated VARCHAR,
   "nuvlabox-engine-version" VARCHAR,
   acl STRUCT<"owners" ARRAY<VARCHAR>,
              "view-data" ARRAY<VARCHAR>
   >)
WITH (KAFKA_TOPIC='nuvlabox-status',
   PARTITIONS=1,
   REPLICAS=1,
   VALUE_FORMAT='JSON');

--- re-key by parent which is NB ID
--- due to: only T-to-T join on foreign key is supported.
CREATE STREAM NUVLAEDGE_STATUS_REKYED_S AS
SELECT
    parent as id,
    nb.name as name,
    nb.description as description,
    nb.tags as tags,
    online,
    "online-prev" as online_prev,
    network,
    resources,
    "resources-prev" as resources_prev,
    "current-time" as timestamp,
    updated as nuvla_timestamp,
    "nuvlabox-engine-version" as nuvlabox_engine_version,
    tlm.acl as acl
FROM NUVLAEDGE_STATUS_S as tlm
JOIN NUVLAEDGE_T as nb ON tlm.parent = nb.id
PARTITION BY parent
EMIT CHANGES;
