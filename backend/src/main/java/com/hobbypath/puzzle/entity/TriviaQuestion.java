package com.hobbypath.puzzle.entity;

import com.hobbypath.hobby.entity.Hobby;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "trivia_questions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TriviaQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hobby_id")
    private Hobby hobby;

    @Column(nullable = false, length = 300)
    private String question;

    @Column(nullable = false, length = 100)
    private String optionA;

    @Column(nullable = false, length = 100)
    private String optionB;

    @Column(nullable = false, length = 100)
    private String optionC;

    @Column(nullable = false, length = 100)
    private String optionD;

    @Column(nullable = false)
    private int correctIndex; // 0, 1, 2, 3

    @Column(columnDefinition = "TEXT")
    private String explanation;

    @Column(length = 30)
    @Builder.Default
    private String difficulty = "ORTA";
}
