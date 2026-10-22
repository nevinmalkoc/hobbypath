package com.hobbypath.hobby.repository;

import com.hobbypath.hobby.entity.Hobby;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HobbyRepository extends JpaRepository<Hobby, Long> {

    Optional<Hobby> findByNameIgnoreCase(String name);

    List<Hobby> findByCategoryIgnoreCase(String category);
}
