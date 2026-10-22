package com.hobbypath.event.repository;

import com.hobbypath.event.entity.Event;
import com.hobbypath.event.entity.EventStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {

    List<Event> findByCommunityIdOrderByEventDateAsc(Long communityId);

    List<Event> findByStatusAndEventDateAfterOrderByEventDateAsc(EventStatus status, Instant after);

    @Query("SELECT e FROM Event e WHERE e.community.hobby.id = :hobbyId AND e.status = :status AND e.eventDate > :after ORDER BY e.eventDate ASC")
    List<Event> findByHobbyIdAndUpcoming(
            @Param("hobbyId") Long hobbyId,
            @Param("status") EventStatus status,
            @Param("after") Instant after
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT e FROM Event e WHERE e.id = :id")
    Optional<Event> findByIdWithLock(@Param("id") Long id);
}
