----------------------------------------------------------
--
-- Subscription to NB state ONLINE with email notification
CREATE TABLE SUBS_NB_STATE_ON_EMAIL_T AS
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
    AND subs.criteria->kind = 'boolean'
    AND subs.criteria->metric = 'state'
    AND subs.criteria->condition = 'yes'
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
    'NB online' as metric,
    subs.condition as condition,
    '' as condition_value,
    '' as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.online = true AND nb_tlm.online_prev = false) as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_STATE_ON_EMAIL_T AS subs ON subs."resource-id" = nb_tlm.id
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND subs.enabled = true
    AND (nb_tlm.online = true AND nb_tlm.online_prev = false)
EMIT CHANGES;

--
-- Subscription to NB state OFFLINE with email notification
CREATE TABLE SUBS_NB_STATE_OFF_EMAIL_T AS
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
    AND subs.criteria->kind = 'boolean'
    AND subs.criteria->metric = 'state'
    AND subs.criteria->condition = 'no'
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
    'NB online' as metric,
    subs.condition as condition,
    '' as condition_value,
    '' as "VALUE",
    nb_tlm.timestamp as timestamp,
    false as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_STATE_OFF_EMAIL_T AS subs ON subs."resource-id" = nb_tlm.id
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND subs.enabled = true
    AND (nb_tlm.online = false AND nb_tlm.online_prev = true)
EMIT CHANGES;


----------------------------------------------------------
--
-- Subscription to NB state ONLINE with slack notification
CREATE TABLE SUBS_NB_STATE_ON_SLACK_T AS
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
    AND subs.criteria->kind = 'boolean'
    AND subs.criteria->metric = 'state'
    AND subs.criteria->condition = 'yes'
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
    'NB online' as metric,
    subs.condition as condition,
    '' as condition_value,
    '' as "VALUE",
    nb_tlm.timestamp as timestamp,
    (nb_tlm.online = true AND nb_tlm.online_prev = false) as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_STATE_ON_SLACK_T AS subs ON subs."resource-id" = nb_tlm.id
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND subs.enabled = true
    AND (nb_tlm.online = true AND nb_tlm.online_prev = false)
EMIT CHANGES;

--
-- Subscription to NB state OFFLINE with slack notification
CREATE TABLE SUBS_NB_STATE_OFF_SLACK_T AS
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
    AND subs.criteria->kind = 'boolean'
    AND subs.criteria->metric = 'state'
    AND subs.criteria->condition = 'no'
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
    'NB online' as metric,
    subs.condition as condition,
    '' as condition_value,
    '' as "VALUE",
    nb_tlm.timestamp as timestamp,
    false as recovery
FROM NB_TELEM_RESOURCES_REKYED_S AS nb_tlm
JOIN SUBS_NB_STATE_OFF_SLACK_T AS subs ON subs."resource-id" = nb_tlm.id
WHERE (ARRAY_CONTAINS(nb_tlm.acl->"owners", subs.owner) OR ARRAY_CONTAINS(nb_tlm.acl->"view-data", subs.owner))
    AND subs.enabled = true
    AND (nb_tlm.online = false AND nb_tlm.online_prev = true)
EMIT CHANGES;
