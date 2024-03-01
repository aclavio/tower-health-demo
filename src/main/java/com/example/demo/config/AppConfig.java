package com.example.demo.config;

import com.example.demo.models.SensorData;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.*;

@Configuration
public class AppConfig {
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }

    @Bean
    public Map<String, SensorData> sensorDataMap() {
        return Collections.synchronizedMap(new HashMap<>());
    }
}
