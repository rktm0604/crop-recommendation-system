package com.crop.controller;

import com.crop.dto.RecommendationRequest;
import com.crop.dto.RecommendationResponse;
import com.crop.entity.User;
import com.crop.repository.UserRepository;
import com.crop.service.RecommendationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/recommendation")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<RecommendationResponse> getRecommendation(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody RecommendationRequest request) {
        User user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow();
        RecommendationResponse response = recommendationService.getRecommendation(user.getId(), user, request);
        return ResponseEntity.ok(response);
    }
}
