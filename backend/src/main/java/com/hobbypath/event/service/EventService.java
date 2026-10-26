package com.hobbypath.event.service;

import com.hobbypath.community.entity.Community;
import com.hobbypath.community.repository.CommunityRepository;
import com.hobbypath.event.dto.CreateEventRequest;
import com.hobbypath.event.dto.EventResponse;
import com.hobbypath.event.entity.Event;
import com.hobbypath.event.entity.EventParticipant;
import com.hobbypath.event.entity.EventStatus;
import com.hobbypath.event.entity.ParticipantStatus;
import com.hobbypath.event.repository.EventParticipantRepository;
import com.hobbypath.event.repository.EventRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class EventService {

    private final EventRepository eventRepository;
    private final EventParticipantRepository participantRepository;
    private final CommunityRepository communityRepository;
    private final com.hobbypath.notification.service.NotificationService notificationService;

    @Transactional
    public EventResponse createEvent(User organizer, Long communityId, CreateEventRequest request) {
        Community community = communityRepository.findById(communityId)
                .orElseThrow(() -> new IllegalArgumentException("Community not found with id: " + communityId));

        Event event = Event.builder()
                .title(request.getTitle().trim())
                .description(request.getDescription().trim())
                .community(community)
                .organizer(organizer)
                .location(request.getLocation().trim())
                .eventDate(request.getEventDate())
                .capacity(request.getCapacity())
                .currentParticipants(1) // Organizer is the first participant
                .status(EventStatus.UPCOMING)
                .build();

        Event savedEvent = eventRepository.save(event);

        // Organizer is automatically registered
        EventParticipant organizerParticipant = EventParticipant.builder()
                .event(savedEvent)
                .user(organizer)
                .status(ParticipantStatus.REGISTERED)
                .build();

        participantRepository.save(organizerParticipant);

        return mapToEventResponse(savedEvent, organizer);
    }

    @Transactional(readOnly = true)
    public List<EventResponse> getUpcomingEvents(Long hobbyId, User currentUser) {
        List<Event> events;
        Instant now = Instant.now();

        if (hobbyId != null) {
            events = eventRepository.findByHobbyIdAndUpcoming(hobbyId, EventStatus.UPCOMING, now);
        } else {
            events = eventRepository.findByStatusAndEventDateAfterOrderByEventDateAsc(EventStatus.UPCOMING, now);
        }

        return events.stream()
                .map(e -> mapToEventResponse(e, currentUser))
                .toList();
    }

    @Transactional(readOnly = true)
    public EventResponse getEventById(Long id, User currentUser) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Event not found with id: " + id));
        return mapToEventResponse(event, currentUser);
    }

    @Transactional
    public EventResponse joinEvent(User user, Long eventId) {
        // Concurrency-safe lock on event row
        Event event = eventRepository.findByIdWithLock(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found with id: " + eventId));

        if (event.getStatus() != EventStatus.UPCOMING) {
            throw new IllegalArgumentException("Cannot join an event that is not upcoming");
        }

        Optional<EventParticipant> existing = participantRepository.findByEventIdAndUserId(event.getId(), user.getId());
        if (existing.isPresent() && existing.get().getStatus() != ParticipantStatus.CANCELLED) {
            throw new IllegalArgumentException("You are already registered or on the waitlist for this event");
        }

        ParticipantStatus status;
        if (event.getCurrentParticipants() < event.getCapacity()) {
            // Main registered slot
            status = ParticipantStatus.REGISTERED;
            event.setCurrentParticipants(event.getCurrentParticipants() + 1);
            eventRepository.save(event);
            log.info("User {} registered for event {} (Seat: {}/{})", user.getUsername(), event.getId(), event.getCurrentParticipants(), event.getCapacity());
        } else {
            // Capacity is full -> Assign to WAITLIST
            status = ParticipantStatus.WAITLIST;
            log.info("Event {} full. User {} added to WAITLIST.", event.getId(), user.getUsername());
        }

        EventParticipant participant = existing.orElseGet(() -> EventParticipant.builder()
                .event(event)
                .user(user)
                .build());

        participant.setStatus(status);
        participantRepository.save(participant);

        return mapToEventResponse(event, user);
    }

    @Transactional
    public EventResponse leaveEvent(User user, Long eventId) {
        Event event = eventRepository.findByIdWithLock(eventId)
                .orElseThrow(() -> new IllegalArgumentException("Event not found with id: " + eventId));

        EventParticipant participant = participantRepository.findByEventIdAndUserId(event.getId(), user.getId())
                .orElseThrow(() -> new IllegalArgumentException("You are not registered for this event"));

        if (participant.getStatus() == ParticipantStatus.CANCELLED) {
            throw new IllegalArgumentException("You have already cancelled this event");
        }

        boolean wasRegistered = participant.getStatus() == ParticipantStatus.REGISTERED;
        participant.setStatus(ParticipantStatus.CANCELLED);
        participantRepository.save(participant);

        if (wasRegistered) {
            // Check if there is someone in the WAITLIST to automatically promote
            Optional<EventParticipant> nextInWaitlist = participantRepository
                    .findFirstByEventIdAndStatusOrderByJoinedAtAsc(event.getId(), ParticipantStatus.WAITLIST);

            if (nextInWaitlist.isPresent()) {
                EventParticipant promoted = nextInWaitlist.get();
                promoted.setStatus(ParticipantStatus.REGISTERED);
                participantRepository.save(promoted);
                log.info("Promoted user {} from WAITLIST to REGISTERED for event {}", promoted.getUser().getUsername(), event.getId());

                notificationService.createNotification(
                        promoted.getUser(),
                        "Kontenjan Açıldı! 🎉",
                        "\"" + event.getTitle() + "\" etkinliğinde boşalan kontenjan için yedek listeden asil listeye alındınız!",
                        com.hobbypath.notification.entity.NotificationType.EVENT_PROMOTED,
                        event.getId()
                );
            } else {
                event.setCurrentParticipants(Math.max(0, event.getCurrentParticipants() - 1));
                eventRepository.save(event);
            }
        }

        return mapToEventResponse(event, user);
    }

    private EventResponse mapToEventResponse(Event e, User currentUser) {
        ParticipantStatus userStatus = null;
        if (currentUser != null && currentUser.getId() != null) {
            userStatus = participantRepository.findByEventIdAndUserId(e.getId(), currentUser.getId())
                    .map(EventParticipant::getStatus)
                    .orElse(null);
        }

        return EventResponse.builder()
                .id(e.getId())
                .title(e.getTitle())
                .description(e.getDescription())
                .communityId(e.getCommunity().getId())
                .communityName(e.getCommunity().getName())
                .hobbyName(e.getCommunity().getHobby().getName())
                .hobbyIcon(e.getCommunity().getHobby().getIcon())
                .organizerUsername(e.getOrganizer().getUsername())
                .location(e.getLocation())
                .latitude(e.getLatitude())
                .longitude(e.getLongitude())
                .city(e.getCity())
                .district(e.getDistrict())
                .eventDate(e.getEventDate())
                .capacity(e.getCapacity())
                .currentParticipants(e.getCurrentParticipants())
                .userStatus(userStatus)
                .status(e.getStatus())
                .build();
    }
}
