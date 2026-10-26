package com.hobbypath.ai.service;

import com.hobbypath.ai.dto.AiChatRequest;
import com.hobbypath.ai.dto.AiChatResponse;
import com.hobbypath.user.entity.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
@Slf4j
public class AiAssistantService {

    public AiChatResponse processMessage(User user, AiChatRequest request) {
        String rawQuery = request.getMessage() != null ? request.getMessage() : "";
        String norm = rawQuery.toLowerCase(Locale.forLanguageTag("tr-TR"))
                .replace('ı', 'i')
                .replace('ğ', 'g')
                .replace('ü', 'u')
                .replace('ş', 's')
                .replace('ö', 'o')
                .replace('ç', 'c')
                .trim();

        String hobbyContext = request.getHobby() != null ? request.getHobby().toLowerCase() : "";

        String reply;
        List<String> suggestions = new ArrayList<>();
        String category = "Genel";

        if (norm.contains("binic") || norm.contains(" at ") || norm.startsWith("at ") || norm.endsWith(" at") || norm.contains("tayt") || norm.contains("chaps") || norm.contains("eyer") || hobbyContext.contains("horse")) {
            category = "Binicilik";
            if (norm.contains("ekipman") || norm.contains("ne al") || norm.contains("giysi") || norm.contains("kiyafet") || norm.contains("giyme") || norm.contains("giyil") || norm.contains("tayt") || norm.contains("bot")) {
                reply = "🐎 Biniciliğe yeni başlarken büyük masraflar yapmana hiç gerek yok! " +
                        "İlk etapta sadece 3 temel malzeme yeterli:\n\n" +
                        "1. **Binicilik Taytı (Jodhpur/Breeches):** Eyerde kaymayı önleyen diz/sele tutuşlu özel dikişsiz tayt.\n" +
                        "2. **Binicilik Botu & Chaps:** Bacağın alt kısmını eyere sürtünmeden korur.\n" +
                        "3. **Kask (Tog):** Çoğu kulüp ilk başta temin eder, sonrasında kendi kaskını alabilirsin.\n\n" +
                        "💡 *Tavsiye:* HobbyPath 'Acemi Çantası' ve 'Elden Ele Devir' sekmesinden ikinci el uygun ekipmanlara göz atabilirsin!";
                suggestions = List.of("Chaps nedir?", "İlk binicilik dersinde ne yapılır?", "Acemi Çantası listesi");
            } else if (norm.contains("kork") || norm.contains("heyecan") || norm.contains("dus")) {
                reply = "Atlar insanların kalp ritmini ve heyecanını hisseder. Derin nefes alıp omuzlarını gevşetmek hem seni hem atı sakinleştirir. Başlangıç derslerinde eğitmen daima lonj (ip) kontrolünde çalışır, tamamen güvendesin!";
                suggestions = List.of("Tırıs ve adeta farkı nedir?", "Atı nasıl yönlendiririm?", "Binicilik kulüpleri");
            } else {
                reply = "At biniciliği muazzam bir denge, karın kası ve odaklanma sporudur. Haftada 1 gün 45 dakikalık temel binicilik dersiyle başlayabilirsin. İstanbul'da Polonezköy ve Kemerburgaz rotaları harika seçeneklerdir.";
                suggestions = List.of("Binicilik için gereken ekipmanlar", "Buluşma etkinliklerine bak", "Binicilik bulmacası çöz");
            }
        } else if (norm.contains("seramik") || norm.contains("kil") || norm.contains("camur") || norm.contains("torna") || hobbyContext.contains("ceramic")) {
            category = "Seramik";
            if (norm.contains("merkez") || norm.contains("torna")) {
                reply = "🏺 Torna üzerinde kili merkezlemek (centering) seramiğin temelidir! " +
                        "Kollarını bacaklarına yaslayıp dirseklerini kilitle. Avuç içlerinle kili eşit kuvvetle bastırarak koni yap ve tekrar indir ('wheeling'). Kil titreşimsiz döndüğünde kupanı açmaya hazırsın.";
                suggestions = List.of("Ebesuar ne işe yarar?", "Bisküvi pişirimi kaç derecede yapılır?", "Kadıköy Seramik Atölyesi");
            } else {
                reply = "Seramik, zihni sakinleştiren harika bir dokunsal meditasyondur. İster el yapımı (çimdik ve fitil) ister tornada fincan ve tabak yaparak başlayabilirsin. Atölyeler tüm kil ve fırınlama hizmetini sunar.";
                suggestions = List.of("Seramik başlangıç ekipmanları", "Seramik partneri bul", "Günün seramik sorusu");
            }
        } else if (norm.contains("kosu") || norm.contains("kos") || norm.contains("maraton") || norm.contains("kadans") || hobbyContext.contains("run")) {
            category = "Koşu";
            if (norm.contains("plan") || norm.contains("5k") || norm.contains("basla") || norm.contains("nasil")) {
                reply = "🏃 Harika bir karar! Sıfırdan 5K'ya başlamak için 'Koş-Yürü' metodu (Galloway) en güvenlisidir:\n\n" +
                        "• Hafta 1: 1 dk hafif koşu + 2 dk yürüyüş (toplam 20 dk, haftada 3 gün)\n" +
                        "• Hafta 2: 2 dk koşu + 1.5 dk yürüyüş\n" +
                        "• Kadansını 170-180 aralığında tutmaya çalış, adımlarını öne fırlatmak yerine gövdenin altına bas!";
                suggestions = List.of("Koşu ayakkabısı nasıl seçilir?", "Kadans nedir?", "Caddebostan koşu grubu");
            } else {
                reply = "Düzenli sabah koşusu hem endorfin salgılatır hem de zihni berraklaştırır. Sahil parkurları ve yumuşak zeminler diz sağlığın için beton zeminden çok daha iyidir.";
                suggestions = List.of("5K koşu planı", "Koşu partneri ara", "Günün koşu trivia testi");
            }
        } else if (norm.contains("fotograf") || norm.contains("kamera") || norm.contains("lens") || norm.contains("diyafram") || hobbyContext.contains("photo")) {
            category = "Fotoğrafçılık";
            reply = "📸 Fotoğrafçılıkta ışığı görmek her şeydir! Pozlama üçgeni (Diyafram - Enstantane - ISO) dengesini kavradığında manuel modda sihir yaratırsın. Portre için geniş diyafram (f/1.8 gibi), manzara için f/8 veya f/11 tercih et.";
            suggestions = List.of("Bokeh etkisi nasıl yapılır?", "Balat fotoğraf yürüyüşü", "Hangi kamerayla başlamalıyım?");
        } else if (norm.contains("yemek") || norm.contains("pisir") || norm.contains("makarna") || norm.contains("mutfak") || hobbyContext.contains("cook")) {
            category = "Gastronomi";
            reply = "🍳 İyi yemek tariften değil, ısı kontrolü ve tuz dengesinden geçer! Örneğin taze ev makarnasında un-yumurta oranı (100g un / 1 yumurta) altın kuraldır. Makarnanı asla durulama, nişastalı haşlama suyu sosu bağlar.";
            suggestions = List.of("İtalyan makarna atölyesi", "Acemi mutfak bıçakları", "Maillard reaksiyonu nedir?");
        } else if (norm.contains("doga") || norm.contains("yuruyus") || norm.contains("trekking") || norm.contains("kamp") || norm.contains("hiking") || hobbyContext.contains("hik")) {
            category = "Doğa Yürüyüşü";
            reply = "🌲 Doğa yürüyüşünde altın kural katmanlı giyim (Termal içlik + Polar + Su geçirmez kabuk) ve bileği saran iyi bir trekking botudur. Baton kullanımı inişlerde dizlere binen yükü %25 azaltır.";
            suggestions = List.of("Ballıkayalar yürüyüşü", "Trekking çantası hazırlama", "Baton seçimi");
        } else {
            reply = "Merhaba " + (user != null ? user.getFullName() : "Hobi Dostu") + "! 👋 Ben senin kişisel HobbyPath AI rehberinim. " +
                    "Yeni bir hobiye başlama adımları, temel ekipman önerileri, antrenman planları veya atölye teknikleri hakkında merak ettiğin her şeyi bana sorabilirsin!";
            suggestions = List.of("Binicilik için minimum ne gerekli?", "5K koşu antrenman planı", "Hobi bulmacalarını oyna", "Yakınımdaki etkinlikler");
        }

        return AiChatResponse.builder()
                .reply(reply)
                .role("assistant")
                .suggestions(suggestions)
                .category(category)
                .build();
    }
}
