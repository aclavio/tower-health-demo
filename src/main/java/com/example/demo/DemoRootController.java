package com.example.demo;

import com.example.demo.models.SensorData;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.common.protocol.types.Field;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Controller
public class DemoRootController {

    Logger logger = LoggerFactory.getLogger(DemoRootController.class);

    @Autowired
    ObjectMapper objectMapper;

    @Autowired
    Map<String, SensorData> sensorDataMap;

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("name", "bob");
        return "index";
    }

    class SensorDataRow {
        public String name;
        public String tower;
        public Integer confidence;
        public String data;
        public String timestamp;

        SensorDataRow(String sensorName, SensorData sensorData) {
            name = sensorName;
            tower = sensorData.getTowerName();
            confidence = sensorData.getConfidence();
            data = sensorData.getEventData();
            timestamp = sensorData.getTimestamp();
        }
    }

    @GetMapping("/health.html")
    public String sensorData(Model model) {
        List<SensorDataRow> sensorData = new ArrayList<>();
        synchronized (sensorDataMap) {
            Iterator<String> keys = sensorDataMap.keySet().iterator();
            while (keys.hasNext()) {
                String key = keys.next();
                SensorData data = sensorDataMap.get(key);
                sensorData.add(new SensorDataRow(key, data));
            }
        }
        model.addAttribute("sensorData", sensorData);
        logger.info("{}", sensorData);
        return "health";
    }

    @GetMapping("/health")
    @CrossOrigin
    @ResponseBody
    public List<SensorDataRow> sensorDataRest() {
        List<SensorDataRow> sensorData = new ArrayList<>();
        synchronized (sensorDataMap) {
            Iterator<String> keys = sensorDataMap.keySet().iterator();
            while (keys.hasNext()) {
                String key = keys.next();
                SensorData data = sensorDataMap.get(key);
                sensorData.add(new SensorDataRow(key, data));
            }
        }
        logger.info("{}", sensorData);
        return sensorData;
    }

}
