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

--
-- email notifications stream
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
    timestamp VARCHAR
) WITH (
    KAFKA_TOPIC='NOTIFICATIONS_EMAIL_S',
    PARTITIONS=3,
    REPLICAS=3,
    VALUE_FORMAT = 'JSON'
);

--
-- slack notifications stream
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
    timestamp VARCHAR
) WITH (
    KAFKA_TOPIC='NOTIFICATIONS_SLACK_S',
    PARTITIONS=3,
    REPLICAS=3,
    VALUE_FORMAT = 'JSON'
);

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
      PARTITIONS=3,
      REPLICAS=3,
      VALUE_FORMAT='JSON');

----------------------------------
-- NB subscription criteria

--
-- NB state metrics (expanded)
CREATE TABLE SUBS_NB_STATE_T AS
    SELECT "resource-id",
           LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
           LATEST_BY_OFFSET(enabled) AS enabled,
           LATEST_BY_OFFSET(name) AS name,
           LATEST_BY_OFFSET(description) AS description,
           LATEST_BY_OFFSET(acl->owners[1]) AS owner,
           LATEST_BY_OFFSET(category) AS category,
           LATEST_BY_OFFSET("method-id") AS "method-id",
           LATEST_BY_OFFSET("resource-kind") AS "resource-kind",
           LATEST_BY_OFFSET(criteria->metric) AS metric,
           LATEST_BY_OFFSET(criteria->condition) AS condition,
           LATEST_BY_OFFSET(criteria->"value") AS "value",
           LATEST_BY_OFFSET(criteria->"window") AS "window"
    FROM SUBSCRIPTION_S
    WHERE "resource-kind" = 'nuvlabox'
          and criteria->kind = 'boolean'
          and criteria->metric = 'state'
    GROUP BY "resource-id"
    EMIT CHANGES;

--
-- NB numeric above metrics (expanded)
CREATE TABLE SUBS_NB_LOAD_ABOVE_T AS
    SELECT "resource-id",
           LATEST_BY_OFFSET(AS_VALUE(id)) AS subs_id,
           LATEST_BY_OFFSET(enabled) AS enabled,
           LATEST_BY_OFFSET(name) AS name,
           LATEST_BY_OFFSET(description) AS description,
           LATEST_BY_OFFSET(acl->owners[1]) AS owner,
           LATEST_BY_OFFSET(category) AS category,
           LATEST_BY_OFFSET("method-id") AS "method-id",
           LATEST_BY_OFFSET("resource-kind") AS "resource-kind",
           LATEST_BY_OFFSET(criteria->metric) AS metric,
           LATEST_BY_OFFSET(criteria->condition) AS condition,
           LATEST_BY_OFFSET(CAST(criteria->"value" as DOUBLE)) AS "value",
           LATEST_BY_OFFSET(criteria->"window") AS "window"
    FROM SUBSCRIPTION_S
    WHERE "resource-kind" = 'nuvlabox'
          and criteria->kind = 'numeric'
          and criteria->condition = '>'
          and criteria->metric = 'load'
    GROUP BY "resource-id"
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
   resources STRUCT<cpu STRUCT<"load" DOUBLE, "capacity" BIGINT, "topic" VARCHAR>,
                    ram STRUCT<"used" BIGINT, "capacity" BIGINT, "topic" VARCHAR>>,
   "current-time" VARCHAR,
   acl STRUCT<"owners" ARRAY<VARCHAR>,
              "view-data" ARRAY<VARCHAR>
   >)
   WITH (KAFKA_TOPIC='es_nuvla-nuvlabox-status',
         PARTITIONS=3,
         REPLICAS=3,
         VALUE_FORMAT='JSON');

-- re-key by parent which is NB ID
-- due to: only T-to-T join on foreign key is supported.
CREATE STREAM NB_TELEM_RESOURCES_REKYED_S AS
   SELECT
       parent as id,
       nb.name as name,
       nb.description as description,
       online,
       resources,
       "current-time" as timestamp,
       tlm.acl as acl
   FROM NB_TELEM_RESOURCES_S as tlm
   JOIN NUVLABOX_T as nb ON tlm.parent = nb.id
   PARTITION BY parent;

