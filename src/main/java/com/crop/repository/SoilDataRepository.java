package com.crop.repository;

import com.crop.entity.SoilData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SoilDataRepository extends JpaRepository<SoilData, Long> {

    List<SoilData> findByUserIdOrderByRecordedDateDesc(Long userId, org.springframework.data.domain.Pageable pageable);

    List<SoilData> findByUserId(Long userId);

    @Query("SELECT s FROM SoilData s WHERE s.user.id = :userId AND s.recordedDate >= :since ORDER BY s.recordedDate DESC")
    List<SoilData> findByUserIdAndRecordedDateAfter(@Param("userId") Long userId, @Param("since") LocalDateTime since);
}
