package com.crop.controller;

import com.crop.dto.WeatherResponse;
import com.crop.service.WeatherService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/weather")
@RequiredArgsConstructor
public class WeatherController {

    private final WeatherService weatherService;

    @GetMapping("/current")
    public ResponseEntity<WeatherResponse> getCurrentWeather(@RequestParam String location) {
        return ResponseEntity.ok(weatherService.fetchAndStoreWeather(location));
    }
}
