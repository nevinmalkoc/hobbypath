package com.hobbypath.puzzle.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SolvePuzzleRequest {

    @NotBlank(message = "Answer cannot be blank")
    private String answer;

    @PositiveOrZero(message = "Completion time must be positive or zero")
    private int completionTimeSeconds;
}
