package com.crop.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeatherResponse {

    private Double temperature;
    private Double humidity;
    private Double rainfall;
    private String location;
    private String recordedAt;
}
