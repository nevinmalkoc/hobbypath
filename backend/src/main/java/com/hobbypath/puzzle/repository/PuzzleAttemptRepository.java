package com.hobbypath.puzzle.repository;

import com.hobbypath.puzzle.entity.PuzzleAttempt;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PuzzleAttemptRepository extends JpaRepository<PuzzleAttempt, Long> {

    Optional<PuzzleAttempt> findByPuzzleIdAndUserId(Long puzzleId, Long userId);

    @Query("SELECT pa FROM PuzzleAttempt pa JOIN FETCH pa.user WHERE pa.puzzle.id = :puzzleId ORDER BY pa.completionTimeSeconds ASC, pa.solvedAt ASC")
    List<PuzzleAttempt> findTopByPuzzleIdOrderByTime(@Param("puzzleId") Long puzzleId, Pageable pageable);
}
