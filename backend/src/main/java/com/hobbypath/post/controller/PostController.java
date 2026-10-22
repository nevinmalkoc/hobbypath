package com.hobbypath.post.controller;

import com.hobbypath.post.dto.CreatePostRequest;
import com.hobbypath.post.dto.PostResponse;
import com.hobbypath.post.service.PostService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/communities/{communityId}/posts")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    @GetMapping
    public ResponseEntity<List<PostResponse>> getCommunityPosts(@PathVariable Long communityId) {
        return ResponseEntity.ok(postService.getCommunityPosts(communityId));
    }

    @PostMapping
    public ResponseEntity<PostResponse> createPost(
            @AuthenticationPrincipal User author,
            @PathVariable Long communityId,
            @Valid @RequestBody CreatePostRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(postService.createPost(author, communityId, request));
    }
}
