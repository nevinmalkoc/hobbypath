package com.hobbypath.buddy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BuddyMatchResponse {
    private Long id;
    private Long requestId;
    private String requestTitle;
    private Long applicantId;
    private String applicantUsername;
    private String applicantFullName;
    private String applicantAvatar;
    private String message;
    private String status;
    private Instant createdAt;
}
