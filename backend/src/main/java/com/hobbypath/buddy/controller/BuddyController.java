package com.hobbypath.buddy.controller;

import com.hobbypath.buddy.dto.BuddyMatchResponse;
import com.hobbypath.buddy.dto.BuddyRequestResponse;
import com.hobbypath.buddy.dto.ConnectBuddyRequest;
import com.hobbypath.buddy.dto.CreateBuddyRequest;
import com.hobbypath.buddy.entity.BuddyIntention;
import com.hobbypath.buddy.entity.GenderPreference;
import com.hobbypath.buddy.entity.MatchStatus;
import com.hobbypath.buddy.service.BuddyService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/buddy")
@RequiredArgsConstructor
public class BuddyController {

    private final BuddyService buddyService;

    @GetMapping("/requests")
    public ResponseEntity<List<BuddyRequestResponse>> getBuddyRequests(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) Long hobbyId,
            @RequestParam(required = false) BuddyIntention intention,
            @RequestParam(required = false) GenderPreference genderPreference
    ) {
        return ResponseEntity.ok(buddyService.getBuddyRequests(user, hobbyId, intention, genderPreference));
    }

    @GetMapping("/my-requests")
    public ResponseEntity<List<BuddyRequestResponse>> getMyRequests(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(buddyService.getMyRequests(user));
    }

    @PostMapping("/requests")
    public ResponseEntity<BuddyRequestResponse> createBuddyRequest(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CreateBuddyRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED).body(buddyService.createBuddyRequest(user, request));
    }

    @PostMapping("/requests/{id}/connect")
    public ResponseEntity<BuddyMatchResponse> connect(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @Valid @RequestBody(required = false) ConnectBuddyRequest request
    ) {
        return ResponseEntity.ok(buddyService.connectToBuddyRequest(user, id, request));
    }

    @PatchMapping("/matches/{matchId}/status")
    public ResponseEntity<BuddyMatchResponse> updateMatchStatus(
            @AuthenticationPrincipal User user,
            @PathVariable Long matchId,
            @RequestParam MatchStatus status
    ) {
        return ResponseEntity.ok(buddyService.updateMatchStatus(user, matchId, status));
    }
}
