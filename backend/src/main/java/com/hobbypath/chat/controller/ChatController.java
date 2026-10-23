package com.hobbypath.chat.controller;

import com.hobbypath.chat.dto.ChatMessageRequest;
import com.hobbypath.chat.dto.ChatMessageResponse;
import com.hobbypath.chat.service.ChatService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
@Slf4j
public class ChatController {

    private final ChatService chatService;

    @GetMapping("/communities/{communityId}/messages")
    public ResponseEntity<List<ChatMessageResponse>> getCommunityMessages(
            @PathVariable Long communityId,
            @RequestParam(defaultValue = "50") int limit
    ) {
        return ResponseEntity.ok(chatService.getRecentCommunityMessages(communityId, limit));
    }

    @PostMapping("/communities/{communityId}/messages")
    public ResponseEntity<ChatMessageResponse> sendCommunityMessage(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long communityId,
            @Valid @RequestBody ChatMessageRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(chatService.sendCommunityMessage(currentUser, communityId, request));
    }

    /**
     * STOMP WebSocket Message Mapping
     * Clients send to: /app/chat.send.{communityId}
     */
    @MessageMapping("/chat.send.{communityId}")
    public void handleWebSocketMessage(
            @DestinationVariable Long communityId,
            @Payload ChatMessageRequest request,
            Principal principal
    ) {
        log.info("Received WebSocket chat message for community {} from principal {}",
                communityId, principal != null ? principal.getName() : "anonymous");
        // WebSocket clients will also broadcast via SimpMessagingTemplate in ChatService
    }
}
