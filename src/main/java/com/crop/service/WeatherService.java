package com.crop.service;

import com.crop.dto.WeatherResponse;
import com.crop.entity.WeatherData;
import com.crop.exception.BadRequestException;
import com.crop.repository.WeatherDataRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.Optional;

/**
 * Fetches weather from OpenWeather API and persists to WeatherData.
 * Handles timeout and API errors.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WeatherService {

    private final WebClient webClient;
    private final WeatherDataRepository weatherDataRepository;

    @Value("${openweather.api.key}")
    private String apiKey;

    @Value("${openweather.api.base-url}")
    private String baseUrl;

    /**
     * Fetch current weather for location (city name) and persist.
     * Rainfall: OpenWeather returns "rain.1h" or "rain.3h" in mm; we use that or 0.
     */
    @Transactional
    public WeatherResponse fetchAndStoreWeather(String location) {
        if (location == null || location.isBlank()) {
            throw new BadRequestException("Location is required");
        }
        try {
            Map<String, Object> response = webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .scheme("https")
                            .host("api.openweathermap.org")
                            .path("/data/2.5/weather")
                            .queryParam("q", location)
                            .queryParam("appid", apiKey)
                            .queryParam("units", "metric")
                            .build())
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {})
                    .block();

            if (response == null) {
                throw new BadRequestException("No weather data received from API");
            }

            double temp = getDouble(response, "main", "temp");
            double humidity = getDouble(response, "main", "humidity");
            double rainfall = getRainfall(response);

            WeatherData data = WeatherData.builder()
                    .temperature(temp)
                    .humidity(humidity)
                    .rainfall(rainfall)
                    .location(location)
                    .recordedDate(LocalDateTime.now())
                    .build();
            data = weatherDataRepository.save(data);
            log.info("Weather stored for {}: temp={}, humidity={}, rainfall={}", location, temp, humidity, rainfall);

            return WeatherResponse.builder()
                    .temperature(data.getTemperature())
                    .humidity(data.getHumidity())
                    .rainfall(data.getRainfall())
                    .location(data.getLocation())
                    .recordedAt(data.getRecordedDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
                    .build();
        } catch (WebClientResponseException e) {
            log.error("OpenWeather API error: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
            if (e.getStatusCode().value() == 401) {
                throw new BadRequestException("Invalid OpenWeather API key. Set openweather.api.key in application.properties");
            }
            if (e.getStatusCode().value() == 404) {
                throw new BadRequestException("Location not found: " + location);
            }
            throw new BadRequestException("Weather API error: " + e.getMessage());
        } catch (Exception e) {
            log.error("Weather fetch failed for {}: {}", location, e.getMessage());
            throw new BadRequestException("Failed to fetch weather: " + e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public Optional<WeatherData> getLatestForLocation(String location) {
        return weatherDataRepository.findFirstByLocationOrderByRecordedDateDesc(location);
    }

    private double getDouble(Map<String, Object> response, String key1, String key2) {
        Object main = response.get(key1);
        if (main instanceof Map) {
            Object val = ((Map<?, ?>) main).get(key2);
            if (val instanceof Number) {
                return ((Number) val).doubleValue();
            }
        }
        return 0.0;
    }

    private double getRainfall(Map<String, Object> response) {
        Object rain = response.get("rain");
        if (rain instanceof Map) {
            Map<?, ?> r = (Map<?, ?>) rain;
            Object v = r.get("1h");
            if (v == null) v = r.get("3h");
            if (v instanceof Number) return ((Number) v).doubleValue();
        }
        return 0.0;
    }
}
