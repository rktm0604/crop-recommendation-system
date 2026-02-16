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
}
