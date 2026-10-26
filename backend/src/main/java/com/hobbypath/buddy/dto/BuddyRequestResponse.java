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
public class BuddyRequestResponse {
    private Long id;
    private Long creatorId;
    private String creatorUsername;
    private String creatorFullName;
    private String creatorAvatar;
    private String creatorGender;
    private Long hobbyId;
    private String hobbyName;
    private String hobbyIcon;
    private String title;
    private String description;
    private String intention;
    private String genderPreference;
    private String location;
    private String preferredTime;
    private String status;
    private Instant createdAt;
    private int matchCount;
    private boolean hasApplied;
}
