package com.crop.repository;

import com.crop.entity.WeatherData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface WeatherDataRepository extends JpaRepository<WeatherData, Long> {

    List<WeatherData> findByLocationOrderByRecordedDateDesc(String location,
            org.springframework.data.domain.Pageable pageable);

    @Query("SELECT w FROM WeatherData w WHERE w.location = :location ORDER BY w.recordedDate DESC")
    List<WeatherData> findLatestByLocation(@Param("location") String location,
            org.springframework.data.domain.Pageable pageable);

    Optional<WeatherData> findFirstByLocationOrderByRecordedDateDesc(String location);

    List<WeatherData> findByLocationAndRecordedDateAfter(String location, LocalDateTime since);
}
