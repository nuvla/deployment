## Kafka Connect Elasticsearch Source

For configuration of "Kafka Connect Elasticsearch Source" see
https://github.com/DarioBalinzo/kafka-connect-elasticsearch-source

Use this Kafka connect for indexes with streams of data like event or
telemetry, because "The connector fetches only new data using a strictly
incremental / temporal field (like a timestamp or an incrementing id)." Do not
use for objects that have fixed duration lifetime and are subject to updates,
like `notification-method` or `subscription-config`.

Select the top level attribute on the document that is the subject to constant
change accross the documents in the index. E.g. it can be either `timestamp` or
`updated`

```
"incrementing.field.name" : "updated"
```

Quick example for `nuvla-nuvlabox` and `nuvla-nuvlabox-status` indexes.

Start Kafka Connect container with jar with dependencies in the `plugin.path`.

Create configuration file

```
cat >elastic-source-nuvlabox-all.json<<EOF
{   "name": "elastic-source-nuvlabox-all",
    "config": {"connector.class": "com.github.dariobalinzo.ElasticSourceConnector",
               "tasks.max": "1",
               "es.host" : "es",
               "es.port" : "9200",
               "index.prefix" : "nuvla-nuvlabox",
               "topic.prefix" : "es_",
               "incrementing.field.name" : "updated",
               "fieldname_converter": "nop"
        }
}
EOF
```

Create the configuration and check its status in the Kafka Connect instance.

```
# create
curl -X POST -H "Content-Type: application/json" --data @elastic-source-nuvlabox-all.json \
    http://kafka-connect:8083/connectors

# status
curl kafka-connect:8083/connectors/elastic-source-nuvlabox-all/status
```

Delete the configuration.

```
curl -X DELETE kafka-connect:8083/connectors/elastic-source-nuvlabox-all
```
