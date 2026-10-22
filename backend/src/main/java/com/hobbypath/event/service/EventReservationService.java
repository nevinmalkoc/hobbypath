package com.hobbypath.event.service;

import com.hobbypath.event.dto.EventReservationResponse;
import com.hobbypath.event.dto.EventResponse;
import com.hobbypath.event.dto.ReservationStatusResponse;
import com.hobbypath.event.entity.Event;
import com.hobbypath.event.entity.EventParticipant;
import com.hobbypath.event.entity.EventStatus;
import com.hobbypath.event.entity.ParticipantStatus;
import com.hobbypath.event.repository.EventParticipantRepository;
import com.hobbypath.event.repository.EventRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class EventReservationService {

    public static final long HOLD_DURATION_SECONDS = 300L; // 5 minutes
    private static final String HOLD_PREFIX = "event:hold:";

    private final StringRedisTemplate redisTemplate;
    private final EventRepository eventRepository;
    private final EventParticipantRepository participantRepository;
    private final EventService eventService;

    /**
     * Attempts to temporarily reserve (hold) a slot for 5 minutes.
     */
    @Transactional(readOnly = true)
    public EventReservationResponse holdSlot(User user, Long eventId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found with id: " + eventId));

        if (event.getStatus() != EventStatus.UPCOMING) {
            throw new IllegalArgumentException("Cannot reserve a slot for an event that is not upcoming");
        }

        // Check if user is already registered in DB
        Optional<EventParticipant> existing = participantRepository.findByEventIdAndUserId(eventId, user.getId());
        if (existing.isPresent() && existing.get().getStatus() == ParticipantStatus.REGISTERED) {
            return EventReservationResponse.builder()
                    .eventId(eventId)
                    .userId(user.getId())
                    .status("ALREADY_REGISTERED")
                    .remainingSeconds(0L)
                    .message("Bu etkinliğe zaten kesin kaydınız bulunmaktadır.")
                    .build();
        }

        String userHoldKey = buildHoldKey(eventId, user.getId());

        // Check if user already holds a slot
        Long existingTtl = redisTemplate.getExpire(userHoldKey, TimeUnit.SECONDS);
        if (existingTtl != null && existingTtl > 0) {
            return EventReservationResponse.builder()
                    .eventId(eventId)
                    .userId(user.getId())
                    .status("HELD")
                    .remainingSeconds(existingTtl)
                    .expiresAt(Instant.now().plusSeconds(existingTtl))
                    .message("Zaten adınıza ayrılmış aktif bir kontenjanınız var. Kalan süre: " + existingTtl + " saniye.")
                    .build();
        }

        // Calculate available slots including current active holds by other users
        int activeHolds = countActiveHolds(eventId);
        int availableSlots = event.getCapacity() - (event.getCurrentParticipants() + activeHolds);

        if (availableSlots <= 0) {
            log.info("Event {} has no available slots (Capacity: {}, Registered: {}, Holds: {})",
                    eventId, event.getCapacity(), event.getCurrentParticipants(), activeHolds);
            return EventReservationResponse.builder()
                    .eventId(eventId)
                    .userId(user.getId())
                    .status("FULL")
                    .remainingSeconds(0L)
                    .message("Tüm kontenjanlar dolu veya şu an diğer kullanıcılar tarafından rezerve edilmiş durumda. Yedek listeye yazılabilirsiniz.")
                    .build();
        }

        // Hold slot in Redis for 5 minutes
        Instant expiresAt = Instant.now().plusSeconds(HOLD_DURATION_SECONDS);
        redisTemplate.opsForValue().set(userHoldKey, String.valueOf(expiresAt.toEpochMilli()), HOLD_DURATION_SECONDS, TimeUnit.SECONDS);

        log.info("User {} held a slot for event {} for 5 minutes. (Active holds now: {})",
                user.getUsername(), eventId, activeHolds + 1);

        return EventReservationResponse.builder()
                .eventId(eventId)
                .userId(user.getId())
                .status("HELD")
                .remainingSeconds(HOLD_DURATION_SECONDS)
                .expiresAt(expiresAt)
                .message("Kontenjanınız 5 dakika (300 saniye) süreyle adınıza ayrıldı. Lütfen bu süre içinde kaydınızı onaylayın.")
                .build();
    }

    /**
     * Confirms the held slot and converts it into a permanent registration.
     */
    @Transactional
    public EventResponse confirmHold(User user, Long eventId) {
        String userHoldKey = buildHoldKey(eventId, user.getId());
        Boolean hasHold = redisTemplate.hasKey(userHoldKey);

        if (Boolean.FALSE.equals(hasHold)) {
            // Check if there is still regular capacity without hold
            Event event = eventRepository.findById(eventId)
                    .orElseThrow(() -> new IllegalArgumentException("Event not found with id: " + eventId));
            if (event.getCurrentParticipants() >= event.getCapacity()) {
                throw new IllegalStateException("Rezervasyon süreniz (5 dakika) dolmuş ve tüm kontenjan dolmuştur. Lütfen tekrar deneyin.");
            }
        }

        // Remove the Redis temporary hold before or upon registration
        redisTemplate.delete(userHoldKey);

        // Perform atomic join in PostgreSQL
        return eventService.joinEvent(user, eventId);
    }

    /**
     * Manually releases the hold if the user cancels or closes the form.
     */
    public void releaseHold(User user, Long eventId) {
        String userHoldKey = buildHoldKey(eventId, user.getId());
        redisTemplate.delete(userHoldKey);
        log.info("User {} released hold for event {}", user.getUsername(), eventId);
    }

    /**
     * Checks reservation and capacity status for an event.
     */
    @Transactional(readOnly = true)
    public ReservationStatusResponse getReservationStatus(Long eventId, User currentUser) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found with id: " + eventId));

        int activeHolds = countActiveHolds(eventId);
        int availableSlots = Math.max(0, event.getCapacity() - (event.getCurrentParticipants() + activeHolds));

        boolean hasActiveReservation = false;
        Long remainingSeconds = 0L;
        Instant expiresAt = null;

        if (currentUser != null && currentUser.getId() != null) {
            String userHoldKey = buildHoldKey(eventId, currentUser.getId());
            Long ttl = redisTemplate.getExpire(userHoldKey, TimeUnit.SECONDS);
            if (ttl != null && ttl > 0) {
                hasActiveReservation = true;
                remainingSeconds = ttl;
                expiresAt = Instant.now().plusSeconds(ttl);
            }
        }

        return ReservationStatusResponse.builder()
                .eventId(eventId)
                .hasActiveReservation(hasActiveReservation)
                .remainingSeconds(remainingSeconds)
                .expiresAt(expiresAt)
                .capacity(event.getCapacity())
                .currentParticipants(event.getCurrentParticipants())
                .activeHoldsCount(activeHolds)
                .availableSlots(availableSlots)
                .build();
    }

    public int countActiveHolds(Long eventId) {
        Set<String> keys = redisTemplate.keys(HOLD_PREFIX + eventId + ":*");
        return (keys != null) ? keys.size() : 0;
    }

    private String buildHoldKey(Long eventId, Long userId) {
        return HOLD_PREFIX + eventId + ":" + userId;
    }
}
