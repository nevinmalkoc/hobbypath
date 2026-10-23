package com.hobbypath.chat.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageResponse {
    private Long id;
    private Long senderId;
    private String senderUsername;
    private String senderFullName;
    private Long communityId;
    private String content;
    private String type;
    private Instant sentAt;
}
