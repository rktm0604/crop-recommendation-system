package com.crop.service;

import com.crop.repository.RecommendationRepository;
import com.crop.repository.SoilDataRepository;
import com.crop.repository.WeatherDataRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Aggregates data for dashboard charts: NPK trends, top crops, rainfall.
 */
@Service
@RequiredArgsConstructor
public class DashboardService {

    private final SoilDataRepository soilDataRepository;
    private final RecommendationRepository recommendationRepository;
    private final WeatherDataRepository weatherDataRepository;

    @Transactional(readOnly = true)
    public Map<String, Object> getFarmerDashboard(Long userId) {
        Map<String, Object> model = new HashMap<>();
        var soilList = soilDataRepository.findByUserIdOrderByRecordedDateDesc(userId, PageRequest.of(0, 20));
        var recList = recommendationRepository.findByUserIdWithCrop(userId, PageRequest.of(0, 10));

        model.put("npkLabels", soilList.stream()
                .map(s -> s.getRecordedDate().toString().substring(0, 16))
                .collect(Collectors.toList()));
        model.put("nitrogen", soilList.stream().map(s -> s.getNitrogen()).collect(Collectors.toList()));
        model.put("phosphorus", soilList.stream().map(s -> s.getPhosphorus()).collect(Collectors.toList()));
        model.put("potassium", soilList.stream().map(s -> s.getPotassium()).collect(Collectors.toList()));
        model.put("recommendations", recList);
        return model;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getAdminDashboard() {
        Map<String, Object> model = new HashMap<>();
        var topCrops = recommendationRepository.countRecommendationsByCropName(PageRequest.of(0, 10));
        model.put("topCropNames", topCrops.stream().map(o -> (String) o[0]).collect(Collectors.toList()));
        model.put("topCropCounts", topCrops.stream().map(o -> ((Number) o[1]).longValue()).collect(Collectors.toList()));
        return model;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getOfficerDashboard(String location) {
        Map<String, Object> model = new HashMap<>();
        var weatherList = location != null && !location.isBlank()
                ? weatherDataRepository.findByLocationOrderByRecordedDateDesc(location, PageRequest.of(0, 20))
                : weatherDataRepository.findAll(PageRequest.of(0, 20)).getContent();
        model.put("rainfallLabels", weatherList.stream()
                .map(w -> w.getRecordedDate().toString().substring(0, 16))
                .collect(Collectors.toList()));
        model.put("rainfall", weatherList.stream().map(w -> w.getRainfall()).collect(Collectors.toList()));
        model.put("temperature", weatherList.stream().map(w -> w.getTemperature()).collect(Collectors.toList()));
        return model;
    }
}
