package com.crop.controller;

import com.crop.dto.SoilDataRequest;
import com.crop.entity.SoilData;
import com.crop.entity.User;
import com.crop.repository.UserRepository;
import com.crop.service.SoilDataService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/soil")
@RequiredArgsConstructor
public class SoilDataController {

    private final SoilDataService soilDataService;
    private final UserRepository userRepository;

    @PostMapping
    public ResponseEntity<SoilData> create(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody SoilDataRequest request) {
        User user = userRepository.findByEmail(userDetails.getUsername()).orElseThrow();
        SoilData created = soilDataService.create(user.getId(), user, request);
        return ResponseEntity.ok(created);
    }

    @GetMapping
    public ResponseEntity<List<SoilData>> list(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "20") int limit) {
        User user = userRepository.findByEmail(userDetails.getUsername()).orElseThrow();
        return ResponseEntity.ok(soilDataService.findByUserId(user.getId(), limit));
    }
}
