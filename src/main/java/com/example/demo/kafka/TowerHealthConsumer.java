package com.example.demo.kafka;

import com.example.demo.models.SensorData;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;

@Configuration
public class TowerHealthConsumer {

    Logger logger = LoggerFactory.getLogger(TowerHealthConsumer.class);

    @Autowired
    ObjectMapper objectMapper;

    @Autowired
    Map<String, SensorData> sensorDataMap;

    @KafkaListener(
            topics = "${tower.health.topic.name}",
            containerFactory = "kafkaListenerContainerFactory"
    )
    public void towerHealthListener(
            @Header(KafkaHeaders.RECEIVED_KEY) String key,
            @Payload String message
    ) {
        logger.debug("got raw: {}:{}", key, message);

        try {
            SensorData data = objectMapper.readValue(message, SensorData.class);
            logger.info("{}", objectMapper.writeValueAsString(data));
            sensorDataMap.put(key, data);
        } catch (JsonProcessingException e) {
            logger.error("Error Deserializing Message:", e);
        }
    }
}
