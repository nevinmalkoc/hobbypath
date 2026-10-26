package com.hobbypath.puzzle.entity;

import com.hobbypath.user.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "puzzle_attempts", uniqueConstraints = {
        @UniqueConstraint(name = "uk_user_puzzle", columnNames = {"user_id", "puzzle_id"})
}, indexes = {
        @Index(name = "idx_puzzle_time", columnList = "puzzle_id, completion_time_seconds")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PuzzleAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "puzzle_id", nullable = false)
    private DailyPuzzle puzzle;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "completion_time_seconds", nullable = false)
    private int completionTimeSeconds;

    @Column(nullable = false)
    @Builder.Default
    private boolean solved = true;

    @CreationTimestamp
    @Column(name = "solved_at", nullable = false, updatable = false)
    private Instant solvedAt;
}
