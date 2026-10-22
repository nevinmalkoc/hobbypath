package com.hobbypath.user.controller;

import com.hobbypath.hobby.dto.AddHobbyRequest;
import com.hobbypath.hobby.dto.UserHobbyResponse;
import com.hobbypath.user.dto.UpdateProfileRequest;
import com.hobbypath.user.dto.UserProfileResponse;
import com.hobbypath.user.entity.User;
import com.hobbypath.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/profile")
    public ResponseEntity<UserProfileResponse> getProfile(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(userService.getUserProfile(user));
    }

    @PutMapping("/profile")
    public ResponseEntity<UserProfileResponse> updateProfile(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        return ResponseEntity.ok(userService.updateProfile(user, request));
    }

    @PostMapping("/hobbies")
    public ResponseEntity<UserHobbyResponse> addOrUpdateHobby(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody AddHobbyRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.addOrUpdateUserHobby(user, request));
    }

    @DeleteMapping("/hobbies/{hobbyId}")
    public ResponseEntity<Void> removeHobby(
            @AuthenticationPrincipal User user,
            @PathVariable Long hobbyId
    ) {
        userService.removeUserHobby(user, hobbyId);
        return ResponseEntity.noContent().build();
    }
}
