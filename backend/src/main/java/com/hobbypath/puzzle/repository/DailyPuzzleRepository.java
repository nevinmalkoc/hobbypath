package com.hobbypath.puzzle.repository;

import com.hobbypath.puzzle.entity.DailyPuzzle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface DailyPuzzleRepository extends JpaRepository<DailyPuzzle, Long> {

    Optional<DailyPuzzle> findFirstByPuzzleDate(LocalDate puzzleDate);

    Optional<DailyPuzzle> findByPuzzleDateAndHobbyId(LocalDate puzzleDate, Long hobbyId);

    Optional<DailyPuzzle> findFirstByOrderByPuzzleDateDesc();
}
