package com.hobbypath.gear.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GearTransferResponse {
    private Long id;
    private Long ownerId;
    private String ownerUsername;
    private String ownerFullName;
    private String ownerAvatar;
    private Long hobbyId;
    private String hobbyName;
    private String hobbyIcon;
    private String title;
    private String description;
    private String transferType;
    private String itemCondition;
    private String location;
    private String contactInfo;
    private String imageUrl;
    private String status;
    private Instant createdAt;
}
