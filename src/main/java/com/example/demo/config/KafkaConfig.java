package com.example.demo.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.config.KafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.listener.ConcurrentMessageListenerContainer;

import java.util.Map;
import java.util.Properties;

@Configuration
@EnableKafka
public class KafkaConfig {

    Logger logger = LoggerFactory.getLogger(KafkaConfig.class);

    @ConfigurationProperties(prefix = "spring.kafka.properties")
    @Bean
    public Properties kafkaProperties() {
        return new Properties();
    }

    @Bean
    public KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<String, String>>
    kafkaListenerContainerFactory(@Autowired Properties kafkaProperties) {
        ConcurrentKafkaListenerContainerFactory<String, String> factory =
                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory(kafkaProperties));
        factory.setConcurrency(1);
        return factory;
    }

    @Bean
    public ConsumerFactory<String, String> consumerFactory(Properties props) {
        return new DefaultKafkaConsumerFactory<>((Map)props);
    }
}
