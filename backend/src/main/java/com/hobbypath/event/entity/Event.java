package com.hobbypath.event.entity;

import com.hobbypath.community.entity.Community;
import com.hobbypath.user.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "community_id", nullable = false)
    private Community community;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "organizer_id", nullable = false)
    private User organizer;

    @Column(nullable = false, length = 255)
    private String location;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @Column(length = 60)
    private String city;

    @Column(length = 60)
    private String district;

    @Column(nullable = false)
    private Instant eventDate;

    @Column(nullable = false)
    private int capacity;

    @Builder.Default
    @Column(nullable = false)
    private int currentParticipants = 1;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    @Column(nullable = false, length = 20)
    private EventStatus status = EventStatus.UPCOMING;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;
}