---------------------------------------
-- Notifications trigger on NB off-line
--
CREATE STREAM NB_OFFLINE_NOTIF_S
WITH (PARTITIONS=3, REPLICAS=3, VALUE_FORMAT='JSON')
AS SELECT
       subs."method-id" as id,
       notif.method as method,
       notif.destination as destination,
       subs.subs_id as subs_id,
       subs.name as subs_name,
       subs.description as subs_description,
       CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as nb_uri,
       nb_tlm.name as nb_name,
       nb_tlm.description as nb_description,
       CONCAT('NB online', '') as metric,
       subs.condition as condition,
       CONCAT('') as condition_value,
       CONCAT('') as "VALUE",
       nb_tlm.timestamp as timestamp
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_STATE_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN NOTIFICATION_METHOD_T AS notif ON notif.id = subs."method-id"
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
      AND subs.enabled = true
      AND nb_tlm.online = false
      EMIT CHANGES;

INSERT INTO NOTIFICATIONS_EMAIL_S
SELECT id,
       method,
       destination,
       subs_id,
       subs_name,
       subs_description,
       nb_uri as resource_uri,
       nb_name as resource_name,
       nb_description as resource_description,
       metric,
       condition,
       condition_value,
       "VALUE",
       timestamp
FROM NB_OFFLINE_NOTIF_S
WHERE LCASE(method) = 'email';

INSERT INTO NOTIFICATIONS_SLACK_S
SELECT id,
       method,
       destination,
       subs_id,
       subs_name,
       subs_description,
       nb_uri as resource_uri,
       nb_name as resource_name,
       nb_description as resource_description,
       metric,
       condition,
       condition_value,
       "VALUE",
       timestamp
FROM NB_OFFLINE_NOTIF_S
WHERE LCASE(method) = 'slack';


------------------------------------------------------
-- Notifications trigger on NB load % above threshold
--
CREATE STREAM NB_LOAD_ABOVE_NOTIF_S
WITH (PARTITIONS=3, REPLICAS=3, VALUE_FORMAT='JSON')
AS SELECT
       subs."method-id" as id,
       notif.method as method,
       notif.destination as destination,
       subs.subs_id as subs_id,
       subs.name as subs_name,
       subs.description as subs_description,
       CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as nb_uri,
       nb_tlm.name as nb_name,
       nb_tlm.description as nb_description,
       CONCAT('NB load %', '') as metric,
       subs.condition as condition,
       subs."value" as condition_value,
       ((nb_tlm.resources->cpu->"load" * 100) / nb_tlm.resources->cpu->"capacity") as "VALUE",
       nb_tlm.timestamp as timestamp
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_LOAD_ABOVE_T AS subs ON subs."resource-id" = nb_tlm.id
JOIN NOTIFICATION_METHOD_T AS notif ON notif.id = subs."method-id"
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
      AND subs.enabled = true
      AND (nb_tlm.resources->cpu->"load" * 100) / nb_tlm.resources->cpu->"capacity" > CAST(subs."value" AS INTEGER)
      EMIT CHANGES;

INSERT INTO NOTIFICATIONS_EMAIL_S
SELECT id,
       method,
       destination,
       subs_id,
       subs_name,
       subs_description,
       nb_uri as resource_uri,
       nb_name as resource_name,
       nb_description as resource_description,
       metric,
       condition,
       CAST(condition_value AS VARCHAR) AS condition_value,
       CAST("VALUE" AS VARCHAR) AS "VALUE",
       timestamp
FROM NB_LOAD_ABOVE_NOTIF_S
WHERE LCASE(method) = 'email';

INSERT INTO NOTIFICATIONS_SLACK_S
SELECT id,
       method,
       destination,
       subs_id,
       subs_name,
       subs_description,
       nb_uri as resource_uri,
       nb_name as resource_name,
       nb_description as resource_description,
       metric,
       condition,
       CAST(condition_value AS VARCHAR) AS condition_value,
       CAST("VALUE" as VARCHAR) AS "VALUE",
       timestamp
FROM NB_LOAD_ABOVE_NOTIF_S
WHERE LCASE(method) = 'slack';
