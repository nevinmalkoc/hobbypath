package com.hobbypath.moment.entity;

import com.hobbypath.community.entity.Community;
import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.user.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "hobby_moments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HobbyMoment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "hobby_id", nullable = false)
    private Hobby hobby;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "community_id")
    private Community community;

    @Column(nullable = false, length = 200)
    private String caption;

    @Column(name = "image_url", nullable = false, length = 600)
    private String imageUrl;

    @Column(name = "likes_count")
    @Builder.Default
    private int likesCount = 0;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;
}
