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
public class ReservationStatusResponse {
    private Long eventId;
    private boolean hasActiveReservation;
    private Long remainingSeconds;
    private Instant expiresAt;
    private int capacity;
    private int currentParticipants;
    private int activeHoldsCount;
    private int availableSlots;
}
