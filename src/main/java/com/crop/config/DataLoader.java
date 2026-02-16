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
        if (!userRepository.existsByEmail("admin@crop.com")) {
            userRepository.save(User.builder()
                    .name("Admin User")
                    .email("admin@crop.com")
                    .password(defaultPassword)
                    .role(Role.ADMIN)
                    .build());
            log.info("Default admin user created (admin@crop.com / password123)");
        }
        if (!userRepository.existsByEmail("farmer@crop.com")) {
            userRepository.save(User.builder()
                    .name("John Farmer")
                    .email("farmer@crop.com")
                    .password(defaultPassword)
                    .role(Role.FARMER)
                    .build());
            log.info("Default farmer user created (farmer@crop.com / password123)");
        }
        if (!userRepository.existsByEmail("officer@crop.com")) {
            userRepository.save(User.builder()
                    .name("Jane Officer")
                    .email("officer@crop.com")
                    .password(defaultPassword)
                    .role(Role.OFFICER)
                    .build());
            log.info("Default officer user created (officer@crop.com / password123)");
        }
        if (cropRepository.count() == 0) {
            List<Crop> crops = List.of(
                    crop("Rice", 80, 120, 30, 50, 30, 50, 5.0, 7.0, 150, 300),
                    crop("Wheat", 60, 100, 25, 45, 25, 45, 6.0, 7.5, 50, 100),
                    crop("Maize", 90, 150, 40, 80, 40, 80, 5.5, 7.5, 60, 120),
                    crop("Cotton", 70, 120, 35, 60, 35, 60, 5.5, 8.0, 50, 100),
                    crop("Sugarcane", 100, 180, 45, 90, 45, 90, 5.0, 8.5, 120, 250),
                    crop("Jute", 50, 90, 20, 40, 20, 40, 6.0, 7.5, 150, 300),
                    crop("Coconut", 40, 80, 20, 35, 40, 80, 5.0, 8.0, 100, 250),
                    crop("Papaya", 60, 100, 30, 50, 40, 70, 5.5, 7.0, 100, 200),
                    crop("Orange", 70, 110, 35, 55, 40, 75, 5.5, 7.5, 60, 150),
                    crop("Apple", 50, 90, 25, 45, 50, 90, 5.5, 7.0, 50, 120),
                    crop("Grapes", 60, 100, 30, 50, 50, 90, 5.5, 7.5, 40, 100),
                    crop("Mango", 55, 95, 25, 45, 40, 75, 5.5, 7.5, 80, 200),
                    crop("Bean", 40, 80, 25, 45, 35, 65, 6.0, 7.5, 50, 150),
                    crop("Lentil", 30, 70, 20, 40, 25, 55, 5.5, 7.5, 40, 100),
                    crop("Chickpea", 35, 75, 25, 45, 30, 60, 5.5, 7.5, 40, 100));
            cropRepository.saveAll(crops);
            log.info("Loaded {} default crops", crops.size());
        }
    }

    private static Crop crop(String name, double nMin, double nMax, double pMin, double pMax,
            double kMin, double kMax, double phMin, double phMax, double rainMin, double rainMax) {
        return Crop.builder()
                .cropName(name)
                .idealNMin(nMin).idealNMax(nMax)
                .idealPMin(pMin).idealPMax(pMax)
                .idealKMin(kMin).idealKMax(kMax)
                .idealPhMin(phMin).idealPhMax(phMax)
                .idealRainfallMin(rainMin).idealRainfallMax(rainMax)
                .build();
    }
}
