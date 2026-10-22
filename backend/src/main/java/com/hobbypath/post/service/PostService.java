package com.hobbypath.post.service;

import com.hobbypath.community.entity.Community;
import com.hobbypath.community.repository.CommunityRepository;
import com.hobbypath.post.dto.CreatePostRequest;
import com.hobbypath.post.dto.PostResponse;
import com.hobbypath.post.entity.Post;
import com.hobbypath.post.repository.PostRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PostService {

    private final PostRepository postRepository;
    private final CommunityRepository communityRepository;

    @Transactional
    public PostResponse createPost(User author, Long communityId, CreatePostRequest request) {
        Community community = communityRepository.findById(communityId)
                .orElseThrow(() -> new IllegalArgumentException("Community not found with id: " + communityId));

        Post post = Post.builder()
                .title(request.getTitle().trim())
                .content(request.getContent().trim())
                .author(author)
                .community(community)
                .build();

        Post saved = postRepository.save(post);
        return mapToPostResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<PostResponse> getCommunityPosts(Long communityId) {
        if (!communityRepository.existsById(communityId)) {
            throw new IllegalArgumentException("Community not found with id: " + communityId);
        }

        return postRepository.findByCommunityIdOrderByCreatedAtDesc(communityId)
                .stream()
                .map(this::mapToPostResponse)
                .toList();
    }

    private PostResponse mapToPostResponse(Post post) {
        return PostResponse.builder()
                .id(post.getId())
                .title(post.getTitle())
                .content(post.getContent())
                .authorId(post.getAuthor().getId())
                .authorUsername(post.getAuthor().getUsername())
                .authorFullName(post.getAuthor().getFullName())
                .communityId(post.getCommunity().getId())
                .communityName(post.getCommunity().getName())
                .createdAt(post.getCreatedAt())
                .build();
    }
}
