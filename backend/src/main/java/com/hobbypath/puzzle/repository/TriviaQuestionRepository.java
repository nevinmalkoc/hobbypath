package com.hobbypath.puzzle.repository;

import com.hobbypath.puzzle.entity.TriviaQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TriviaQuestionRepository extends JpaRepository<TriviaQuestion, Long> {
    List<TriviaQuestion> findByHobbyId(Long hobbyId);
}
