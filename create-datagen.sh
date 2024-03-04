#!/bin/bash

CONNECT_HOST=localhost
TOWER_NAME=TOWER_1
for i in $(seq 1 3);
do
    echo "Creating Connector #$i"
    curl -s -X PUT \
          -H "Content-Type: application/json" \
          --data '{
                    "name": "datagen-sensor$i",
                    "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
                    "kafka.topic": "device-data.sensor$i",
                    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
                    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
                    "value.converter.schemas.enable": "false",
                    "max.interval": 500,
                    "iterations": "-1",
                    "tasks.max": "1",
                    "schema.keyfield": "sensor_name",
                    "schema.string": "{\"namespace\": \"\",\"name\": \"sensor\",\"type\": \"record\",\"fields\": [{\"name\": \"sensor_name\",\"type\": {\"type\": \"string\",\"arg.properties\": {\"options\": [\"sensor$i\"]}}},{\"name\": \"tower_name\",\"type\": {\"type\": \"string\",\"arg.properties\": {\"options\": [\"$TOWER_NAME\"]}}},{\"name\": \"event_time\",\"type\": {\"type\": \"long\",\"logicalType\": \"timestamp-millis\"}},{\"name\": \"confidence\",\"type\": {\"type\": \"int\",\"arg.properties\": {\"range\": {\"min\": 0,\"max\": 100}}}},{\"name\": \"event_data\",\"type\": {\"type\": \"int\",\"arg.properties\": {\"iteration\": {\"start\": 0}}}}]}"
                }' \
          http://$CONNECT_HOST:8083/connectors/datagen-sensor$i/config | jq .
done



