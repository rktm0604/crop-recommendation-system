package com.crop.service;

import com.crop.dto.SoilDataRequest;
import com.crop.entity.SoilData;
import com.crop.entity.User;
import com.crop.exception.ResourceNotFoundException;
import com.crop.repository.SoilDataRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class SoilDataService {

    private final SoilDataRepository soilDataRepository;

    @Transactional
    public SoilData create(Long userId, User user, SoilDataRequest request) {
        SoilData data = SoilData.builder()
                .user(user)
                .nitrogen(request.getNitrogen())
                .phosphorus(request.getPhosphorus())
                .potassium(request.getPotassium())
                .ph(request.getPh())
                .moisture(request.getMoisture())
                .recordedDate(java.time.LocalDateTime.now())
                .build();
        data = soilDataRepository.save(data);
        log.info("Soil data saved for user {}: id={}", userId, data.getId());
        return data;
    }

    @Transactional(readOnly = true)
    public List<SoilData> findByUserId(Long userId, int limit) {
        return soilDataRepository.findByUserIdOrderByRecordedDateDesc(userId, PageRequest.of(0, limit));
    }

    @Transactional(readOnly = true)
    public SoilData getById(Long id) {
        return soilDataRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("SoilData", id));
    }
}
