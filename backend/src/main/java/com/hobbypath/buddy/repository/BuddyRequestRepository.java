package com.hobbypath.buddy.repository;

import com.hobbypath.buddy.entity.BuddyRequest;
import com.hobbypath.buddy.entity.BuddyRequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BuddyRequestRepository extends JpaRepository<BuddyRequest, Long> {
    List<BuddyRequest> findByStatusOrderByCreatedAtDesc(BuddyRequestStatus status);
    List<BuddyRequest> findByHobbyIdAndStatusOrderByCreatedAtDesc(Long hobbyId, BuddyRequestStatus status);
    List<BuddyRequest> findByCreatorIdOrderByCreatedAtDesc(Long creatorId);
}
