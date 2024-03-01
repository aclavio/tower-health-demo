package com.example.demo.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public class SensorData {
    @JsonProperty("TOWER_NAME")
    String towerName;

    @JsonProperty("CONFIDENCE")
    Integer confidence;

    @JsonProperty("EVENT_DATA")
    String eventData;

    @JsonProperty("TS")
    String timestamp;

    public String getTowerName() {
        return towerName;
    }

    public void setTowerName(String towerName) {
        this.towerName = towerName;
    }

    public Integer getConfidence() {
        return confidence;
    }

    public void setConfidence(Integer confidence) {
        this.confidence = confidence;
    }

    public String getEventData() {
        return eventData;
    }

    public void setEventData(String eventData) {
        this.eventData = eventData;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
}
