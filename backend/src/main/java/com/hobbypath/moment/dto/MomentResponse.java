package com.hobbypath.moment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MomentResponse {
    private Long id;
    private Long userId;
    private String username;
    private String userFullName;
    private String userAvatar;
    private Long hobbyId;
    private String hobbyName;
    private String hobbyIcon;
    private Long communityId;
    private String communityName;
    private String caption;
    private String imageUrl;
    private int likesCount;
    private boolean likedByMe;
    private Instant createdAt;
}
