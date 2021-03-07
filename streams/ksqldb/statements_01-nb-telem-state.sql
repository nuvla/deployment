----------------------------------
--
-- Subscription to NB state change
CREATE TABLE SUBS_NB_STATE_T AS
SELECT
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
