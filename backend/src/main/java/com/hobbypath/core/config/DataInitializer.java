package com.hobbypath.core.config;

import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final HobbyRepository hobbyRepository;
    private final com.hobbypath.user.repository.UserRepository userRepository;
    private final com.hobbypath.community.repository.CommunityRepository communityRepository;
    private final com.hobbypath.event.repository.EventRepository eventRepository;
    private final com.hobbypath.event.repository.EventParticipantRepository participantRepository;

    @Override
    public void run(String... args) {
        seedHobbies();
        seedCommunitiesAndEvents();
    }

    private void seedHobbies() {
        if (hobbyRepository.count() == 0) {
            log.info("Seeding initial curated hobbies into database...");

            List<Hobby> initialHobbies = List.of(
                    Hobby.builder()
                            .name("Horse Riding")
                            .category("Sports")
                            .icon("🐎")
                            .description("At biniciliği, at bakımı, eğitim ve açık hava biniş deneyimi.")
                            .build(),
                    Hobby.builder()
                            .name("Ceramics")
                            .category("Arts & Crafts")
                            .icon("🏺")
                            .description("Kil şekillendirme, torna, çömlekçilik ve seramik atölyeleri.")
                            .build(),
                    Hobby.builder()
                            .name("Photography")
                            .category("Visual Arts")
                            .icon("📸")
                            .description("Dijital ve analog fotoğrafçılık, portre, manzara ve ışık teknikleri.")
                            .build(),
                    Hobby.builder()
                            .name("Reading")
                            .category("Literature")
                            .icon("📚")
                            .description("Kitap kulüpleri, tahlil buluşmaları, kurgu ve kurgu dışı edebiyat.")
                            .build(),
                    Hobby.builder()
                            .name("Running")
                            .category("Sports")
                            .icon("🏃")
                            .description("Sabah koşuları, yarı maraton ve maraton antrenmanları.")
                            .build(),
                    Hobby.builder()
                            .name("Hiking")
                            .category("Outdoor")
                            .icon("🌲")
                            .description("Doğa yürüyüşleri, trekking, rota keşifleri ve kamp etkinlikleri.")
                            .build(),
                    Hobby.builder()
                            .name("Cooking")
                            .category("Culinary")
                            .icon("🍳")
                            .description("Dünya mutfağı, fırıncılık, ev yapımı lezzetler ve gastronomi atölyeleri.")
                            .build(),
                    Hobby.builder()
                            .name("Programming")
                            .category("Technology")
                            .icon("💻")
                            .description("Yazılım geliştirme, açık kaynak projeler, mobil ve web teknolojileri.")
                            .build()
            );

            hobbyRepository.saveAll(initialHobbies);
            log.info("Successfully seeded {} hobbies.", initialHobbies.size());
        }
    }

    private void seedCommunitiesAndEvents() {
        if (communityRepository.count() <= 1) {
            com.hobbypath.user.entity.User organizer = userRepository.findAll().stream().findFirst().orElse(null);
            if (organizer == null) return;

            log.info("Seeding diverse communities and events across hobbies...");

            // 1. Ceramics
            Hobby ceramics = hobbyRepository.findByNameIgnoreCase("Ceramics").orElse(null);
            if (ceramics != null) {
                com.hobbypath.community.entity.Community comm = communityRepository.save(
                        com.hobbypath.community.entity.Community.builder()
                                .name("Kadıköy Çamur & Seramik Atölyesi")
                                .description("Çömlek tornası, kil şekillendirme ve el yapımı seramik sevenler.")
                                .hobby(ceramics)
                                .creator(organizer)
                                .memberCount(14)
                                .build()
                );
                eventRepository.save(
                        com.hobbypath.event.entity.Event.builder()
                                .title("Hafta Sonu Torna & Kupa Tasarımı Workshop'u")
                                .description("Kendi kahve kupanızı sıfırdan çamurla şekillendirip boyuyoruz.")
                                .community(comm)
                                .organizer(organizer)
                                .location("Moda Caddesi No:42, Kadıköy, İstanbul")
                                .eventDate(java.time.Instant.now().plus(java.time.Duration.ofDays(4)))
                                .capacity(6)
                                .currentParticipants(3)
                                .status(com.hobbypath.event.entity.EventStatus.UPCOMING)
                                .build()
                );
            }

            // 2. Running
            Hobby running = hobbyRepository.findByNameIgnoreCase("Running").orElse(null);
            if (running != null) {
                com.hobbypath.community.entity.Community comm = communityRepository.save(
                        com.hobbypath.community.entity.Community.builder()
                                .name("Caddebostan Sahil Koşucuları")
                                .description("Hafta sonu sabah sahil boyunca hafif tempo koşan hobi koşucuları.")
                                .hobby(running)
                                .creator(organizer)
                                .memberCount(28)
                                .build()
                );
                eventRepository.save(
                        com.hobbypath.event.entity.Event.builder()
                                .title("Pazar Sabahı 6K Sahil Koşusu & Kahve Sohbeti")
                                .description("Caddebostan Beltur önünden başlayıp Fenerbahçe Parkı'na koşuyoruz.")
                                .community(comm)
                                .organizer(organizer)
                                .location("Caddebostan Sahili, Kadıköy, İstanbul")
                                .eventDate(java.time.Instant.now().plus(java.time.Duration.ofDays(6)))
                                .capacity(15)
                                .currentParticipants(7)
                                .status(com.hobbypath.event.entity.EventStatus.UPCOMING)
                                .build()
                );
            }

            // 3. Photography
            Hobby photo = hobbyRepository.findByNameIgnoreCase("Photography").orElse(null);
            if (photo != null) {
                com.hobbypath.community.entity.Community comm = communityRepository.save(
                        com.hobbypath.community.entity.Community.builder()
                                .name("İstanbul Sokak Fotoğrafçıları")
                                .description("Tarihi yarımada, sokak portreleri ve ışık-gölge çalışmaları.")
                                .hobby(photo)
                                .creator(organizer)
                                .memberCount(19)
                                .build()
                );
                eventRepository.save(
                        com.hobbypath.event.entity.Event.builder()
                                .title("Karaköy & Balat Gün Batımı Fotoğraf Yürüyüşü")
                                .description("Tarihi sokaklarda ışığı yakalayıp analog ve dijital çekimler yapıyoruz.")
                                .community(comm)
                                .organizer(organizer)
                                .location("Karaköy İskele Önü, Beyoğlu, İstanbul")
                                .eventDate(java.time.Instant.now().plus(java.time.Duration.ofDays(8)))
                                .capacity(8)
                                .currentParticipants(4)
                                .status(com.hobbypath.event.entity.EventStatus.UPCOMING)
                                .build()
                );
            }

            // 4. Cooking
            Hobby cooking = hobbyRepository.findByNameIgnoreCase("Cooking").orElse(null);
            if (cooking != null) {
                com.hobbypath.community.entity.Community comm = communityRepository.save(
                        com.hobbypath.community.entity.Community.builder()
                                .name("Artisan Mutfak & Gastronomi Atölyesi")
                                .description("Evde dünya mutfağı lezzetleri, ekmek ve makarna meraklıları.")
                                .hobby(cooking)
                                .creator(organizer)
                                .memberCount(22)
                                .build()
                );
                eventRepository.save(
                        com.hobbypath.event.entity.Event.builder()
                                .title("Ev Yapımı İtalyan Taze Makarna & Pesto Atölyesi")
                                .description("Sıfırdan un ve yumurtayla tagliatelle açıp taze pesto sosu pişiriyoruz.")
                                .community(comm)
                                .organizer(organizer)
                                .location("Akaretler Mutfak Stüdyosu, Beşiktaş, İstanbul")
                                .eventDate(java.time.Instant.now().plus(java.time.Duration.ofDays(10)))
                                .capacity(5)
                                .currentParticipants(2)
                                .status(com.hobbypath.event.entity.EventStatus.UPCOMING)
                                .build()
                );
            }

            // 5. Hiking
            Hobby hiking = hobbyRepository.findByNameIgnoreCase("Hiking").orElse(null);
            if (hiking != null) {
                com.hobbypath.community.entity.Community comm = communityRepository.save(
                        com.hobbypath.community.entity.Community.builder()
                                .name("Doğa & Zirve Rota Gezginleri")
                                .description("Hafta sonu doğada trekking, kanyon geçişi ve kamp rotaları.")
                                .hobby(hiking)
                                .creator(organizer)
                                .memberCount(35)
                                .build()
                );
                eventRepository.save(
                        com.hobbypath.event.entity.Event.builder()
                                .title("Ballıkayalar Kanyonu Sonbahar Doğa Yürüyüşü")
                                .description("9 kilometrelik kanyon içi kayalık parkur ve doğa kampı.")
                                .community(comm)
                                .organizer(organizer)
                                .location("Ballıkayalar Tabiat Parkı Girişi, Gebze")
                                .eventDate(java.time.Instant.now().plus(java.time.Duration.ofDays(12)))
                                .capacity(12)
                                .currentParticipants(5)
                                .status(com.hobbypath.event.entity.EventStatus.UPCOMING)
                                .build()
                );
            }
        }
    }
}
