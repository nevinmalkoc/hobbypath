package com.hobbypath.chat.service;

import com.hobbypath.chat.dto.ChatMessageRequest;
import com.hobbypath.chat.dto.ChatMessageResponse;
import com.hobbypath.chat.entity.ChatMessage;
import com.hobbypath.chat.entity.MessageType;
import com.hobbypath.chat.repository.ChatMessageRepository;
import com.hobbypath.community.entity.Community;
import com.hobbypath.community.repository.CommunityMemberRepository;
import com.hobbypath.community.repository.CommunityRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final CommunityRepository communityRepository;
    private final CommunityMemberRepository memberRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional
    public ChatMessageResponse sendCommunityMessage(User sender, Long communityId, ChatMessageRequest request) {
        Community community = communityRepository.findById(communityId)
                .orElseThrow(() -> new IllegalArgumentException("Community not found with id: " + communityId));

        // Ensure user is member or creator
        boolean isMember = memberRepository.existsByCommunityIdAndUserId(communityId, sender.getId());
        if (!isMember) {
            throw new IllegalArgumentException("You must be a member of the community to send messages");
        }

        ChatMessage message = ChatMessage.builder()
                .sender(sender)
                .community(community)
                .content(request.getContent().trim())
                .type(request.getType() != null ? request.getType() : MessageType.CHAT)
                .build();

        ChatMessage saved = chatMessageRepository.save(message);
        ChatMessageResponse response = mapToResponse(saved);

        // Broadcast to WebSocket subscribers: /topic/community/{communityId}
        String destination = "/topic/community/" + communityId;
        log.info("Broadcasting chat message from user {} to {}", sender.getUsername(), destination);
        messagingTemplate.convertAndSend(destination, response);

        return response;
    }

    @Transactional(readOnly = true)
    public List<ChatMessageResponse> getRecentCommunityMessages(Long communityId, int limit) {
        int pageSize = Math.min(Math.max(limit, 10), 100);
        Pageable pageable = PageRequest.of(0, pageSize);
        List<ChatMessage> messages = chatMessageRepository.findRecentByCommunityId(communityId, pageable);
        return messages.stream().map(this::mapToResponse).toList();
    }

    private ChatMessageResponse mapToResponse(ChatMessage msg) {
        return ChatMessageResponse.builder()
                .id(msg.getId())
                .senderId(msg.getSender().getId())
                .senderUsername(msg.getSender().getUsername())
                .senderFullName(msg.getSender().getFullName())
                .communityId(msg.getCommunity() != null ? msg.getCommunity().getId() : null)
                .content(msg.getContent())
                .type(msg.getType().name())
                .sentAt(msg.getSentAt())
                .build();
    }
}
