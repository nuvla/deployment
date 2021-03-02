----------------------------------------------------------
--
-- Subscription to NB load > threshold with email notification
CREATE TABLE SUBS_NB_LOAD_ABOVE_EMAIL_T AS
SELECT "resource-id",
    LATEST_BY_OFFSET(notif.method) as method,
    LATEST_BY_OFFSET(notif.destination) as destination,
    LATEST_BY_OFFSET(subs.enabled) AS enabled,
    LATEST_BY_OFFSET(AS_VALUE(subs.id)) AS subs_id,
    LATEST_BY_OFFSET(subs.name) AS name,
    LATEST_BY_OFFSET(subs.description) AS description,
    LATEST_BY_OFFSET(subs.acl->owners[1]) AS owner,
    LATEST_BY_OFFSET(subs.category) AS category,
    LATEST_BY_OFFSET(subs."method-id") AS "method-id",
    LATEST_BY_OFFSET(subs."resource-kind") AS "resource-kind",
    LATEST_BY_OFFSET(subs.criteria->metric) AS metric,
    LATEST_BY_OFFSET(subs.criteria->condition) AS condition,
    LATEST_BY_OFFSET(subs.criteria->"value") AS "value",
    LATEST_BY_OFFSET(subs.criteria->"window") AS "window"
FROM SUBSCRIPTION_S AS subs
JOIN NOTIFICATION_METHOD_T AS notif ON notif.id = "method-id"
WHERE "resource-kind" = 'nuvlabox'
    AND notif.method = 'email'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'load'
    AND subs.criteria->condition = '>'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_EMAIL_S
