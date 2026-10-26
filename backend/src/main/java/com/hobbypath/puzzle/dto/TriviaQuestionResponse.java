package com.hobbypath.puzzle.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TriviaQuestionResponse {
    private Long id;
    private Long hobbyId;
    private String hobbyName;
    private String hobbyIcon;
    private String question;
    private List<String> options;
    private int correctIndex;
    private String explanation;
    private String difficulty;
}
