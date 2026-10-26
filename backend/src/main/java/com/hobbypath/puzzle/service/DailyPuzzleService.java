package com.hobbypath.puzzle.service;

import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import com.hobbypath.puzzle.dto.DailyPuzzleResponse;
import com.hobbypath.puzzle.dto.LeaderboardEntryResponse;
import com.hobbypath.puzzle.dto.SolvePuzzleRequest;
import com.hobbypath.puzzle.entity.DailyPuzzle;
import com.hobbypath.puzzle.entity.PuzzleAttempt;
import com.hobbypath.puzzle.repository.DailyPuzzleRepository;
import com.hobbypath.puzzle.repository.PuzzleAttemptRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class DailyPuzzleService {

    private final DailyPuzzleRepository puzzleRepository;
    private final PuzzleAttemptRepository attemptRepository;
    private final HobbyRepository hobbyRepository;

    @Transactional
    public DailyPuzzleResponse getTodayPuzzle(User currentUser) {
        LocalDate today = LocalDate.now();
        DailyPuzzle puzzle = puzzleRepository.findByPuzzleDate(today)
                .orElseGet(() -> seedTodayPuzzle(today));

        boolean alreadySolved = false;
        Integer myTime = null;

        if (currentUser != null) {
            Optional<PuzzleAttempt> attempt = attemptRepository.findByPuzzleIdAndUserId(puzzle.getId(), currentUser.getId());
            if (attempt.isPresent()) {
                alreadySolved = true;
                myTime = attempt.get().getCompletionTimeSeconds();
            }
        }

        return DailyPuzzleResponse.builder()
                .id(puzzle.getId())
                .puzzleDate(puzzle.getPuzzleDate())
                .hobbyName(puzzle.getHobby() != null ? puzzle.getHobby().getName() : "Genel Hobi")
                .hobbyIcon(puzzle.getHobby() != null ? puzzle.getHobby().getIcon() : "🧩")
                .title(puzzle.getTitle())
                .clue(puzzle.getClue())
                .answerLength(puzzle.getAnswer().length())
                .scrambledLetters(puzzle.getScrambledLetters())
                .alreadySolved(alreadySolved)
                .myCompletionTimeSeconds(myTime)
                .build();
    }

    @Transactional
    public LeaderboardEntryResponse solvePuzzle(User user, Long puzzleId, SolvePuzzleRequest request) {
        DailyPuzzle puzzle = puzzleRepository.findById(puzzleId)
                .orElseThrow(() -> new IllegalArgumentException("Puzzle not found with id: " + puzzleId));

        String submitted = request.getAnswer().trim().toUpperCase();
        String expected = puzzle.getAnswer().trim().toUpperCase();

        if (!submitted.equals(expected)) {
            throw new IllegalArgumentException("Cevap doğru değil! İpucuna tekrar bakın.");
        }

        Optional<PuzzleAttempt> existing = attemptRepository.findByPuzzleIdAndUserId(puzzleId, user.getId());
        PuzzleAttempt attempt;

        if (existing.isPresent()) {
            attempt = existing.get();
        } else {
            attempt = PuzzleAttempt.builder()
                    .puzzle(puzzle)
                    .user(user)
                    .completionTimeSeconds(Math.max(1, request.getCompletionTimeSeconds()))
                    .solved(true)
                    .build();
            attempt = attemptRepository.save(attempt);
            log.info("User {} solved daily puzzle {} in {} seconds!", user.getUsername(), puzzleId, attempt.getCompletionTimeSeconds());
        }

        return LeaderboardEntryResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .completionTimeSeconds(attempt.getCompletionTimeSeconds())
                .solvedAt(attempt.getSolvedAt())
                .build();
    }

    @Transactional(readOnly = true)
    public List<LeaderboardEntryResponse> getLeaderboard(Long puzzleId, int limit) {
        int pageSize = Math.min(Math.max(limit, 5), 50);
        List<PuzzleAttempt> attempts = attemptRepository.findTopByPuzzleIdOrderByTime(
                puzzleId,
                PageRequest.of(0, pageSize)
        );

        List<LeaderboardEntryResponse> result = new ArrayList<>();
        int rank = 1;
        for (PuzzleAttempt a : attempts) {
            result.add(LeaderboardEntryResponse.builder()
                    .rank(rank++)
                    .userId(a.getUser().getId())
                    .username(a.getUser().getUsername())
                    .fullName(a.getUser().getFullName())
                    .completionTimeSeconds(a.getCompletionTimeSeconds())
                    .solvedAt(a.getSolvedAt())
                    .build());
        }
        return result;
    }

    private DailyPuzzle seedTodayPuzzle(LocalDate date) {
        Hobby horseRiding = hobbyRepository.findByNameIgnoreCase("Horse Riding").orElse(null);

        java.util.List<String> letters = new java.util.ArrayList<>(java.util.List.of("P", "T", "C", "R", "A", "O", "S", "H", "K", "L"));
        java.util.Collections.shuffle(letters);
        String scrambled = String.join(",", letters);

        DailyPuzzle puzzle = DailyPuzzle.builder()
                .puzzleDate(date)
                .hobby(horseRiding)
                .title("Günün Binicilik Terimi 🐎")
                .clue("Binicilikte bacağın alt kısmını ve pantolonu sürtünmeden koruyan deri veya süet koruyucu?")
                .answer("CHAPS")
                .scrambledLetters(scrambled)
                .pointsReward(100)
                .build();

        return puzzleRepository.save(puzzle);
    }
}
