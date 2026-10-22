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

    @Override
    public void run(String... args) {
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
}
