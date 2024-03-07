#!/bin/bash

BOOTSTRAP_SERVER=localhost:29092
CONNECT_HOST=localhost
KSQLDB_HOST=localhost

#COMMAND_CONFIG=
COMMAND_CONFIG="--command-config client.properties"
START=1
END=3
TOPIC_PREFIX='device-data.'
SENSOR_NAME_PREFIX=sensor_
TOWER_NAME=TOWER_1

for i in $(seq $START $END);
do
    SENSOR_NAME="$SENSOR_NAME_PREFIX$i"
    TOPIC_NAME="$TOPIC_PREFIX$SENSOR_NAME"
    echo "Creating topic $TOPIC_NAME"
    kafka-topics --bootstrap-server $BOOTSTRAP_SERVER $COMMAND_CONFIG --create --topic $TOPIC_NAME

    echo "Creating Connector #$i"
    curl -s -X PUT \
          -H "Content-Type: application/json" \
          --data '{
                    "name": "datagen-'"$SENSOR_NAME"'",
                    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
                    "kafka.topic": "'"$TOPIC_NAME"'",
                    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
                    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
                    "value.converter.schemas.enable": "false",
                    "max.interval": 500,
                    "iterations": "-1",
                    "tasks.max": "1",
                    "schema.keyfield": "sensor_name",
                    "schema.string": "{\"namespace\": \"\",\"name\": \"sensor\",\"type\": \"record\",\"fields\": [{\"name\": \"sensor_name\",\"type\": {\"type\": \"string\",\"arg.properties\": {\"options\": [\"'"$SENSOR_NAME"'\"]}}},{\"name\": \"tower_name\",\"type\": {\"type\": \"string\",\"arg.properties\": {\"options\": [\"'"$TOWER_NAME"'\"]}}},{\"name\": \"event_time\",\"type\": {\"type\": \"long\",\"logicalType\": \"timestamp-millis\"}},{\"name\": \"confidence\",\"type\": {\"type\": \"int\",\"arg.properties\": {\"range\": {\"min\": 0,\"max\": 100}}}},{\"name\": \"event_data\",\"type\": {\"type\": \"int\",\"arg.properties\": {\"iteration\": {\"start\": 0}}}}]}"
                }' \
          http://$CONNECT_HOST:8083/connectors/datagen-$SENSOR_NAME/config | jq .

    echo "Creating 'Edge' ksqlDB stream #$i"
    ksql --execute "
    CREATE OR REPLACE STREAM ${SENSOR_NAME}_stream (
      sensor_name STRING KEY,
      tower_name STRING,
      event_time BIGINT,
      confidence INT,
      event_data INT
    )
    WITH (kafka_topic='${TOPIC_NAME}', value_format='json')
    " -- http://$KSQLDB_HOST:8088

    echo "Creating 'Edge' ksqlDB filtered stream #$i"
    ksql --execute "
    CREATE STREAM ${SENSOR_NAME}_priority_stream
    WITH (kafka_topic='${TOPIC_NAME}_priority', value_format='json')
    AS SELECT
      sensor_name,
      tower_name,
      confidence,
      event_data,
      ROWTIME as ts
    FROM  ${SENSOR_NAME}_STREAM
    WHERE confidence > 80
    PARTITION BY sensor_name
    EMIT CHANGES
    " -- http://$KSQLDB_HOST:8088
done



