package com.hobbypath.event.controller;

import com.hobbypath.event.dto.CreateEventRequest;
import com.hobbypath.event.dto.EventResponse;
import com.hobbypath.event.service.EventService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;
    private final com.hobbypath.event.service.EventReservationService reservationService;

    @GetMapping
    public ResponseEntity<List<EventResponse>> getUpcomingEvents(
            @RequestParam(required = false) Long hobbyId,
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(eventService.getUpcomingEvents(hobbyId, currentUser));
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventResponse> getEventById(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(eventService.getEventById(id, currentUser));
    }

    @PostMapping("/community/{communityId}")
    public ResponseEntity<EventResponse> createEvent(
            @AuthenticationPrincipal User organizer,
            @PathVariable Long communityId,
            @Valid @RequestBody CreateEventRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(eventService.createEvent(organizer, communityId, request));
    }

    @PostMapping("/{id}/join")
    public ResponseEntity<EventResponse> joinEvent(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(eventService.joinEvent(currentUser, id));
    }

    @PostMapping("/{id}/leave")
    public ResponseEntity<EventResponse> leaveEvent(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(eventService.leaveEvent(currentUser, id));
    }

    @PostMapping("/{id}/reserve")
    public ResponseEntity<com.hobbypath.event.dto.EventReservationResponse> reserveSlot(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(reservationService.holdSlot(currentUser, id));
    }

    @PostMapping("/{id}/confirm")
    public ResponseEntity<EventResponse> confirmReservation(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(reservationService.confirmHold(currentUser, id));
    }

    @DeleteMapping("/{id}/reserve")
    public ResponseEntity<Void> cancelReservation(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        reservationService.releaseHold(currentUser, id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/reservation-status")
    public ResponseEntity<com.hobbypath.event.dto.ReservationStatusResponse> getReservationStatus(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id
    ) {
        return ResponseEntity.ok(reservationService.getReservationStatus(id, currentUser));
    }
}
