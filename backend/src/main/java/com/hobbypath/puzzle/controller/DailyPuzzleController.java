package com.hobbypath.puzzle.controller;

import com.hobbypath.puzzle.dto.DailyPuzzleResponse;
import com.hobbypath.puzzle.dto.LeaderboardEntryResponse;
import com.hobbypath.puzzle.dto.SolvePuzzleRequest;
import com.hobbypath.puzzle.dto.TriviaQuestionResponse;
import com.hobbypath.puzzle.service.DailyPuzzleService;
import com.hobbypath.user.entity.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/puzzles")
@RequiredArgsConstructor
public class DailyPuzzleController {

    private final DailyPuzzleService puzzleService;

    @GetMapping("/today")
    public ResponseEntity<DailyPuzzleResponse> getTodayPuzzle(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) Long hobbyId
    ) {
        return ResponseEntity.ok(puzzleService.getTodayPuzzle(currentUser, hobbyId));
    }

    @GetMapping("/trivia")
    public ResponseEntity<List<TriviaQuestionResponse>> getTriviaQuestions(
            @RequestParam(required = false) Long hobbyId
    ) {
        return ResponseEntity.ok(puzzleService.getTriviaQuestions(hobbyId));
    }

    @PostMapping("/{id}/solve")
    public ResponseEntity<LeaderboardEntryResponse> solvePuzzle(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id,
            @Valid @RequestBody SolvePuzzleRequest request
    ) {
        return ResponseEntity.ok(puzzleService.solvePuzzle(currentUser, id, request));
    }

    @GetMapping("/{id}/leaderboard")
    public ResponseEntity<List<LeaderboardEntryResponse>> getLeaderboard(
            @PathVariable Long id,
            @RequestParam(defaultValue = "10") int limit
    ) {
        return ResponseEntity.ok(puzzleService.getLeaderboard(id, limit));
    }
}
