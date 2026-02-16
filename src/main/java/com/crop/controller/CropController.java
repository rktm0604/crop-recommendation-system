package com.crop.controller;

import com.crop.entity.Crop;
import com.crop.repository.CropRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Crop CRUD for admin. Read-only for others.
 */
@RestController
@RequestMapping("/api/crops")
@RequiredArgsConstructor
public class CropController {

    private final CropRepository cropRepository;

    @GetMapping
    public ResponseEntity<List<Crop>> list() {
        return ResponseEntity.ok(cropRepository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Crop> getById(@PathVariable Long id) {
        return ResponseEntity.ok(cropRepository.findById(id)
                .orElseThrow(() -> new com.crop.exception.ResourceNotFoundException("Crop", id)));
    }
}
