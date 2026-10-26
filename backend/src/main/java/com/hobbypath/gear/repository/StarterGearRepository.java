package com.hobbypath.gear.repository;

import com.hobbypath.gear.entity.StarterGear;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StarterGearRepository extends JpaRepository<StarterGear, Long> {
    List<StarterGear> findByHobbyIdOrderByPriorityOrderAsc(Long hobbyId);
    List<StarterGear> findAllByOrderByPriorityOrderAsc();
}
