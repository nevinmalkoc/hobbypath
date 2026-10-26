package com.hobbypath.puzzle.entity;

import com.hobbypath.hobby.entity.Hobby;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.Instant;

@Entity
@Table(name = "daily_puzzles", indexes = {
        @Index(name = "idx_daily_puzzle_date", columnList = "puzzle_date", unique = true)
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyPuzzle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "puzzle_date", nullable = false, unique = true)
    private LocalDate puzzleDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hobby_id")
    private Hobby hobby;

    @Column(nullable = false, length = 120)
    private String title;

    @Column(nullable = false, length = 500)
    private String clue;

    @Column(nullable = false, length = 50)
    private String answer;

    @Column(name = "scrambled_letters", nullable = false, length = 100)
    private String scrambledLetters;

    @Column(name = "points_reward", nullable = false)
    @Builder.Default
    private int pointsReward = 100;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
