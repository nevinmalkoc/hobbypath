package com.hobbypath.feed.service;

import com.hobbypath.community.entity.CommunityMember;
import com.hobbypath.community.repository.CommunityMemberRepository;
import com.hobbypath.event.dto.EventResponse;
import com.hobbypath.event.service.EventService;
import com.hobbypath.feed.dto.FeedResponse;
import com.hobbypath.post.dto.PostResponse;
import com.hobbypath.post.repository.PostRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FeedService {

    private final CommunityMemberRepository communityMemberRepository;
    private final PostRepository postRepository;
    private final EventService eventService;

    @Transactional(readOnly = true)
    public FeedResponse getHomeFeed(User currentUser) {
        List<PostResponse> posts = new ArrayList<>();

        if (currentUser != null) {
            List<CommunityMember> memberships = communityMemberRepository.findByUserId(currentUser.getId());
            for (CommunityMember cm : memberships) {
                postRepository.findByCommunityIdOrderByCreatedAtDesc(cm.getCommunity().getId())
                        .stream()
                        .limit(10)
                        .forEach(p -> posts.add(PostResponse.builder()
                                .id(p.getId())
                                .title(p.getTitle())
                                .content(p.getContent())
                                .authorId(p.getAuthor().getId())
                                .authorUsername(p.getAuthor().getUsername())
                                .authorFullName(p.getAuthor().getFullName())
                                .communityId(p.getCommunity().getId())
                                .communityName(p.getCommunity().getName())
                                .createdAt(p.getCreatedAt())
                                .build()));
            }
        }

        // Upcoming events
        List<EventResponse> upcomingEvents = eventService.getUpcomingEvents(null, currentUser);

        return FeedResponse.builder()
                .communityPosts(posts)
                .upcomingEvents(upcomingEvents)
                .build();
    }
}
