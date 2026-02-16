package com.crop.controller;

import com.crop.entity.enums.Role;
import com.crop.repository.UserRepository;
import com.crop.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * REST API for dashboard chart data (consumed by frontend with Chart.js).
 */
@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardApiController {

    private final DashboardService dashboardService;
    private final UserRepository userRepository;

    @GetMapping("/farmer")
    public ResponseEntity<Map<String, Object>> farmerData(@AuthenticationPrincipal UserDetails userDetails) {
        var user = userRepository.findByEmail(userDetails.getUsername()).orElseThrow();
        return ResponseEntity.ok(dashboardService.getFarmerDashboard(user.getId()));
    }

    @GetMapping("/admin")
    public ResponseEntity<Map<String, Object>> adminData() {
        return ResponseEntity.ok(dashboardService.getAdminDashboard());
    }

    @GetMapping("/officer")
    public ResponseEntity<Map<String, Object>> officerData(
            @RequestParam(required = false) String location) {
        return ResponseEntity.ok(dashboardService.getOfficerDashboard(location));
    }
}
