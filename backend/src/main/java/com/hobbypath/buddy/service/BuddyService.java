package com.hobbypath.buddy.service;

import com.hobbypath.buddy.dto.BuddyMatchResponse;
import com.hobbypath.buddy.dto.BuddyRequestResponse;
import com.hobbypath.buddy.dto.ConnectBuddyRequest;
import com.hobbypath.buddy.dto.CreateBuddyRequest;
import com.hobbypath.buddy.entity.*;
import com.hobbypath.buddy.repository.BuddyMatchRepository;
import com.hobbypath.buddy.repository.BuddyRequestRepository;
import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import com.hobbypath.notification.entity.NotificationType;
import com.hobbypath.notification.service.NotificationService;
import com.hobbypath.user.entity.User;
import com.hobbypath.user.repository.UserRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BuddyService {

    private final BuddyRequestRepository buddyRequestRepository;
    private final BuddyMatchRepository buddyMatchRepository;
    private final HobbyRepository hobbyRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    @Transactional(readOnly = true)
    public List<BuddyRequestResponse> getBuddyRequests(User currentUser, Long hobbyId, BuddyIntention intention, GenderPreference genderPreference) {
        List<BuddyRequest> list;
        if (hobbyId != null) {
            list = buddyRequestRepository.findByHobbyIdAndStatusOrderByCreatedAtDesc(hobbyId, BuddyRequestStatus.OPEN);
        } else {
            list = buddyRequestRepository.findByStatusOrderByCreatedAtDesc(BuddyRequestStatus.OPEN);
        }

        if (intention != null) {
            list = list.stream().filter(r -> r.getIntention() == intention).collect(Collectors.toList());
        }

        if (genderPreference != null) {
            list = list.stream().filter(r -> r.getGenderPreference() == genderPreference).collect(Collectors.toList());
        }

        return list.stream().map(r -> mapToResponse(r, currentUser)).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BuddyRequestResponse> getMyRequests(User currentUser) {
        return buddyRequestRepository.findByCreatorIdOrderByCreatedAtDesc(currentUser.getId())
                .stream()
                .map(r -> mapToResponse(r, currentUser))
                .collect(Collectors.toList());
    }

    @Transactional
    public BuddyRequestResponse createBuddyRequest(User currentUser, CreateBuddyRequest request) {
        Hobby hobby = hobbyRepository.findById(request.getHobbyId())
                .orElseThrow(() -> new IllegalArgumentException("Hobby not found: " + request.getHobbyId()));

        BuddyRequest buddyRequest = BuddyRequest.builder()
                .creator(currentUser)
                .hobby(hobby)
                .title(request.getTitle().trim())
                .description(request.getDescription().trim())
                .intention(request.getIntention())
                .genderPreference(request.getGenderPreference())
                .creatorGender(request.getCreatorGender() != null ? request.getCreatorGender().trim() : "Belirtilmedi")
                .location(request.getLocation() != null ? request.getLocation().trim() : currentUser.getLocation())
                .preferredTime(request.getPreferredTime() != null ? request.getPreferredTime().trim() : "Müsait vakitlerde")
                .status(BuddyRequestStatus.OPEN)
                .createdAt(Instant.now())
                .build();

        BuddyRequest saved = buddyRequestRepository.save(buddyRequest);
        log.info("User {} created buddy request: {}", currentUser.getUsername(), saved.getTitle());
        return mapToResponse(saved, currentUser);
    }

    @Transactional
    public BuddyMatchResponse connectToBuddyRequest(User currentUser, Long requestId, ConnectBuddyRequest request) {
        BuddyRequest buddyRequest = buddyRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Buddy request not found: " + requestId));

        if (buddyRequest.getCreator().getId().equals(currentUser.getId())) {
            throw new IllegalArgumentException("Kendi ilanınıza başvuru yapamazsınız.");
        }

        var existingMatch = buddyMatchRepository.findByBuddyRequestIdAndApplicantId(requestId, currentUser.getId());
        if (existingMatch.isPresent()) {
            return mapToMatchResponse(existingMatch.get());
        }

        BuddyMatch match = BuddyMatch.builder()
                .buddyRequest(buddyRequest)
                .applicant(currentUser)
                .message(request != null && request.getMessage() != null ? request.getMessage().trim() : "Birlikte hobi yapabiliriz!")
                .status(MatchStatus.PENDING)
                .createdAt(Instant.now())
                .build();

        BuddyMatch saved = buddyMatchRepository.save(match);

        // Bildirim gönder
        notificationService.createNotification(
                buddyRequest.getCreator(),
                "Yeni Hobi Partneri İsteği! 🤝",
                currentUser.getFullName() + " \"" + buddyRequest.getTitle() + "\" ilanınıza eşleşme isteği gönderdi: " + match.getMessage(),
                NotificationType.SYSTEM,
                buddyRequest.getId()
        );

        return mapToMatchResponse(saved);
    }

    @Transactional
    public BuddyMatchResponse updateMatchStatus(User currentUser, Long matchId, MatchStatus newStatus) {
        BuddyMatch match = buddyMatchRepository.findById(matchId)
                .orElseThrow(() -> new IllegalArgumentException("Buddy match not found: " + matchId));

        if (!match.getBuddyRequest().getCreator().getId().equals(currentUser.getId())) {
            throw new org.springframework.security.access.AccessDeniedException("Bu isteği yalnızca ilan sahibi yanıtlayabilir.");
        }

        match.setStatus(newStatus);
        BuddyMatch updated = buddyMatchRepository.save(match);

        if (newStatus == MatchStatus.ACCEPTED) {
            notificationService.createNotification(
                    match.getApplicant(),
                    "Partner İsteğin Kabul Edildi! 🎉",
                    match.getBuddyRequest().getCreator().getFullName() + " eşleşme isteğini kabul etti! Sohbet edip buluşmayı planlayabilirsiniz.",
                    NotificationType.SYSTEM,
                    match.getBuddyRequest().getId()
            );
        }

        return mapToMatchResponse(updated);
    }

    @PostConstruct
    @Transactional
    public void initBuddySeedData() {
        if (buddyRequestRepository.count() == 0) {
            log.info("Seeding initial Hobi Partneri Bul (Buddy matching) requests...");
            User sampleOwner = userRepository.findAll().stream().findFirst().orElse(null);
            Hobby ceramics = hobbyRepository.findByNameIgnoreCase("Ceramics").orElse(null);
            Hobby running = hobbyRepository.findByNameIgnoreCase("Running").orElse(null);
            Hobby photo = hobbyRepository.findByNameIgnoreCase("Photography").orElse(null);
            Hobby horseRiding = hobbyRepository.findByNameIgnoreCase("Horse Riding").orElse(null);

            if (sampleOwner != null && ceramics != null) {
                buddyRequestRepository.save(
                        BuddyRequest.builder()
                                .creator(sampleOwner)
                                .hobby(ceramics)
                                .title("Moda'da Seramik Workshop'una Birlikte Gidelim mi? 🏺☕")
                                .description("Bu pazar Kadıköy Moda'da el yapımı kupa atölyesine gitmek istiyorum. Tek gitmek yerine hem atölyede çamur yoğurup hem de sonrasında kahve içebileceğim bir hobi arkadaşı arıyorum!")
                                .intention(BuddyIntention.DATE)
                                .genderPreference(GenderPreference.ANY)
                                .creatorGender("KADIN")
                                .location("Kadıköy / Moda")
                                .preferredTime("Pazar Günleri 14:00")
                                .status(BuddyRequestStatus.OPEN)
                                .createdAt(Instant.now().minus(java.time.Duration.ofHours(2)))
                                .build()
                );
            }

            if (sampleOwner != null && running != null) {
                buddyRequestRepository.save(
                        BuddyRequest.builder()
                                .creator(sampleOwner)
                                .hobby(running)
                                .title("Caddebostan Sahil Sabah Koşu Partneri 🏃‍♀️")
                                .description("Haftada 2-3 sabah 07:30'da 5K - 7K arası hafif tempo sahil koşusu yapıyorum. Motivasyon için tempo tutabilecek kadın koşu partneri arıyorum.")
                                .intention(BuddyIntention.ACTIVITY)
                                .genderPreference(GenderPreference.FEMALE_ONLY)
                                .creatorGender("KADIN")
                                .location("Caddebostan Sahili")
                                .preferredTime("Salı & Perşembe Sabahları")
                                .status(BuddyRequestStatus.OPEN)
                                .createdAt(Instant.now().minus(java.time.Duration.ofHours(4)))
                                .build()
                );
            }

            if (sampleOwner != null && photo != null) {
                buddyRequestRepository.save(
                        BuddyRequest.builder()
                                .creator(sampleOwner)
                                .hobby(photo)
                                .title("Karaköy & Balat Sokak Fotoğrafçılığı Gezisi 📸")
                                .description("Analog veya dijital makineyle sokak portresi ve ışık kovalayacak, sohbeti keyifli bir fotoğraf dostu arıyorum. Kız veya erkek fark etmez!")
                                .intention(BuddyIntention.FRIENDSHIP)
                                .genderPreference(GenderPreference.ANY)
                                .creatorGender("KADIN")
                                .location("Karaköy / Fatih")
                                .preferredTime("Cumartesi Öğleden Sonra")
                                .status(BuddyRequestStatus.OPEN)
                                .createdAt(Instant.now().minus(java.time.Duration.ofHours(6)))
                                .build()
                );
            }

            if (sampleOwner != null && horseRiding != null) {
                buddyRequestRepository.save(
                        BuddyRequest.builder()
                                .creator(sampleOwner)
                                .hobby(horseRiding)
                                .title("Polonezköy Başlangıç Seviye Binicilik Arkadaşı 🐎")
                                .description("Hafta sonu Polonezköy'deki çiftlikte biniş dersi alıyorum. Birlikte çiftliğe gidip deneyim paylaşabileceğimiz bir partner harika olur.")
                                .intention(BuddyIntention.FRIENDSHIP)
                                .genderPreference(GenderPreference.ANY)
                                .creatorGender("KADIN")
                                .location("Polonezköy / Beykoz")
                                .preferredTime("Hafta Sonu 11:00")
                                .status(BuddyRequestStatus.OPEN)
                                .createdAt(Instant.now().minus(java.time.Duration.ofHours(8)))
                                .build()
                );
            }
        }
    }

    private BuddyRequestResponse mapToResponse(BuddyRequest r, User currentUser) {
        boolean hasApplied = false;
        if (currentUser != null && currentUser.getId() != null) {
            hasApplied = buddyMatchRepository.findByBuddyRequestIdAndApplicantId(r.getId(), currentUser.getId()).isPresent();
        }
        int matchCount = buddyMatchRepository.countByBuddyRequestId(r.getId());

        return BuddyRequestResponse.builder()
                .id(r.getId())
                .creatorId(r.getCreator().getId())
                .creatorUsername(r.getCreator().getUsername())
                .creatorFullName(r.getCreator().getFullName())
                .creatorAvatar(r.getCreator().getAvatar())
                .creatorGender(r.getCreatorGender())
                .hobbyId(r.getHobby().getId())
                .hobbyName(r.getHobby().getName())
                .hobbyIcon(r.getHobby().getIcon())
                .title(r.getTitle())
                .description(r.getDescription())
                .intention(r.getIntention().name())
                .genderPreference(r.getGenderPreference().name())
                .location(r.getLocation())
                .preferredTime(r.getPreferredTime())
                .status(r.getStatus().name())
                .createdAt(r.getCreatedAt())
                .matchCount(matchCount)
                .hasApplied(hasApplied)
                .build();
    }

    private BuddyMatchResponse mapToMatchResponse(BuddyMatch m) {
        return BuddyMatchResponse.builder()
                .id(m.getId())
                .requestId(m.getBuddyRequest().getId())
                .requestTitle(m.getBuddyRequest().getTitle())
                .applicantId(m.getApplicant().getId())
                .applicantUsername(m.getApplicant().getUsername())
                .applicantFullName(m.getApplicant().getFullName())
                .applicantAvatar(m.getApplicant().getAvatar())
                .message(m.getMessage())
                .status(m.getStatus().name())
                .createdAt(m.getCreatedAt())
                .build();
    }
}
