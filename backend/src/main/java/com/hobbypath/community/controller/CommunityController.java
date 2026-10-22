package com.hobbypath.community.controller;

import com.hobbypath.community.dto.CommunityResponse;
import com.hobbypath.community.dto.CreateCommunityRequest;
import com.hobbypath.community.service.CommunityService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/communities")
@RequiredArgsConstructor
public class CommunityController {

    private final CommunityService communityService;

    @GetMapping
    public ResponseEntity<List<CommunityResponse>> getCommunities(
            @RequestParam(required = false) Long hobbyId,
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(communityService.getCommunities(hobbyId, currentUser));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CommunityResponse> getCommunityById(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(communityService.getCommunityById(id, currentUser));
    }

    @PostMapping
    public ResponseEntity<CommunityResponse> createCommunity(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateCommunityRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(communityService.createCommunity(currentUser, request));
    }

    @PostMapping("/{id}/join")
    public ResponseEntity<CommunityResponse> joinCommunity(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(communityService.joinCommunity(currentUser, id));
    }

    @PostMapping("/{id}/leave")
    public ResponseEntity<CommunityResponse> leaveCommunity(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(communityService.leaveCommunity(currentUser, id));
    }
}
