package com.crop.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Soil data recorded by users (NPK, pH, moisture).
 * Used as input for crop recommendation engine.
 */
@Entity
@Table(name = "soil_data", indexes = {
        @Index(name = "idx_soil_user_id", columnList = "user_id"),
        @Index(name = "idx_soil_recorded_date", columnList = "recorded_date")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SoilData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonIgnore
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, foreignKey = @ForeignKey(name = "fk_soil_user"))
    private User user;

    @NotNull
    @Column(nullable = false)
    private Double nitrogen;

    @NotNull
    @Column(nullable = false)
    private Double phosphorus;

    @NotNull
    @Column(nullable = false)
    private Double potassium;

    @NotNull
    @Column(nullable = false)
    private Double ph;

    @NotNull
    @Column(nullable = false)
    private Double moisture;

    @NotNull
    @Column(nullable = false)
    private LocalDateTime recordedDate;

    @PrePersist
    protected void onCreate() {
        if (recordedDate == null) {
            recordedDate = LocalDateTime.now();
        }
    }
}
