package com.hobbypath.gear.service;

import com.hobbypath.gear.dto.CreateGearTransferRequest;
import com.hobbypath.gear.dto.GearTransferResponse;
import com.hobbypath.gear.dto.StarterGearResponse;
import com.hobbypath.gear.entity.GearTransfer;
import com.hobbypath.gear.entity.StarterGear;
import com.hobbypath.gear.entity.TransferStatus;
import com.hobbypath.gear.entity.TransferType;
import com.hobbypath.gear.repository.GearTransferRepository;
import com.hobbypath.gear.repository.StarterGearRepository;
import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import com.hobbypath.user.entity.User;
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
public class GearService {

    private final StarterGearRepository starterGearRepository;
    private final GearTransferRepository gearTransferRepository;
    private final HobbyRepository hobbyRepository;
    private final com.hobbypath.user.repository.UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<StarterGearResponse> getStarterGears(Long hobbyId) {
        List<StarterGear> list;
        if (hobbyId != null) {
            list = starterGearRepository.findByHobbyIdOrderByPriorityOrderAsc(hobbyId);
        } else {
            list = starterGearRepository.findAllByOrderByPriorityOrderAsc();
        }
        return list.stream().map(this::mapToStarterGearResponse).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<GearTransferResponse> getTransfers(Long hobbyId, TransferType type) {
        List<GearTransfer> list;
        if (hobbyId != null) {
            list = gearTransferRepository.findByHobbyIdAndStatusOrderByCreatedAtDesc(hobbyId, TransferStatus.AVAILABLE);
        } else {
            list = gearTransferRepository.findByStatusOrderByCreatedAtDesc(TransferStatus.AVAILABLE);
        }

        if (type != null) {
            list = list.stream().filter(t -> t.getTransferType() == type).collect(Collectors.toList());
        }

        return list.stream().map(this::mapToGearTransferResponse).collect(Collectors.toList());
    }

    @Transactional
    public GearTransferResponse createTransfer(User user, CreateGearTransferRequest request) {
        Hobby hobby = hobbyRepository.findById(request.getHobbyId())
                .orElseThrow(() -> new IllegalArgumentException("Hobby not found with id: " + request.getHobbyId()));

        GearTransfer transfer = GearTransfer.builder()
                .owner(user)
                .hobby(hobby)
                .title(request.getTitle().trim())
                .description(request.getDescription().trim())
                .transferType(request.getTransferType())
                .itemCondition(request.getItemCondition() != null ? request.getItemCondition().trim() : "İyi Durumda")
                .location(request.getLocation() != null ? request.getLocation().trim() : user.getLocation())
                .contactInfo(request.getContactInfo() != null ? request.getContactInfo().trim() : user.getEmail())
                .imageUrl(request.getImageUrl() != null ? request.getImageUrl().trim() : null)
                .status(TransferStatus.AVAILABLE)
                .createdAt(Instant.now())
                .build();

        GearTransfer saved = gearTransferRepository.save(transfer);
        log.info("User {} created gear transfer listing: {}", user.getUsername(), saved.getTitle());
        return mapToGearTransferResponse(saved);
    }

    @Transactional
    public GearTransferResponse updateTransferStatus(User user, Long transferId, TransferStatus newStatus) {
        GearTransfer transfer = gearTransferRepository.findById(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Transfer listing not found: " + transferId));

        if (!transfer.getOwner().getId().equals(user.getId())) {
            throw new org.springframework.security.access.AccessDeniedException("Bu ilanı yalnızca ilanın sahibi güncelleyebilir.");
        }

        transfer.setStatus(newStatus);
        GearTransfer updated = gearTransferRepository.save(transfer);
        return mapToGearTransferResponse(updated);
    }

    @Transactional
    public void deleteTransfer(User user, Long transferId) {
        GearTransfer transfer = gearTransferRepository.findById(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Transfer listing not found: " + transferId));

        if (!transfer.getOwner().getId().equals(user.getId())) {
            throw new org.springframework.security.access.AccessDeniedException("Bu ilanı yalnızca ilanın sahibi silebilir.");
        }

        gearTransferRepository.delete(transfer);
    }

    @PostConstruct
    @Transactional
    public void initStarterGears() {
        if (starterGearRepository.count() == 0) {
            log.info("Seeding initial Acemi Çantası (Minimum Starter Gear) checklists...");

            // 1. Binicilik (Horse Riding) - Nevin'in özellikle bahsettiği Chaps, Tayt, Bot!
            Hobby horseRiding = hobbyRepository.findByNameIgnoreCase("Horse Riding").orElse(null);
            if (horseRiding != null) {
                starterGearRepository.saveAll(List.of(
                        StarterGear.builder()
                                .hobby(horseRiding)
                                .name("Binicilik Chaps (Deri veya Süet)")
                                .icon("👢")
                                .mandatory(true)
                                .estimatedBudget("350 - 750 TL")
                                .advice("Bacağın iç kısmını eğere sürtünmekten korur, başlangıçta pahalı deri yerine dayanıklı süet chaps fazlasıyla yeterlidir.")
                                .priorityOrder(1)
                                .build(),
                        StarterGear.builder()
                                .hobby(horseRiding)
                                .name("Binicilik Taytı (Kaymaz Silikonlu)")
                                .icon("👖")
                                .mandatory(true)
                                .estimatedBudget("400 - 800 TL")
                                .advice("Eğer üzerinde kaymayı önler ve dikişsiz iç yapısıyla bacak tahrişini engeller. Temel seviye için şarttır.")
                                .priorityOrder(2)
                                .build(),
                        StarterGear.builder()
                                .hobby(horseRiding)
                                .name("Düz Tabanlı Kısa Binicilik Botu (Jodhpur)")
                                .icon("🥾")
                                .mandatory(true)
                                .estimatedBudget("600 - 1200 TL")
                                .advice("Üzengiye takılmayacak küçük topuklu ve düz tabanlı olmalıdır. Chaps ile birleştiğinde uzun çizme işlevi görür.")
                                .priorityOrder(3)
                                .build(),
                        StarterGear.builder()
                                .hobby(horseRiding)
                                .name("Binicilik Toku (Kask)")
                                .icon("⛑️")
                                .mandatory(false)
                                .estimatedBudget("Genellikle Çiftlikte Ücretsiz Verilir")
                                .advice("Güvenlik için şarttır ancak neredeyse tüm çiftlikler başlangıç öğrencilerine ücretsiz temin eder, hemen satın almanıza gerek yoktur.")
                                .priorityOrder(4)
                                .build(),
                        StarterGear.builder()
                                .hobby(horseRiding)
                                .name("Binicilik Eldiveni & Kamçı")
                                .icon("🧤")
                                .mandatory(false)
                                .estimatedBudget("Opsiyonel (200 - 400 TL)")
                                .advice("Dizginlerin eli acıtmasını önler. İlerleyen aylarda antrenörünüz önerdiğinde alabilirsiniz.")
                                .priorityOrder(5)
                                .build()
                ));
            }

            // 2. Seramik (Ceramics)
            Hobby ceramics = hobbyRepository.findByNameIgnoreCase("Ceramics").orElse(null);
            if (ceramics != null) {
                starterGearRepository.saveAll(List.of(
                        StarterGear.builder()
                                .hobby(ceramics)
                                .name("Temel Çamur Şekillendirme Ebeşuar Seti (8 Parça)")
                                .icon("🪵")
                                .mandatory(true)
                                .estimatedBudget("150 - 300 TL")
                                .advice("Kili kesmek, oymak ve düzleştirmek için gereken ahşap ve metal uçlu temel alet seti.")
                                .priorityOrder(1)
                                .build(),
                        StarterGear.builder()
                                .hobby(ceramics)
                                .name("Atölye Önlüğü & Sünger")
                                .icon("🦺")
                                .mandatory(true)
                                .estimatedBudget("100 - 200 TL")
                                .advice("Kıyafetleri kilden korur, doğal sünger ise tornada kil nemlendirme ve pürüzsüzleştirme için vazgeçilmezdir.")
                                .priorityOrder(2)
                                .build(),
                        StarterGear.builder()
                                .hobby(ceramics)
                                .name("Masaüstü Turnet (Döner Tabla)")
                                .icon("🔄")
                                .mandatory(false)
                                .estimatedBudget("Opsiyonel / Ev Çalışması İçin")
                                .advice("Atölye derslerinde bulunur. Yalnızca evde bağımsız heykel/kupa yapacaksanız gereklidir.")
                                .priorityOrder(3)
                                .build()
                ));
            }

            // 3. Fotoğrafçılık (Photography)
            Hobby photo = hobbyRepository.findByNameIgnoreCase("Photography").orElse(null);
            if (photo != null) {
                starterGearRepository.saveAll(List.of(
                        StarterGear.builder()
                                .hobby(photo)
                                .name("50mm f/1.8 Lens (Nifty Fifty)")
                                .icon("📷")
                                .mandatory(true)
                                .estimatedBudget("İkinci El Uygun / Temel")
                                .advice("Geniş diyaframı sayesinde arka planı flu (bokeh) yapar, düşük ışıkta harikadır ve kompozisyon öğretir.")
                                .priorityOrder(1)
                                .build(),
                        StarterGear.builder()
                                .hobby(photo)
                                .name("Hafıza Kartı (Hızlı SDXC Class 10) & Lens Bezi")
                                .icon("💾")
                                .mandatory(true)
                                .estimatedBudget("250 - 450 TL")
                                .advice("Çekim ortasında donma yaşamamak ve lensi tozdan arındırmak için olmazsa olmaz ikili.")
                                .priorityOrder(2)
                                .build(),
                        StarterGear.builder()
                                .hobby(photo)
                                .name("Hafif Seyahat Tripodu")
                                .icon("📐")
                                .mandatory(false)
                                .estimatedBudget("Opsiyonel (500 - 900 TL)")
                                .advice("Gece veya uzun pozlama manzara çekimleri haricinde başlangıçta zorunlu değildir.")
                                .priorityOrder(3)
                                .build()
                ));
            }

            // 4. Koşu (Running)
            Hobby running = hobbyRepository.findByNameIgnoreCase("Running").orElse(null);
            if (running != null) {
                starterGearRepository.saveAll(List.of(
                        StarterGear.builder()
                                .hobby(running)
                                .name("Yastıklamalı Yol Koşu Ayakkabısı")
                                .icon("👟")
                                .mandatory(true)
                                .estimatedBudget("Orta Bütçe")
                                .advice("Diz ve ayak bileği sakatlıklarını önleyen tek ve en önemli yatırımdır. Günlük sneaker ile koşulmamalıdır.")
                                .priorityOrder(1)
                                .build(),
                        StarterGear.builder()
                                .hobby(running)
                                .name("Nefes Alabilir Koşu Çorabı & Şortu")
                                .icon("🧦")
                                .mandatory(true)
                                .estimatedBudget("150 - 300 TL")
                                .advice("Sürtünmeye bağlı su toplamalarını engeller.")
                                .priorityOrder(2)
                                .build(),
                        StarterGear.builder()
                                .hobby(running)
                                .name("GPS Koşu Saati")
                                .icon("⌚")
                                .mandatory(false)
                                .estimatedBudget("Lüks / Opsiyonel")
                                .advice("Telefonunuzdaki Strava uygulaması ilk 6 ay tüm temponuzu ve mesafenizi ücretsiz takip eder.")
                                .priorityOrder(3)
                                .build()
                ));
            }

            // 5. Doğa Yürüyüşü & Hiking
            Hobby hiking = hobbyRepository.findByNameIgnoreCase("Hiking").orElse(null);
            if (hiking != null) {
                starterGearRepository.saveAll(List.of(
                        StarterGear.builder()
                                .hobby(hiking)
                                .name("Bileği Tutan Vibram Tabanlı Trekking Botu")
                                .icon("🥾")
                                .mandatory(true)
                                .estimatedBudget("Orta / Dayanıklı")
                                .advice("Kayalık ve çamurlu arazide burkulmaları önler ve su geçirmezliği ile konfor sağlar.")
                                .priorityOrder(1)
                                .build(),
                        StarterGear.builder()
                                .hobby(hiking)
                                .name("20-30L Günlük Sırt Çantası & Termos")
                                .icon("🎒")
                                .mandatory(true)
                                .estimatedBudget("300 - 600 TL")
                                .advice("Su, hafif atıştırmalık ve yağmurluk taşımak için yeterli hacim sağlar.")
                                .priorityOrder(2)
                                .build(),
                        StarterGear.builder()
                                .hobby(hiking)
                                .name("Teleskopik Yürüyüş Batonu")
                                .icon("🦯")
                                .mandatory(false)
                                .estimatedBudget("Opsiyonel (200 - 400 TL)")
                                .advice("Diz yükünü %25 azaltır, dik iniş ve çıkışlarda denge verir.")
                                .priorityOrder(3)
                                .build()
                ));
            }
        }

        // Örnek Pay-it-Forward devir ilanları tohumlama (Community Seeding)
        if (gearTransferRepository.count() == 0) {
            log.info("Seeding initial community Pay-It-Forward gear transfers...");
            User sampleOwner = userRepository.findAll().stream().findFirst().orElse(null);

            Hobby horseRiding = hobbyRepository.findByNameIgnoreCase("Horse Riding").orElse(null);
            Hobby ceramics = hobbyRepository.findByNameIgnoreCase("Ceramics").orElse(null);
            Hobby photo = hobbyRepository.findByNameIgnoreCase("Photography").orElse(null);

            if (sampleOwner != null && horseRiding != null) {
                gearTransferRepository.save(
                        GearTransfer.builder()
                                .owner(sampleOwner)
                                .hobby(horseRiding)
                                .title("38 Numara Temiz Süet Chaps & Başlangıç Botu")
                                .description("Bir üst seviyeye geçtiğim için kullanmadığım chaps ve botumu biniciliğe yeni başlayacak bir öğrenci arkadaşımıza hediye etmek istiyorum. Yırtığı söküğü yoktur.")
                                .transferType(TransferType.GIFT)
                                .itemCondition("Az Kullanılmış / Çok Temiz")
                                .location("Kadıköy İskele / İstanbul")
                                .contactInfo("@nevin (Uygulama içi DM veya Kadıköy elden teslim)")
                                .imageUrl("https://images.unsplash.com/photo-1598971861713-54ad16a7e72e?w=500")
                                .status(TransferStatus.AVAILABLE)
                                .createdAt(Instant.now().minus(java.time.Duration.ofHours(3)))
                                .build()
                );
            }

            if (sampleOwner != null && ceramics != null) {
                gearTransferRepository.save(
                        GearTransfer.builder()
                                .owner(sampleOwner)
                                .hobby(ceramics)
                                .title("8'li Ahşap Kil & Çömlek Ebeşuar Seti (Ödünç / Devir)")
                                .description("Atölye dönemi bittiği için şu an boşta duran şekillendirme aletlerimi denemek isteyen birine 1 aylığına ödünç verebilirim veya çay kahve ısmarlaması karşılığı devredebilirim.")
                                .transferType(TransferType.SYMBOLIC)
                                .itemCondition("Sıfır Gibi")
                                .location("Beşiktaş / İstanbul")
                                .contactInfo("Uygulama içi mesaj atabilirsiniz")
                                .imageUrl("https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=500")
                                .status(TransferStatus.AVAILABLE)
                                .createdAt(Instant.now().minus(java.time.Duration.ofHours(5)))
                                .build()
                );
            }

            if (sampleOwner != null && photo != null) {
                gearTransferRepository.save(
                        GearTransfer.builder()
                                .owner(sampleOwner)
                                .hobby(photo)
                                .title("Canon Uyumlu 58mm UV Filtre & Taşıma Çantası")
                                .description("Yeni lense geçtiğim için çapı uymuyor. İhtiyacı olan genç fotoğrafçı arkadaşımıza ücretsiz hediye!")
                                .transferType(TransferType.GIFT)
                                .itemCondition("Çiziksiz / Temiz")
                                .location("Mecidiyeköy / İstanbul")
                                .contactInfo("@ahmet (DM yoluyla ulaşabilirsiniz)")
                                .imageUrl("https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500")
                                .status(TransferStatus.AVAILABLE)
                                .createdAt(Instant.now().minus(java.time.Duration.ofHours(8)))
                                .build()
                );
            }
        }
    }

    private StarterGearResponse mapToStarterGearResponse(StarterGear gear) {
        return StarterGearResponse.builder()
                .id(gear.getId())
                .hobbyId(gear.getHobby().getId())
                .hobbyName(gear.getHobby().getName())
                .name(gear.getName())
                .icon(gear.getIcon())
                .mandatory(gear.isMandatory())
                .estimatedBudget(gear.getEstimatedBudget())
                .advice(gear.getAdvice())
                .priorityOrder(gear.getPriorityOrder())
                .build();
    }

    private GearTransferResponse mapToGearTransferResponse(GearTransfer transfer) {
        return GearTransferResponse.builder()
                .id(transfer.getId())
                .ownerId(transfer.getOwner().getId())
                .ownerUsername(transfer.getOwner().getUsername())
                .ownerFullName(transfer.getOwner().getFullName())
                .ownerAvatar(transfer.getOwner().getAvatar())
                .hobbyId(transfer.getHobby().getId())
                .hobbyName(transfer.getHobby().getName())
                .hobbyIcon(transfer.getHobby().getIcon())
                .title(transfer.getTitle())
                .description(transfer.getDescription())
                .transferType(transfer.getTransferType().name())
                .itemCondition(transfer.getItemCondition())
                .location(transfer.getLocation())
                .contactInfo(transfer.getContactInfo())
                .imageUrl(transfer.getImageUrl())
                .status(transfer.getStatus().name())
                .createdAt(transfer.getCreatedAt())
                .build();
    }
}
