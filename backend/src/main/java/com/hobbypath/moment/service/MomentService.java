package com.hobbypath.moment.service;

import com.hobbypath.community.entity.Community;
import com.hobbypath.community.repository.CommunityRepository;
import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import com.hobbypath.moment.dto.CreateMomentRequest;
import com.hobbypath.moment.dto.MomentResponse;
import com.hobbypath.moment.entity.HobbyMoment;
import com.hobbypath.moment.repository.MomentRepository;
import com.hobbypath.user.entity.User;
import com.hobbypath.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MomentService {

    private final MomentRepository momentRepository;
    private final HobbyRepository hobbyRepository;
    private final CommunityRepository communityRepository;
    private final UserRepository userRepository;

    @Transactional
    public List<MomentResponse> getRecentMoments(User currentUser) {
        ensureMomentsSeeded();
        List<HobbyMoment> moments = momentRepository.findAllByOrderByCreatedAtDesc();
        return moments.stream().map(m -> mapToResponse(m, currentUser)).collect(Collectors.toList());
    }

    @Transactional
    public MomentResponse createMoment(User user, CreateMomentRequest request) {
        Hobby hobby = hobbyRepository.findById(request.getHobbyId())
                .orElseThrow(() -> new IllegalArgumentException("Hobby not found: " + request.getHobbyId()));

        Community community = null;
        if (request.getCommunityId() != null) {
            community = communityRepository.findById(request.getCommunityId()).orElse(null);
        }

        HobbyMoment moment = HobbyMoment.builder()
                .user(user)
                .hobby(hobby)
                .community(community)
                .caption(request.getCaption().trim())
                .imageUrl(request.getImageUrl().trim())
                .likesCount(0)
                .build();

        HobbyMoment saved = momentRepository.save(moment);
        log.info("User {} shared a new hobby moment: {}", user.getUsername(), saved.getCaption());
        return mapToResponse(saved, user);
    }

    @Transactional
    public MomentResponse toggleLike(User user, Long momentId) {
        HobbyMoment moment = momentRepository.findById(momentId)
                .orElseThrow(() -> new IllegalArgumentException("Moment not found: " + momentId));

        moment.setLikesCount(moment.getLikesCount() + 1);
        HobbyMoment updated = momentRepository.save(moment);
        return mapToResponse(updated, user);
    }

    private MomentResponse mapToResponse(HobbyMoment m, User currentUser) {
        return MomentResponse.builder()
                .id(m.getId())
                .userId(m.getUser().getId())
                .username(m.getUser().getUsername())
                .userFullName(m.getUser().getFullName())
                .userAvatar(m.getUser().getAvatar())
                .hobbyId(m.getHobby().getId())
                .hobbyName(m.getHobby().getName())
                .hobbyIcon(m.getHobby().getIcon())
                .communityId(m.getCommunity() != null ? m.getCommunity().getId() : null)
                .communityName(m.getCommunity() != null ? m.getCommunity().getName() : null)
                .caption(m.getCaption())
                .imageUrl(m.getImageUrl())
                .likesCount(m.getLikesCount())
                .likedByMe(false)
                .createdAt(m.getCreatedAt())
                .build();
    }

    private void ensureMomentsSeeded() {
        if (momentRepository.count() > 0) return;

        User user = userRepository.findAll().stream().findFirst().orElse(null);
        if (user == null) return;

        log.info("Seeding initial high quality hobby moments (Şipşak)...");
        Hobby ceramics = hobbyRepository.findByNameIgnoreCase("Ceramics").orElse(null);
        Hobby horse = hobbyRepository.findByNameIgnoreCase("Horse Riding").orElse(null);
        Hobby running = hobbyRepository.findByNameIgnoreCase("Running").orElse(null);
        Hobby photo = hobbyRepository.findByNameIgnoreCase("Photography").orElse(null);
        Hobby cooking = hobbyRepository.findByNameIgnoreCase("Cooking").orElse(null);
        Hobby hiking = hobbyRepository.findByNameIgnoreCase("Hiking").orElse(null);

        List<HobbyMoment> list = List.of(
                HobbyMoment.builder()
                        .user(user)
                        .hobby(ceramics)
                        .caption("İlk el yapımı kahve kupam fırından ve sırdan çıktı! 🏺☕")
                        .imageUrl("https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&w=800&q=80")
                        .likesCount(28)
                        .build(),
                HobbyMoment.builder()
                        .user(user)
                        .hobby(horse)
                        .caption("Polonezköy'de sabah binişi ve tırıs parkuru tamamlandı 🐎🌲")
                        .imageUrl("https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&w=800&q=80")
                        .likesCount(42)
                        .build(),
                HobbyMoment.builder()
                        .user(user)
                        .hobby(running)
                        .caption("Caddebostan sahilinde 10K sabah koşusu! Kadans: 176 🏃‍♂️💨")
                        .imageUrl("https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&w=800&q=80")
                        .likesCount(35)
                        .build(),
                HobbyMoment.builder()
                        .user(user)
                        .hobby(photo)
                        .caption("Karaköy İskelesi'nde gün batımı ve altın saat ışığı 📸🌅")
                        .imageUrl("https://images.unsplash.com/photo-1502982720700-bfff97f2ecac?auto=format&fit=crop&w=800&q=80")
                        .likesCount(56)
                        .build(),
                HobbyMoment.builder()
                        .user(user)
                        .hobby(cooking)
                        .caption("Ev yapımı taze fesleğenli tagliatelle makarna ve pesto! 🍳🍝")
                        .imageUrl("https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=800&q=80")
                        .likesCount(39)
                        .build(),
                HobbyMoment.builder()
                        .user(user)
                        .hobby(hiking)
                        .caption("Ballıkayalar Kanyonu zirve rotasından selamlar 🌲🥾")
                        .imageUrl("https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80")
                        .likesCount(47)
                        .build()
        );

        momentRepository.saveAll(list);
        log.info("Successfully seeded {} hobby moments.", list.size());
    }
}
