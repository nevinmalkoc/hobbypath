package com.hobbypath.chat.repository;

import com.hobbypath.chat.entity.ChatMessage;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    @Query("SELECT m FROM ChatMessage m JOIN FETCH m.sender WHERE m.community.id = :communityId ORDER BY m.sentAt ASC")
    List<ChatMessage> findRecentByCommunityId(@Param("communityId") Long communityId, Pageable pageable);

    Page<ChatMessage> findByCommunityIdOrderBySentAtDesc(Long communityId, Pageable pageable);
}
