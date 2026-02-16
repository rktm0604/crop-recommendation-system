package com.crop.repository;

import com.crop.entity.Recommendation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecommendationRepository extends JpaRepository<Recommendation, Long> {

    List<Recommendation> findByUserIdOrderByRecommendationDateDesc(Long userId,
            org.springframework.data.domain.Pageable pageable);

    List<Recommendation> findByUserId(Long userId);

    @Query("SELECT r.crop.cropName, COUNT(r) as cnt FROM Recommendation r GROUP BY r.crop.cropName ORDER BY cnt DESC")
    List<Object[]> countRecommendationsByCropName(org.springframework.data.domain.Pageable pageable);

    @Query("SELECT r FROM Recommendation r JOIN FETCH r.crop WHERE r.user.id = :userId ORDER BY r.recommendationDate DESC")
    List<Recommendation> findByUserIdWithCrop(@Param("userId") Long userId,
            org.springframework.data.domain.Pageable pageable);
}
