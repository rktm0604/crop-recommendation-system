package com.crop.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

/**
 * Crop entity with ideal ranges for N, P, K, pH, rainfall.
 * Used by recommendation engine for rule-based matching.
 */
@Entity
@Table(name = "crops", indexes = {
        @Index(name = "idx_crop_name", columnList = "crop_name", unique = true)
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Crop {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Column(name = "crop_name", nullable = false, unique = true, length = 100)
    private String cropName;

    @NotNull
    @Column(nullable = false)
    private Double idealNMin;

    @NotNull
    @Column(nullable = false)
    private Double idealNMax;

    @NotNull
    @Column(nullable = false)
    private Double idealPMin;

    @NotNull
    @Column(nullable = false)
    private Double idealPMax;

    @NotNull
    @Column(nullable = false)
    private Double idealKMin;

    @NotNull
    @Column(nullable = false)
    private Double idealKMax;

    @NotNull
    @Column(nullable = false)
    private Double idealPhMin;

    @NotNull
    @Column(nullable = false)
    private Double idealPhMax;

    @NotNull
    @Column(nullable = false)
    private Double idealRainfallMin;

    @NotNull
    @Column(nullable = false)
    private Double idealRainfallMax;

    @Column(name = "rain_avg")
    private Double rainAvg;

    @Column(name = "n_avg")
    private Double nAvg;

    @Column(name = "p_avg")
    private Double pAvg;

    @Column(name = "k_avg")
    private Double kAvg;

    @Column(name = "ph_avg")
    private Double phAvg;

    @JsonIgnore
    @OneToMany(mappedBy = "crop", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Recommendation> recommendations = new ArrayList<>();
}
