package com.hobbypath.hobby.controller;

import com.hobbypath.hobby.dto.HobbyResponse;
import com.hobbypath.hobby.service.HobbyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/hobbies")
@RequiredArgsConstructor
public class HobbyController {

    private final HobbyService hobbyService;

    @GetMapping
    public ResponseEntity<List<HobbyResponse>> getAllHobbies() {
        return ResponseEntity.ok(hobbyService.getAllHobbies());
    }

    @GetMapping("/{id}")
    public ResponseEntity<HobbyResponse> getHobbyById(@PathVariable Long id) {
        return ResponseEntity.ok(hobbyService.getHobbyById(id));
    }
}
