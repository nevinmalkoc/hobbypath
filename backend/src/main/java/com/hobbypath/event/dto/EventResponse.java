package com.hobbypath.event.dto;

import com.hobbypath.event.entity.EventStatus;
import com.hobbypath.event.entity.ParticipantStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EventResponse {

    private Long id;
    private String title;
    private String description;
    private Long communityId;
    private String communityName;
    private String hobbyName;
    private String hobbyIcon;
    private String organizerUsername;
    private String location;
    private Double latitude;
    private Double longitude;
    private String city;
    private String district;
    private Instant eventDate;
    private int capacity;
    private int currentParticipants;
    private ParticipantStatus userStatus;
    private EventStatus status;
}
