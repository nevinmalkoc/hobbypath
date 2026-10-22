package com.hobbypath.hobby.repository;

import com.hobbypath.hobby.entity.UserHobby;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserHobbyRepository extends JpaRepository<UserHobby, Long> {

    List<UserHobby> findByUserId(Long userId);

    Optional<UserHobby> findByUserIdAndHobbyId(Long userId, Long hobbyId);

    boolean existsByUserIdAndHobbyId(Long userId, Long hobbyId);

    void deleteByUserIdAndHobbyId(Long userId, Long hobbyId);
}
