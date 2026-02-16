package com.crop.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Stored recommendation linking user, crop, and confidence score.
 */
@Entity
@Table(name = "recommendations", indexes = {
        @Index(name = "idx_recommendation_user_id", columnList = "user_id"),
        @Index(name = "idx_recommendation_crop_id", columnList = "crop_id"),
        @Index(name = "idx_recommendation_date", columnList = "recommendation_date")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Recommendation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonIgnore
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_recommendation_user"))
    private User user;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false, foreignKey = @ForeignKey(name = "fk_recommendation_crop"))
    private Crop crop;

    @NotNull
    @Column(nullable = false)
    private LocalDateTime recommendationDate;

    @NotNull
    @Column(nullable = false)
    private Double confidenceScore;

    @PrePersist
    protected void onCreate() {
        if (recommendationDate == null) {
            recommendationDate = LocalDateTime.now();
        }
    }
}
