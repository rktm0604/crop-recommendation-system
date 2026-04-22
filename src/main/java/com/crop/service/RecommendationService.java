package com.crop.service;

import com.crop.dto.RecommendationRequest;
import com.crop.dto.RecommendationResponse;
import com.crop.dto.SoilDataRequest;
import com.crop.entity.Crop;
import com.crop.entity.Recommendation;
import com.crop.entity.User;
import com.crop.repository.CropRepository;
import com.crop.repository.RecommendationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import com.crop.dto.MultipleRecommendationResponse;
import com.crop.dto.MultipleRecommendationResponse.CropRecommendation;

/**
 * Rule-based crop recommendation: match soil (and optional weather) to crop ideal ranges.
 * Score = how many criteria fall within range; best match is returned and saved.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RecommendationService {

    private final CropRepository cropRepository;
    private final RecommendationRepository recommendationRepository;
    private final WeatherService weatherService;

    /**
     * Get recommendation for authenticated user. Uses location for rainfall if provided.
     */
    @Transactional
    public RecommendationResponse getRecommendation(Long userId, User user, RecommendationRequest request) {
        SoilDataRequest soil = request.getSoilData();
        double nitrogen = soil.getNitrogen();
        double phosphorus = soil.getPhosphorus();
        double potassium = soil.getPotassium();
        double ph = soil.getPh();
        double rainfall = 0.0;

        if (request.getLocation() != null && !request.getLocation().isBlank()) {
            Optional<com.crop.entity.WeatherData> weather = weatherService.getLatestForLocation(request.getLocation());
            if (weather.isPresent()) {
                rainfall = weather.get().getRainfall();
            } else {
                try {
                    rainfall = weatherService.fetchAndStoreWeather(request.getLocation()).getRainfall();
                } catch (Exception e) {
                    log.warn("Could not fetch weather for recommendation: {}", e.getMessage());
                }
            }
        }

        List<Crop> crops = cropRepository.findAll();
        if (crops.isEmpty()) {
            return RecommendationResponse.builder()
                    .cropName("N/A")
                    .confidenceScore(0.0)
                    .message("No crops in database. Please add crop data first.")
                    .build();
        }

        List<ScoredCrop> scored = new ArrayList<>();
        for (Crop c : crops) {
            double score = 0.0;
            int factors = 0;
            if (inRange(nitrogen, c.getIdealNMin(), c.getIdealNMax())) { score += 1.0; factors++; }
            if (inRange(phosphorus, c.getIdealPMin(), c.getIdealPMax())) { score += 1.0; factors++; }
            if (inRange(potassium, c.getIdealKMin(), c.getIdealKMax())) { score += 1.0; factors++; }
            if (inRange(ph, c.getIdealPhMin(), c.getIdealPhMax())) { score += 1.0; factors++; }
            if (inRange(rainfall, c.getIdealRainfallMin(), c.getIdealRainfallMax())) { score += 1.0; factors++; }
            int totalFactors = 5;
            double confidence = factors == 0 ? 0.0 : (score / totalFactors) * 100.0;
            scored.add(new ScoredCrop(c, confidence));
        }

        ScoredCrop best = scored.stream()
                .max(Comparator.comparingDouble(s -> s.confidence))
                .orElseThrow();

        Recommendation rec = Recommendation.builder()
                .user(user)
                .crop(best.crop)
                .confidenceScore(best.confidence)
                .build();
        rec = recommendationRepository.save(rec);
        log.info("Recommendation saved: user={}, crop={}, score={}", userId, best.crop.getCropName(), best.confidence);

        return RecommendationResponse.builder()
                .recommendationId(rec.getId())
                .cropName(best.crop.getCropName())
                .confidenceScore(best.confidence)
                .message(String.format("Best match: %s (%.1f%% confidence)", best.crop.getCropName(), best.confidence))
                .build();
    }

    private boolean inRange(double value, double min, double max) {
        return value >= min && value <= max;
    }

    private record ScoredCrop(Crop crop, double confidence) {}

    /**
     * Get multiple crop recommendations sorted by confidence score.
     * Uses SQL: ORDER BY confidence_score DESC LIMIT N
     */
    public MultipleRecommendationResponse getMultipleRecommendations(Long userId, User user, RecommendationRequest request, int limit) {
        SoilDataRequest soil = request.getSoilData();
        double nitrogen = soil.getNitrogen();
        double phosphorus = soil.getPhosphorus();
        double potassium = soil.getPotassium();
        double ph = soil.getPh();
        double rainfall = 0.0;

        if (request.getLocation() != null && !request.getLocation().isBlank()) {
            Optional<com.crop.entity.WeatherData> weather = weatherService.getLatestForLocation(request.getLocation());
            if (weather.isPresent()) {
                rainfall = weather.get().getRainfall();
            } else {
                try {
                    rainfall = weatherService.fetchAndStoreWeather(request.getLocation()).getRainfall();
                } catch (Exception e) {
                    log.warn("Could not fetch weather for recommendation: {}", e.getMessage());
                }
            }
        }

        List<Crop> crops = cropRepository.findAll();
        if (crops.isEmpty()) {
            return MultipleRecommendationResponse.builder()
                    .recommendations(List.of())
                    .totalCount(0)
                    .message("No crops in database.")
                    .build();
        }

        List<ScoredCrop> scored = new ArrayList<>();
        for (Crop c : crops) {
            double score = 0.0;
            int factors = 0;
            if (inRange(nitrogen, c.getIdealNMin(), c.getIdealNMax())) { score += 1.0; factors++; }
            if (inRange(phosphorus, c.getIdealPMin(), c.getIdealPMax())) { score += 1.0; factors++; }
            if (inRange(potassium, c.getIdealKMin(), c.getIdealKMax())) { score += 1.0; factors++; }
            if (inRange(ph, c.getIdealPhMin(), c.getIdealPhMax())) { score += 1.0; factors++; }
            if (inRange(rainfall, c.getIdealRainfallMin(), c.getIdealRainfallMax())) { score += 1.0; factors++; }
            int totalFactors = 5;
            double confidence = factors == 0 ? 0.0 : (score / totalFactors) * 100.0;
            scored.add(new ScoredCrop(c, confidence));
        }

        List<ScoredCrop> topCrops = scored.stream()
                .sorted(Comparator.comparingDouble((ScoredCrop s) -> s.confidence).reversed())
                .limit(limit)
                .collect(Collectors.toList());

        if (!topCrops.isEmpty()) {
            Recommendation rec = Recommendation.builder()
                    .user(user)
                    .crop(topCrops.get(0).crop)
                    .confidenceScore(topCrops.get(0).confidence)
                    .build();
            recommendationRepository.save(rec);
            log.info("Top recommendation saved: user={}, crop={}, score={}", userId, topCrops.get(0).crop.getCropName(), topCrops.get(0).confidence);
        }

        List<CropRecommendation> recommendations = new ArrayList<>();
        int rank = 1;
        for (ScoredCrop sc : topCrops) {
            recommendations.add(CropRecommendation.builder()
                    .rank(rank++)
                    .cropName(sc.crop.getCropName())
                    .confidenceScore(Math.round(sc.confidence * 10.0) / 10.0)
                    .build());
        }

        return MultipleRecommendationResponse.builder()
                .recommendations(recommendations)
                .totalCount(recommendations.size())
                .message(String.format("Found %d recommended crops (Top %d)", recommendations.size(), limit))
                .build();
    }
}
