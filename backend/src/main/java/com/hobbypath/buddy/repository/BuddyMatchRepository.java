package com.hobbypath.buddy.repository;

import com.hobbypath.buddy.entity.BuddyMatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BuddyMatchRepository extends JpaRepository<BuddyMatch, Long> {
    List<BuddyMatch> findByBuddyRequestIdOrderByCreatedAtDesc(Long requestId);
    List<BuddyMatch> findByApplicantIdOrderByCreatedAtDesc(Long applicantId);
    Optional<BuddyMatch> findByBuddyRequestIdAndApplicantId(Long requestId, Long applicantId);
    int countByBuddyRequestId(Long requestId);
}
