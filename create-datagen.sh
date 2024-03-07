#!/bin/bash

BOOTSTRAP_SERVER=localhost:29092
COMMAND_CONFIG=
#COMMAND_CONFIG="--command-config client.properties"
CONNECT_HOST=localhost
START=1
COUNT=3
TOPIC_PREFIX='device-data.'
SENSOR_NAME_PREFIX=sensor_
TOWER_NAME=TOWER_1

for i in $(seq $START $COUNT);
do
    TOPIC_NAME="$TOPIC_PREFIX$SENSOR_NAME_PREFIX$i"
    echo "Creating topic $TOPIC_NAME"
    kafka-topics --bootstrap-server $BOOTSTRAP_SERVER $COMMAND_CONFIG --create --topic $TOPIC_NAME

    echo "Creating Connector #$i"
    curl -s -X PUT \
          -H "Content-Type: application/json" \
          --data '{
                    "name": "datagen-'"$SENSOR_NAME_PREFIX$i"'",
                    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
                    "kafka.topic": "'"$TOPIC_NAME"'",
                    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
                    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
                    "value.converter.schemas.enable": "false",
                    "max.interval": 500,
                    "iterations": "-1",
                    "tasks.max": "1",
                    "schema.keyfield": "sensor_name",
                    "schema.string": "{\"namespace\": \"\",\"name\": \"sensor\",\"type\": \"record\",\"fields\": [{\"name\": \"sensor_name\",\"type\": {\"type\": \"string\",\"arg.properties\": {\"options\": [\"'"$SENSOR_NAME_PREFIX$i"'\"]}}},{\"name\": \"tower_name\",\"type\": {\"type\": \"string\",\"arg.properties\": {\"options\": [\"'"$TOWER_NAME"'\"]}}},{\"name\": \"event_time\",\"type\": {\"type\": \"long\",\"logicalType\": \"timestamp-millis\"}},{\"name\": \"confidence\",\"type\": {\"type\": \"int\",\"arg.properties\": {\"range\": {\"min\": 0,\"max\": 100}}}},{\"name\": \"event_data\",\"type\": {\"type\": \"int\",\"arg.properties\": {\"iteration\": {\"start\": 0}}}}]}"
                }' \
          http://$CONNECT_HOST:8083/connectors/datagen-$SENSOR_NAME_PREFIX$i/config | jq .
done



