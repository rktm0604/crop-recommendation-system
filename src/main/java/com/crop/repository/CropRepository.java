package com.crop.repository;

import com.crop.entity.Crop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CropRepository extends JpaRepository<Crop, Long> {

    Optional<Crop> findByCropName(String cropName);

    boolean existsByCropName(String cropName);

    @Query("SELECT c.cropName, c.rainAvg, c.nAvg, c.pAvg, c.kAvg, c.phAvg FROM Crop c ORDER BY c.cropName")
    List<Object[]> getAllCropStats();
}
