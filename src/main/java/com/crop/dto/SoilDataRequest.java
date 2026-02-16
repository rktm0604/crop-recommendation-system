package com.crop.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SoilDataRequest {

    @NotNull
    private Double nitrogen;

    @NotNull
    private Double phosphorus;

    @NotNull
    private Double potassium;

    @NotNull
    private Double ph;

    @NotNull
    private Double moisture;
}
