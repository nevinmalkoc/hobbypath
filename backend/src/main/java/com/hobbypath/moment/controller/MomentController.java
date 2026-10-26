package com.hobbypath.moment.controller;

import com.hobbypath.moment.dto.CreateMomentRequest;
import com.hobbypath.moment.dto.MomentResponse;
import com.hobbypath.moment.service.MomentService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/moments")
@RequiredArgsConstructor
public class MomentController {

    private final MomentService momentService;

    @GetMapping
    public ResponseEntity<List<MomentResponse>> getRecentMoments(
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(momentService.getRecentMoments(currentUser));
    }

    @PostMapping
    public ResponseEntity<MomentResponse> createMoment(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateMomentRequest request
    ) {
        return ResponseEntity.ok(momentService.createMoment(currentUser, request));
    }

    @PostMapping("/{id}/like")
    public ResponseEntity<MomentResponse> toggleLike(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(momentService.toggleLike(currentUser, id));
    }
}
