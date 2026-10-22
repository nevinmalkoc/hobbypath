package com.hobbypath.event.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EventReservationResponse {
    private Long eventId;
    private Long userId;
    private String status; // HELD, CONFIRMED, WAITLIST, FULL
    private Long remainingSeconds;
    private Instant expiresAt;
    private String message;
}
