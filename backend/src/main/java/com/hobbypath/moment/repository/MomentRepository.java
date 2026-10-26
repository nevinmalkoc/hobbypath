package com.hobbypath.moment.repository;

import com.hobbypath.moment.entity.HobbyMoment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MomentRepository extends JpaRepository<HobbyMoment, Long> {

    List<HobbyMoment> findAllByOrderByCreatedAtDesc();

    List<HobbyMoment> findByHobbyIdOrderByCreatedAtDesc(Long hobbyId);
}
