package com.hobbypath.hobby.entity;

import com.hobbypath.user.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(
        name = "user_hobbies",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_user_hobby", columnNames = {"user_id", "hobby_id"})
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserHobby {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "hobby_id", nullable = false)
    private Hobby hobby;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private SkillLevel skillLevel;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;
}
