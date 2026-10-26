package com.hobbypath.puzzle.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaderboardEntryResponse {
    private int rank;
    private Long userId;
    private String username;
    private String fullName;
    private int completionTimeSeconds;
    private Instant solvedAt;
}
