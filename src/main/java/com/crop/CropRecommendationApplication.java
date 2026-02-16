package com.crop;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Main entry point for Smart Crop Recommendation System.
 * Enables scheduling for periodic weather sync and async operations.
 */
@SpringBootApplication
@EnableScheduling
@EnableAsync
public class CropRecommendationApplication {

    public static void main(String[] args) {
        SpringApplication.run(CropRecommendationApplication.class, args);
    }
}
