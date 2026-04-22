package com.crop.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MultipleRecommendationResponse {

    private List<CropRecommendation> recommendations;
    private Integer totalCount;
    private String message;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CropRecommendation {
        private Integer rank;
        private String cropName;
        private Double confidenceScore;
    }
}