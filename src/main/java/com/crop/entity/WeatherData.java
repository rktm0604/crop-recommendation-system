package com.crop.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Weather data from OpenWeather API (temperature, humidity, rainfall).
 * Stored for historical analysis and recommendation input.
 */
@Entity
@Table(name = "weather_data", indexes = {
    @Index(name = "idx_weather_location", columnList = "location"),
    @Index(name = "idx_weather_recorded_date", columnList = "recorded_date")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WeatherData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(nullable = false)
    private Double temperature;

    @NotNull
    @Column(nullable = false)
    private Double humidity;

    @NotNull
    @Column(nullable = false)
    private Double rainfall;

    @NotNull
    @Column(nullable = false, length = 255)
    private String location;

    @NotNull
    @Column(nullable = false)
    private LocalDateTime recordedDate;

    @PrePersist
    protected void onCreate() {
        if (recordedDate == null) {
            recordedDate = LocalDateTime.now();
        }
    }
}
