package com.hobbypath.community.service;

import com.hobbypath.community.dto.CommunityResponse;
import com.hobbypath.community.dto.CreateCommunityRequest;
import com.hobbypath.community.entity.Community;
import com.hobbypath.community.entity.CommunityMember;
import com.hobbypath.community.entity.CommunityRole;
import com.hobbypath.community.repository.CommunityMemberRepository;
import com.hobbypath.community.repository.CommunityRepository;
import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommunityService {

    private final CommunityRepository communityRepository;
    private final CommunityMemberRepository communityMemberRepository;
    private final HobbyRepository hobbyRepository;

    @Transactional(readOnly = true)
    public List<CommunityResponse> getCommunities(Long hobbyId, User currentUser) {
        List<Community> communities;
        if (hobbyId != null) {
            communities = communityRepository.findByHobbyIdOrderByMemberCountDesc(hobbyId);
        } else {
            communities = communityRepository.findAllByOrderByMemberCountDesc();
        }

        return communities.stream()
                .map(c -> mapToCommunityResponse(c, currentUser))
                .toList();
    }

    @Transactional(readOnly = true)
    public CommunityResponse getCommunityById(Long id, User currentUser) {
        Community community = communityRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Community not found with id: " + id));
        return mapToCommunityResponse(community, currentUser);
    }

    @Transactional
    public CommunityResponse createCommunity(User creator, CreateCommunityRequest request) {
        Hobby hobby = hobbyRepository.findById(request.getHobbyId())
                .orElseThrow(() -> new IllegalArgumentException("Hobby not found with id: " + request.getHobbyId()));

        Community community = Community.builder()
                .name(request.getName().trim())
                .description(request.getDescription())
                .hobby(hobby)
                .creator(creator)
                .coverImage(request.getCoverImage())
                .memberCount(1)
                .build();

        Community saved = communityRepository.save(community);

        // Creator automatically joins as ADMIN
        CommunityMember member = CommunityMember.builder()
                .community(saved)
                .user(creator)
                .role(CommunityRole.ADMIN)
                .build();

        communityMemberRepository.save(member);

        return mapToCommunityResponse(saved, creator);
    }

    @Transactional
    public CommunityResponse joinCommunity(User user, Long communityId) {
        Community community = communityRepository.findById(communityId)
                .orElseThrow(() -> new IllegalArgumentException("Community not found with id: " + communityId));

        if (communityMemberRepository.existsByCommunityIdAndUserId(community.getId(), user.getId())) {
            throw new IllegalArgumentException("You are already a member of this community");
        }

        CommunityMember member = CommunityMember.builder()
                .community(community)
                .user(user)
                .role(CommunityRole.MEMBER)
                .build();

        communityMemberRepository.save(member);

        community.setMemberCount(community.getMemberCount() + 1);
        Community updated = communityRepository.save(community);

        return mapToCommunityResponse(updated, user);
    }

    @Transactional
    public CommunityResponse leaveCommunity(User user, Long communityId) {
        Community community = communityRepository.findById(communityId)
                .orElseThrow(() -> new IllegalArgumentException("Community not found with id: " + communityId));

        if (!communityMemberRepository.existsByCommunityIdAndUserId(community.getId(), user.getId())) {
            throw new IllegalArgumentException("You are not a member of this community");
        }

        communityMemberRepository.deleteByCommunityIdAndUserId(community.getId(), user.getId());

        community.setMemberCount(Math.max(0, community.getMemberCount() - 1));
        Community updated = communityRepository.save(community);

        return mapToCommunityResponse(updated, user);
    }

    private CommunityResponse mapToCommunityResponse(Community c, User currentUser) {
        boolean isMember = false;
        if (currentUser != null && currentUser.getId() != null) {
            isMember = communityMemberRepository.existsByCommunityIdAndUserId(c.getId(), currentUser.getId());
        }

        return CommunityResponse.builder()
                .id(c.getId())
                .name(c.getName())
                .description(c.getDescription())
                .hobbyId(c.getHobby().getId())
                .hobbyName(c.getHobby().getName())
                .hobbyIcon(c.getHobby().getIcon())
                .creatorUsername(c.getCreator() != null ? c.getCreator().getUsername() : null)
                .memberCount(c.getMemberCount())
                .isMember(isMember)
                .createdAt(c.getCreatedAt())
                .build();
    }
}
