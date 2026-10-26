package com.hobbypath.puzzle.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyPuzzleResponse {
    private Long id;
    private LocalDate puzzleDate;
    private String hobbyName;
    private String hobbyIcon;
    private String title;
    private String clue;
    private int answerLength;
    private String scrambledLetters;
    private boolean alreadySolved;
    private Integer myCompletionTimeSeconds;
}
