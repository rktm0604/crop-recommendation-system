package com.crop.config;

import com.crop.entity.Crop;
import com.crop.entity.User;
import com.crop.entity.enums.Role;
import com.crop.repository.CropRepository;
import com.crop.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Loads default users and crop reference data on first run.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DataLoader implements CommandLineRunner {

    private final UserRepository userRepository;
    private final CropRepository cropRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        try {
            loadData();
        } catch (Exception e) {
            log.error("DataLoader failed (app will continue): {}", e.getMessage(), e);
        }
    }

    private void loadData() {
        String defaultPassword = passwordEncoder.encode("password123");
        if (!userRepository.existsByEmail("farmer@crop.com")) {
            userRepository.save(User.builder()
                    .name("John Farmer")
                    .email("farmer@crop.com")
                    .password(defaultPassword)
                    .role(Role.FARMER)
                    .build());
            log.info("Default farmer user created (farmer@crop.com / password123)");
        }
        if (cropRepository.count() == 0) {
            List<Crop> crops = List.of(
                    crop("Rice", 80, 120, 30, 50, 30, 50, 5.0, 7.0, 150, 300, 100, 90, 40, 40, 6.0),
                    crop("Wheat", 60, 100, 25, 45, 25, 45, 6.0, 7.5, 50, 100, 80, 35, 35, 6.8),
                    crop("Maize", 90, 150, 40, 80, 40, 80, 5.5, 7.5, 60, 120, 120, 60, 60, 6.5),
                    crop("Cotton", 70, 120, 35, 60, 35, 60, 5.5, 8.0, 50, 100, 95, 47, 47, 6.8),
                    crop("Sugarcane", 100, 180, 45, 90, 45, 90, 5.0, 8.5, 120, 250, 140, 67, 67, 6.8),
                    crop("Jute", 50, 90, 20, 40, 20, 40, 6.0, 7.5, 150, 300, 70, 30, 30, 6.8),
                    crop("Coconut", 40, 80, 20, 35, 40, 80, 5.0, 8.0, 100, 250, 60, 27, 60, 6.5),
                    crop("Papaya", 60, 100, 30, 50, 40, 70, 5.5, 7.0, 100, 200, 80, 40, 55, 6.3),
                    crop("Orange", 70, 110, 35, 55, 40, 75, 5.5, 7.5, 60, 150, 90, 45, 57, 6.5),
                    crop("Apple", 50, 90, 25, 45, 50, 90, 5.5, 7.0, 50, 120, 70, 35, 70, 6.3),
                    crop("Grapes", 60, 100, 30, 50, 50, 90, 5.5, 7.5, 40, 100, 80, 40, 70, 6.5),
                    crop("Mango", 55, 95, 25, 45, 40, 75, 5.5, 7.5, 80, 200, 75, 35, 57, 6.5),
                    crop("Bean", 40, 80, 25, 45, 35, 65, 6.0, 7.5, 50, 150, 60, 35, 50, 6.8),
                    crop("Lentil", 30, 70, 20, 40, 25, 55, 5.5, 7.5, 40, 100, 50, 30, 40, 6.5),
                    crop("Chickpea", 35, 75, 25, 45, 30, 60, 5.5, 7.5, 40, 100, 55, 35, 45, 6.5));
            cropRepository.saveAll(crops);
            log.info("Loaded {} default crops", crops.size());
        }
    }

    private static Crop crop(String name, double nMin, double nMax, double pMin, double pMax,
            double kMin, double kMax, double phMin, double phMax, double rainMin, double rainMax,
            double rainAvg, double nAvg, double pAvg, double kAvg, double phAvg) {
        return Crop.builder()
                .cropName(name)
                .idealNMin(nMin).idealNMax(nMax)
                .idealPMin(pMin).idealPMax(pMax)
                .idealKMin(kMin).idealKMax(kMax)
                .idealPhMin(phMin).idealPhMax(phMax)
                .idealRainfallMin(rainMin).idealRainfallMax(rainMax)
                .rainAvg(rainAvg)
                .nAvg(nAvg)
                .pAvg(pAvg)
                .kAvg(kAvg)
                .phAvg(phAvg)
                .build();
    }
}
