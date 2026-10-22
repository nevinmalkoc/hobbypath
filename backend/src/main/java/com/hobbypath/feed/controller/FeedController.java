package com.hobbypath.feed.controller;

import com.hobbypath.feed.dto.FeedResponse;
import com.hobbypath.feed.service.FeedService;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/feed")
@RequiredArgsConstructor
public class FeedController {

    private final FeedService feedService;

    @GetMapping
    public ResponseEntity<FeedResponse> getHomeFeed(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(feedService.getHomeFeed(currentUser));
    }
}
