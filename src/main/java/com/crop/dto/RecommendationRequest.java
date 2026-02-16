package com.crop.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request to get crop recommendation: soil data + optional location for weather.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationRequest {

    @Valid
    @NotNull
    private SoilDataRequest soilData;

    /**
     * Optional location (city name) for weather-based recommendation.
     * If provided, rainfall from OpenWeather is used.
     */
    private String location;
}
