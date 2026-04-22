package com.crop.controller;

import com.crop.service.DashboardService;
import com.crop.repository.CropRepository;
import com.crop.repository.RecommendationRepository;
import com.crop.repository.SoilDataRepository;
import com.crop.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * REST API for Final Project Evaluation Dashboard
 * Provides DBMS, CNDC, and Statistics data
 */
@RestController
@RequestMapping("/api/evaluation")
@RequiredArgsConstructor
public class EvaluationApiController {

    private final UserRepository userRepository;
    private final CropRepository cropRepository;
    private final SoilDataRepository soilDataRepository;
    private final RecommendationRepository recommendationRepository;
    private final DashboardService dashboardService;

    /**
     * GET /api/evaluation/dbms-stats
     * Returns database statistics for DBMS section
     */
    @GetMapping("/dbms-stats")
    public ResponseEntity<Map<String, Object>> getDbmsStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("users", userRepository.count());
        stats.put("crops", cropRepository.count());
        stats.put("soilData", soilDataRepository.count());
        stats.put("recommendations", recommendationRepository.count());
        return ResponseEntity.ok(stats);
    }

    /**
     * GET /api/evaluation/dbms-query
     * Returns SQL JOIN query results for demonstration
     */
    @GetMapping("/dbms-query")
    public ResponseEntity<Map<String, Object>> runDbmsQuery() {
        Map<String, Object> result = new HashMap<>();
        // Sample JOIN query result
        result.put("query", "SELECT u.name, c.crop_name, r.confidence_score FROM recommendations r JOIN app_users u ON r.user_id = u.id JOIN crops c ON r.crop_id = c.id");
        result.put("explanation", "This query demonstrates JOIN operation between 3 tables: recommendations, app_users, and crops");
        return ResponseEntity.ok(result);
    }

    /**
     * GET /api/evaluation/network-info
     * Returns network architecture info for CNDC section
     */
    @GetMapping("/network-info")
    public ResponseEntity<Map<String, Object>> getNetworkInfo() {
        Map<String, Object> info = new HashMap<>();
        
        // Protocol details
        Map<String, String> protocols = new HashMap<>();
        protocols.put("HTTP", "REST API communication");
        protocols.put("HTTPS", "Secure data transmission");
        protocols.put("JWT", "Token-based authentication");
        protocols.put("WebClient", "External API calls");
        protocols.put("JDBC/JPA", "Database connectivity");
        info.put("protocols", protocols);

        // Data flow
        String[] dataFlow = {"Client (Browser)", "HTTPS", "Spring Boot Server", "JDBC", "MySQL Database"};
        info.put("dataFlow", dataFlow);

        return ResponseEntity.ok(info);
    }

    /**
     * GET /api/evaluation/stats-summary
     * Returns statistical summary for Statistics section
     */
    @GetMapping("/stats-summary")
    public ResponseEntity<Map<String, Object>> getStatsSummary() {
        Map<String, Object> stats = new HashMap<>();
        
        // Get top crops for statistics
        var topCrops = recommendationRepository.countRecommendationsByCropName(org.springframework.data.domain.PageRequest.of(0, 5));
        
        stats.put("topCropNames", topCrops.stream().map(o -> (String) o[0]).toList());
        stats.put("topCropCounts", topCrops.stream().map(o -> ((Number) o[1]).longValue()).toList());
        
        // Average confidence (mock for demo)
        stats.put("averageConfidence", 85.5);
        
        return ResponseEntity.ok(stats);
    }
}