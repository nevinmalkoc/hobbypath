package com.hobbypath.ai.controller;

import com.hobbypath.ai.dto.AiChatRequest;
import com.hobbypath.ai.dto.AiChatResponse;
import com.hobbypath.ai.service.AiAssistantService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiAssistantService aiService;

    @PostMapping("/chat")
    public ResponseEntity<AiChatResponse> chat(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody AiChatRequest request
    ) {
        return ResponseEntity.ok(aiService.processMessage(currentUser, request));
    }
}
