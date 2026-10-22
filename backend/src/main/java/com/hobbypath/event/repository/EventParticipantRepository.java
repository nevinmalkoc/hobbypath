package com.hobbypath.event.repository;

import com.hobbypath.event.entity.EventParticipant;
import com.hobbypath.event.entity.ParticipantStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EventParticipantRepository extends JpaRepository<EventParticipant, Long> {

    List<EventParticipant> findByEventIdAndStatusOrderByJoinedAtAsc(Long eventId, ParticipantStatus status);

    Optional<EventParticipant> findByEventIdAndUserId(Long eventId, Long userId);

    boolean existsByEventIdAndUserIdAndStatus(Long eventId, Long userId, ParticipantStatus status);

    Optional<EventParticipant> findFirstByEventIdAndStatusOrderByJoinedAtAsc(Long eventId, ParticipantStatus status);

    int countByEventIdAndStatus(Long eventId, ParticipantStatus status);
}
