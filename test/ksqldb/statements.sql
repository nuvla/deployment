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
WITH (KAFKA_TOPIC='notification-method', PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON');

--
-- all subscriptions stream
-- from subscription.deployment.state topic
CREATE TABLE SUBSCRIPTION_T
(id VARCHAR,
  type VARCHAR,
  status VARCHAR,
  kind VARCHAR,
  category VARCHAR,
  resource VARCHAR PRIMARY KEY,
  method VARCHAR,
  acl STRUCT<
    owners ARRAY<VARCHAR>
  >
)
WITH (KAFKA_TOPIC='subscription', PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON');

--
-- subscriptions to event notifications of category 'state'
-- from SUBSCRIPTION_T topic
CREATE TABLE SUBS_EVENT_NOTIF_STATE_T
WITH (PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON')
AS SELECT *
FROM SUBSCRIPTION_T AS s
WHERE s.kind = 'event' AND s.type = 'notification' AND s.category = 'state';

--
-- events stream
-- from events topic
CREATE STREAM EVENT_S
(id VARCHAR,
  category VARCHAR,
  content STRUCT<resource STRUCT<href VARCHAR>,state VARCHAR>,
  severity VARCHAR,
  timestamp VARCHAR,
  acl STRUCT<
    owners ARRAY<VARCHAR>
  >
)
WITH (KAFKA_TOPIC='es_nuvla-event', PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON');

--
-- events for subscription on deployment state stream
-- as join between events stream and subscriptions to deployment state table
CREATE STREAM SUBS_EVENT_NOTIF_STATE_EVENT_S
WITH (PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON')
AS SELECT
  s.resource AS ID,
  s.method AS method_id,
  e.content AS event_content
FROM EVENT_S AS e
JOIN SUBS_EVENT_NOTIF_STATE_T AS s
ON s.resource = e.content->resource->href
WHERE ARRAY_CONTAINS(e.acl->owners, s.acl->owners[1]) AND s.status = 'enabled';

-- NB! Consider merging with the above join.
-- notifications stream
-- as join between events for subscription on deployment state stream and notification configuration table
CREATE STREAM NOTIFICATIONS_S
WITH (PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON')
AS SELECT
  se.id AS event_id,
  n.id AS notif_config_id,
  n.method AS method,
  n.destination AS destination,
  se.event_content->resource->href AS resource_id,
  se.event_content->state AS resource_state
FROM SUBS_EVENT_NOTIF_STATE_EVENT_S AS se
JOIN NOTIFICATION_METHOD_T AS n ON n.id = se.method_id;

--
-- email notifications
-- select from notifications stream
CREATE STREAM NOTIFICATIONS_EMAIL_S
WITH (PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON')
AS SELECT *
FROM NOTIFICATIONS_S
WHERE LCASE(method) = 'email';

--
-- slack notifications
-- select from notifications stream
CREATE STREAM NOTIFICATIONS_SLACK_S
WITH (PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON')
AS SELECT *
FROM NOTIFICATIONS_S
WHERE LCASE(method) = 'slack';

--
-- other notifications
-- select from notifications stream
CREATE STREAM NOTIFICATIONS_OTHER_S
WITH (PARTITIONS=1, REPLICAS=1, VALUE_FORMAT='JSON')
AS SELECT *
FROM NOTIFICATIONS_S
WHERE LCASE(method) != 'slack' AND LCASE(method) != 'email';