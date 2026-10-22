package com.hobbypath.community.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommunityResponse {

    private Long id;
    private String name;
    private String description;
    private Long hobbyId;
    private String hobbyName;
    private String hobbyIcon;
    private String creatorUsername;
    private int memberCount;
    private boolean isMember;
    private Instant createdAt;
}