SELECT
    subs."resource-id" as id,
    subs.method as method,
    subs.destination as destination,
    subs.subs_id as subs_id,
    subs.name as subs_name,
    subs.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB load %' as metric,
    subs.condition as condition,
    CAST(subs."value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_cpu_load_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->cpu->"load" > nb_tlm.resources->cpu->"load") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_LOAD_ABOVE_EMAIL_T AS subs ON nb_tlm.id = subs."resource-id"
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND subs.enabled = true
    AND ((nb_tlm.resources_prev_cpu_load_pers <= CAST(subs."value" AS INTEGER)
           AND nb_tlm.resources_cpu_load_pers > CAST(subs."value" AS INTEGER))
        OR
        (nb_tlm.resources_cpu_load_pers < CAST(subs."value" AS INTEGER)
           AND nb_tlm.resources_prev_cpu_load_pers >= CAST(subs."value" AS INTEGER)))
EMIT CHANGES;

----------
--
-- Subscription to NB load > threshold with slack notification
CREATE TABLE SUBS_NB_LOAD_ABOVE_SLACK_T AS
SELECT "resource-id",
    LATEST_BY_OFFSET(notif.method) as method,
    LATEST_BY_OFFSET(notif.destination) as destination,
    LATEST_BY_OFFSET(subs.enabled) AS enabled,
    LATEST_BY_OFFSET(AS_VALUE(subs.id)) AS subs_id,
    LATEST_BY_OFFSET(subs.name) AS name,
    LATEST_BY_OFFSET(subs.description) AS description,
    LATEST_BY_OFFSET(subs.acl->owners[1]) AS owner,
    LATEST_BY_OFFSET(subs.category) AS category,
    LATEST_BY_OFFSET(subs."method-id") AS "method-id",
    LATEST_BY_OFFSET(subs."resource-kind") AS "resource-kind",
    LATEST_BY_OFFSET(subs.criteria->metric) AS metric,
    LATEST_BY_OFFSET(subs.criteria->condition) AS condition,
    LATEST_BY_OFFSET(subs.criteria->"value") AS "value",
    LATEST_BY_OFFSET(subs.criteria->"window") AS "window"
FROM SUBSCRIPTION_S AS subs
JOIN NOTIFICATION_METHOD_T AS notif ON notif.id = "method-id"
WHERE "resource-kind" = 'nuvlabox'
    AND notif.method = 'slack'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'load'
    AND subs.criteria->condition = '>'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_SLACK_S
SELECT
    subs."resource-id" as id,
    subs.method as method,
    subs.destination as destination,
    subs.subs_id as subs_id,
    subs.name as subs_name,
    subs.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB load %' as metric,
    subs.condition as condition,
    CAST(subs."value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_cpu_load_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->cpu->"load" > nb_tlm.resources->cpu->"load") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_LOAD_ABOVE_SLACK_T AS subs ON nb_tlm.id = subs."resource-id"
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND subs.enabled = true
    AND ((nb_tlm.resources_prev_cpu_load_pers <= CAST(subs."value" AS INTEGER)
           AND nb_tlm.resources_cpu_load_pers > CAST(subs."value" AS INTEGER))
        OR
        (nb_tlm.resources_cpu_load_pers < CAST(subs."value" AS INTEGER)
           AND nb_tlm.resources_prev_cpu_load_pers >= CAST(subs."value" AS INTEGER)))
EMIT CHANGES;

----------------------------------------------------------
--
-- Subscription to NB load < threshold with email notification
CREATE TABLE SUBS_NB_LOAD_BELOW_EMAIL_T AS
SELECT "resource-id",
    LATEST_BY_OFFSET(notif.method) as method,
    LATEST_BY_OFFSET(notif.destination) as destination,
    LATEST_BY_OFFSET(subs.enabled) AS enabled,
    LATEST_BY_OFFSET(AS_VALUE(subs.id)) AS subs_id,
    LATEST_BY_OFFSET(subs.name) AS name,
    LATEST_BY_OFFSET(subs.description) AS description,
    LATEST_BY_OFFSET(subs.acl->owners[1]) AS owner,
    LATEST_BY_OFFSET(subs.category) AS category,
    LATEST_BY_OFFSET(subs."method-id") AS "method-id",
    LATEST_BY_OFFSET(subs."resource-kind") AS "resource-kind",
    LATEST_BY_OFFSET(subs.criteria->metric) AS metric,
    LATEST_BY_OFFSET(subs.criteria->condition) AS condition,
    LATEST_BY_OFFSET(subs.criteria->"value") AS "value",
    LATEST_BY_OFFSET(subs.criteria->"window") AS "window"
FROM SUBSCRIPTION_S AS subs
JOIN NOTIFICATION_METHOD_T AS notif ON notif.id = "method-id"
WHERE "resource-kind" = 'nuvlabox'
    AND notif.method = 'email'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'load'
    AND subs.criteria->condition = '<'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_EMAIL_S
SELECT
    subs."resource-id" as id,
    subs.method as method,
    subs.destination as destination,
    subs.subs_id as subs_id,
    subs.name as subs_name,
    subs.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB load %' as metric,
    subs.condition as condition,
    CAST(subs."value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_cpu_load_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->cpu->"load" < nb_tlm.resources->cpu->"load") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_LOAD_BELOW_EMAIL_T AS subs ON nb_tlm.id = subs."resource-id"
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND subs.enabled = true
    AND ((nb_tlm.resources_prev_cpu_load_pers >= CAST(subs."value" AS INTEGER)
           AND nb_tlm.resources_cpu_load_pers < CAST(subs."value" AS INTEGER))
        OR
        (nb_tlm.resources_cpu_load_pers > CAST(subs."value" AS INTEGER)
           AND nb_tlm.resources_prev_cpu_load_pers <= CAST(subs."value" AS INTEGER)))
EMIT CHANGES;

----------
--
-- Subscription to NB load < threshold with slack notification
CREATE TABLE SUBS_NB_LOAD_BELOW_SLACK_T AS
SELECT "resource-id",
    LATEST_BY_OFFSET(notif.method) as method,
    LATEST_BY_OFFSET(notif.destination) as destination,
    LATEST_BY_OFFSET(subs.enabled) AS enabled,
    LATEST_BY_OFFSET(AS_VALUE(subs.id)) AS subs_id,
    LATEST_BY_OFFSET(subs.name) AS name,
    LATEST_BY_OFFSET(subs.description) AS description,
    LATEST_BY_OFFSET(subs.acl->owners[1]) AS owner,
    LATEST_BY_OFFSET(subs.category) AS category,
    LATEST_BY_OFFSET(subs."method-id") AS "method-id",
    LATEST_BY_OFFSET(subs."resource-kind") AS "resource-kind",
    LATEST_BY_OFFSET(subs.criteria->metric) AS metric,
    LATEST_BY_OFFSET(subs.criteria->condition) AS condition,
    LATEST_BY_OFFSET(subs.criteria->"value") AS "value",
    LATEST_BY_OFFSET(subs.criteria->"window") AS "window"
FROM SUBSCRIPTION_S AS subs
JOIN NOTIFICATION_METHOD_T AS notif ON notif.id = "method-id"
WHERE "resource-kind" = 'nuvlabox'
    AND notif.method = 'slack'
    AND criteria->kind = 'numeric'
    AND criteria->metric = 'load'
    AND subs.criteria->condition = '<'
GROUP BY "resource-id"
EMIT CHANGES;

INSERT INTO NOTIFICATIONS_SLACK_S
SELECT
    subs."resource-id" as id,
    subs.method as method,
    subs.destination as destination,
    subs.subs_id as subs_id,
    subs.name as subs_name,
    subs.description as subs_description,
    CONCAT('edge/', SPLIT(AS_VALUE(nb_tlm.id), '/')[2]) as resource_uri,
    nb_tlm.name as resource_name,
    nb_tlm.description as resource_description,
    'NB load %' as metric,
    subs.condition as condition,
    CAST(subs."value" as VARCHAR) as condition_value,
    CAST(nb_tlm.resources_cpu_load_pers as VARCHAR) as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.resources_prev->cpu->"load" < nb_tlm.resources->cpu->"load") as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_LOAD_BELOW_SLACK_T AS subs ON nb_tlm.id = subs."resource-id"
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND subs.enabled = true
    AND ((nb_tlm.resources_prev_cpu_load_pers >= CAST(subs."value" AS INTEGER)
           AND nb_tlm.resources_cpu_load_pers < CAST(subs."value" AS INTEGER))
        OR
        (nb_tlm.resources_cpu_load_pers > CAST(subs."value" AS INTEGER)
           AND nb_tlm.resources_prev_cpu_load_pers <= CAST(subs."value" AS INTEGER)))
EMIT CHANGES;
