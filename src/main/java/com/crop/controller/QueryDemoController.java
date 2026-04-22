package com.crop.controller;

import com.crop.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/evaluation")
@RequiredArgsConstructor
public class QueryDemoController {

    private final UserRepository userRepository;
    private final CropRepository cropRepository;
    private final RecommendationRepository recommendationRepository;

    /**
     * Query 1: SELECT with JOIN
     */
    @GetMapping("/query-join")
    public ResponseEntity<List<Map<String, Object>>> getJoinQuery() {
        var recs = recommendationRepository.findAll();
        List<Map<String, Object>> result = new ArrayList<>();
        for (var rec : recs) {
            Map<String, Object> row = new HashMap<>();
            row.put("farmerName", rec.getUser().getName());
            row.put("cropName", rec.getCrop().getCropName());
            row.put("confidenceScore", rec.getConfidenceScore().intValue());
            result.add(row);
            if (result.size() >= 5) break;
        }
        return ResponseEntity.ok(result);
    }

    /**
     * Query 2: GROUP BY
     */
    @GetMapping("/query-groupby")
    public ResponseEntity<List<Map<String, Object>>> getGroupByQuery() {
        var crops = recommendationRepository.countRecommendationsByCropName(org.springframework.data.domain.PageRequest.of(0, 10));
        List<Map<String, Object>> result = new ArrayList<>();
        for (var row : crops) {
            Map<String, Object> map = new HashMap<>();
            map.put("cropName", (String) row[0]);
            map.put("total", ((Number) row[1]).longValue());
            map.put("avgConfidence", Math.round((Double) row[2] * 10.0) / 10.0);
            result.add(map);
        }
        return ResponseEntity.ok(result);
    }

    /**
     * Query 3: Nested Query
     */
    @GetMapping("/query-nested")
    public ResponseEntity<List<Map<String, Object>>> getNestedQuery() {
        var crops = recommendationRepository.countRecommendationsByCropName(org.springframework.data.domain.PageRequest.of(0, 10));
        double avg = recommendationRepository.findAll().stream()
            .mapToDouble(r -> r.getConfidenceScore())
            .average().orElse(0);
        
        List<Map<String, Object>> result = new ArrayList<>();
        for (var row : crops) {
            double cropAvg = (Double) row[2];
            if (cropAvg >= avg) {
                Map<String, Object> map = new HashMap<>();
                map.put("cropName", (String) row[0]);
                map.put("avgConfidence", Math.round(cropAvg * 10.0) / 10.0);
                result.add(map);
            }
        }
        return ResponseEntity.ok(result);
    }

    /**
     * Query 4: WHERE
     */
    @GetMapping("/query-where")
    public ResponseEntity<List<Map<String, Object>>> getWhereQuery() {
        var recs = recommendationRepository.findByConfidenceScoreGreaterThan(80.0);
        List<Map<String, Object>> result = new ArrayList<>();
        for (var rec : recs) {
            Map<String, Object> row = new HashMap<>();
            row.put("farmerName", rec.getUser().getName());
            row.put("cropName", rec.getCrop().getCropName());
            row.put("confidenceScore", rec.getConfidenceScore().intValue());
            row.put("date", rec.getRecommendationDate().toString().substring(0, 10));
            result.add(row);
        }
        return ResponseEntity.ok(result);
    }
}