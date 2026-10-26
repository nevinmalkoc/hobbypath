package com.hobbypath.puzzle.service;

import com.hobbypath.hobby.entity.Hobby;
import com.hobbypath.hobby.repository.HobbyRepository;
import com.hobbypath.puzzle.dto.DailyPuzzleResponse;
import com.hobbypath.puzzle.dto.LeaderboardEntryResponse;
import com.hobbypath.puzzle.dto.SolvePuzzleRequest;
import com.hobbypath.puzzle.dto.TriviaQuestionResponse;
import com.hobbypath.puzzle.entity.DailyPuzzle;
import com.hobbypath.puzzle.entity.PuzzleAttempt;
import com.hobbypath.puzzle.entity.TriviaQuestion;
import com.hobbypath.puzzle.repository.DailyPuzzleRepository;
import com.hobbypath.puzzle.repository.PuzzleAttemptRepository;
import com.hobbypath.puzzle.repository.TriviaQuestionRepository;
import com.hobbypath.user.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DailyPuzzleService {

    private final DailyPuzzleRepository puzzleRepository;
    private final PuzzleAttemptRepository attemptRepository;
    private final TriviaQuestionRepository triviaRepository;
    private final HobbyRepository hobbyRepository;

    @Transactional
    public DailyPuzzleResponse getTodayPuzzle(User currentUser, Long hobbyId) {
        LocalDate today = LocalDate.now();
        DailyPuzzle puzzle;

        if (hobbyId != null) {
            puzzle = puzzleRepository.findByPuzzleDateAndHobbyId(today, hobbyId)
                    .orElseGet(() -> seedOrFetchPuzzleForHobby(today, hobbyId));
        } else {
            puzzle = puzzleRepository.findFirstByPuzzleDate(today)
                    .orElseGet(() -> seedTodayPuzzle(today));
        }

        boolean alreadySolved = false;
        Integer myTime = null;

        if (currentUser != null && puzzle.getId() != null) {
            Optional<PuzzleAttempt> attempt = attemptRepository.findByPuzzleIdAndUserId(puzzle.getId(), currentUser.getId());
            if (attempt.isPresent()) {
                alreadySolved = true;
                myTime = attempt.get().getCompletionTimeSeconds();
            }
        }

        return DailyPuzzleResponse.builder()
                .id(puzzle.getId())
                .puzzleDate(puzzle.getPuzzleDate())
                .hobbyName(puzzle.getHobby() != null ? puzzle.getHobby().getName() : "Genel Hobi")
                .hobbyIcon(puzzle.getHobby() != null ? puzzle.getHobby().getIcon() : "🧩")
                .title(puzzle.getTitle())
                .clue(puzzle.getClue())
                .answerLength(puzzle.getAnswer().length())
                .scrambledLetters(puzzle.getScrambledLetters())
                .alreadySolved(alreadySolved)
                .myCompletionTimeSeconds(myTime)
                .build();
    }

    @Transactional
    public LeaderboardEntryResponse solvePuzzle(User user, Long puzzleId, SolvePuzzleRequest request) {
        DailyPuzzle puzzle = puzzleRepository.findById(puzzleId)
                .orElseThrow(() -> new IllegalArgumentException("Bulmaca bulunamadı: " + puzzleId));

        String submitted = request.getAnswer().trim().toUpperCase(Locale.forLanguageTag("tr-TR"));
        String expected = puzzle.getAnswer().trim().toUpperCase(Locale.forLanguageTag("tr-TR"));

        // Fallback standard uppercase comparison
        if (!submitted.equals(expected) && !submitted.equalsIgnoreCase(expected)) {
            throw new IllegalArgumentException("Cevap doğru değil! İpucuna tekrar bakın.");
        }

        Optional<PuzzleAttempt> existing = attemptRepository.findByPuzzleIdAndUserId(puzzleId, user.getId());
        PuzzleAttempt attempt;

        if (existing.isPresent()) {
            attempt = existing.get();
        } else {
            attempt = PuzzleAttempt.builder()
                    .puzzle(puzzle)
                    .user(user)
                    .completionTimeSeconds(Math.max(1, request.getCompletionTimeSeconds()))
                    .solved(true)
                    .build();
            attempt = attemptRepository.save(attempt);
            log.info("User {} solved daily puzzle {} in {} seconds!", user.getUsername(), puzzleId, attempt.getCompletionTimeSeconds());
        }

        return LeaderboardEntryResponse.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .completionTimeSeconds(attempt.getCompletionTimeSeconds())
                .solvedAt(attempt.getSolvedAt())
                .build();
    }

    @Transactional(readOnly = true)
    public List<LeaderboardEntryResponse> getLeaderboard(Long puzzleId, int limit) {
        int pageSize = Math.min(Math.max(limit, 5), 50);
        List<PuzzleAttempt> attempts = attemptRepository.findTopByPuzzleIdOrderByTime(
                puzzleId,
                PageRequest.of(0, pageSize)
        );

        List<LeaderboardEntryResponse> result = new ArrayList<>();
        int rank = 1;
        for (PuzzleAttempt a : attempts) {
            result.add(LeaderboardEntryResponse.builder()
                    .rank(rank++)
                    .userId(a.getUser().getId())
                    .username(a.getUser().getUsername())
                    .fullName(a.getUser().getFullName())
                    .completionTimeSeconds(a.getCompletionTimeSeconds())
                    .solvedAt(a.getSolvedAt())
                    .build());
        }
        return result;
    }

    @Transactional
    public List<TriviaQuestionResponse> getTriviaQuestions(Long hobbyId) {
        ensureTriviaQuestionsSeeded();

        List<TriviaQuestion> allQuestions;
        if (hobbyId != null && hobbyId > 0) {
            allQuestions = triviaRepository.findByHobbyId(hobbyId);
            if (allQuestions.isEmpty()) {
                allQuestions = triviaRepository.findAll();
            }
        } else {
            allQuestions = triviaRepository.findAll();
        }

        List<TriviaQuestion> shuffled = new ArrayList<>(allQuestions);
        Collections.shuffle(shuffled);
        List<TriviaQuestion> selected = shuffled.stream().limit(5).collect(Collectors.toList());

        return selected.stream().map(q -> TriviaQuestionResponse.builder()
                .id(q.getId())
                .hobbyId(q.getHobby() != null ? q.getHobby().getId() : null)
                .hobbyName(q.getHobby() != null ? q.getHobby().getName() : "Genel Hobi")
                .hobbyIcon(q.getHobby() != null ? q.getHobby().getIcon() : "💡")
                .question(q.getQuestion())
                .options(List.of(q.getOptionA(), q.getOptionB(), q.getOptionC(), q.getOptionD()))
                .correctIndex(q.getCorrectIndex())
                .explanation(q.getExplanation())
                .difficulty(q.getDifficulty())
                .build()
        ).collect(Collectors.toList());
    }

    private DailyPuzzle seedOrFetchPuzzleForHobby(LocalDate date, Long hobbyId) {
        Hobby hobby = hobbyRepository.findById(hobbyId).orElse(null);
        if (hobby == null) return seedTodayPuzzle(date);

        String hobbyName = hobby.getName().toLowerCase();
        String answer;
        String clue;
        String title;

        if (hobbyName.contains("ceramics") || hobbyName.contains("seramik")) {
            answer = "EBESUAR";
            clue = "Kili tornada veya elde kesip şekillendirmekte kullanılan ahşap ya da metal uçlu modelaj aleti?";
            title = "Günün Seramik Terimi 🏺";
        } else if (hobbyName.contains("photo") || hobbyName.contains("foto")) {
            answer = "BOKEH";
            clue = "Geniş diyaframlı lenslerde odak dışı alanlarda oluşan yumuşak, estetik ışık bulanıklığı?";
            title = "Günün Fotoğrafçılık Terimi 📸";
        } else if (hobbyName.contains("run") || hobbyName.contains("koşu")) {
            answer = "KADANS";
            clue = "Koşucunun dakikada attığı adım frekansı; ritim ve koşu verimliliği göstergesi?";
            title = "Günün Koşu Terimi 🏃";
        } else if (hobbyName.contains("cook") || hobbyName.contains("mutfak")) {
            answer = "ALDENTE";
            clue = "İtalyan mutfağında makarnanın fazla yumuşamadan, dişe gelir dirilikte pişirilme kıvamı?";
            title = "Günün Mutfak Terimi 🍳";
        } else if (hobbyName.contains("hik") || hobbyName.contains("doğa")) {
            answer = "BATON";
            clue = "Trekking ve dağ yürüyüşlerinde dizlere binen yükü hafifleten teleskopik yürüyüş sopası?";
            title = "Günün Doğa Yürüyüşü Terimi 🌲";
        } else {
            answer = "CHAPS";
            clue = "Binicilikte bacağın alt kısmını ve pantolonu eyer sürtünmesinden koruyan koruyucu tozluk?";
            title = "Günün Binicilik Terimi 🐎";
        }

        String scrambled = generateScrambledLetters(answer);

        DailyPuzzle puzzle = DailyPuzzle.builder()
                .puzzleDate(date)
                .hobby(hobby)
                .title(title)
                .clue(clue)
                .answer(answer)
                .scrambledLetters(scrambled)
                .pointsReward(100)
                .build();

        return puzzleRepository.save(puzzle);
    }

    private DailyPuzzle seedTodayPuzzle(LocalDate date) {
        Hobby horseRiding = hobbyRepository.findByNameIgnoreCase("Horse Riding").orElse(null);
        String answer = "CHAPS";
        String scrambled = generateScrambledLetters(answer);

        DailyPuzzle puzzle = DailyPuzzle.builder()
                .puzzleDate(date)
                .hobby(horseRiding)
                .title("Günün Binicilik Terimi 🐎")
                .clue("Binicilikte bacağın alt kısmını ve pantolonu eyer sürtünmesinden koruyan koruyucu tozluk?")
                .answer(answer)
                .scrambledLetters(scrambled)
                .pointsReward(100)
                .build();

        return puzzleRepository.save(puzzle);
    }

    private String generateScrambledLetters(String answer) {
        List<Character> chars = new ArrayList<>();
        for (char c : answer.toCharArray()) {
            chars.add(c);
        }

        // Add 4-5 random distractor letters
        char[] alphabet = "ABCDEFGHKLMNOPRSTUVYZ".toCharArray();
        Random rnd = new Random();
        for (int i = 0; i < 4; i++) {
            chars.add(alphabet[rnd.nextInt(alphabet.length)]);
        }

        Collections.shuffle(chars);
        return chars.stream().map(String::valueOf).collect(Collectors.joining(","));
    }

    private void ensureTriviaQuestionsSeeded() {
        if (triviaRepository.count() > 0) return;

        log.info("Seeding initial rich trivia questions for hobby arcade...");
        Hobby ceramics = hobbyRepository.findByNameIgnoreCase("Ceramics").orElse(null);
        Hobby horse = hobbyRepository.findByNameIgnoreCase("Horse Riding").orElse(null);
        Hobby running = hobbyRepository.findByNameIgnoreCase("Running").orElse(null);
        Hobby photo = hobbyRepository.findByNameIgnoreCase("Photography").orElse(null);
        Hobby cooking = hobbyRepository.findByNameIgnoreCase("Cooking").orElse(null);
        Hobby hiking = hobbyRepository.findByNameIgnoreCase("Hiking").orElse(null);

        List<TriviaQuestion> questions = List.of(
                // Ceramics
                TriviaQuestion.builder()
                        .hobby(ceramics)
                        .question("Seramik tornasında kili merkeze sabitleme işlemine ne ad verilir?")
                        .optionA("Merkezleme (Centering)")
                        .optionB("Gerdan Kırma")
                        .optionC("Bisküvi Pişirimi")
                        .optionD("Perdah Çekme")
                        .correctIndex(0)
                        .explanation("Merkezleme, dönen tornanın tam merkezine kili oturtup titreşimsiz döndürmeyi sağlayan temel aşamadır.")
                        .difficulty("ORTA")
                        .build(),
                TriviaQuestion.builder()
                        .hobby(ceramics)
                        .question("Şekillendirilmiş kilin sırlanmadan önce yaklaşık 900-1000°C'de yapılan ilk pişirimine ne denir?")
                        .optionA("Raku Pişirimi")
                        .optionB("Bisküvi (İlk) Pişirimi")
                        .optionC("Lüstr Pişirimi")
                        .optionD("Sinterleme")
                        .correctIndex(1)
                        .explanation("Kili sağlamlaştırmak ve sır emilimini kolaylaştırmak için yapılan ilk fırınlamaya bisküvi pişirimi denir.")
                        .difficulty("KOLAY")
                        .build(),
                TriviaQuestion.builder()
                        .hobby(ceramics)
                        .question("İki ayrı kil parçasını birbirine yapıştırmak için çamur ve su ile hazırlanan macuna ne denir?")
                        .optionA("Angop")
                        .optionB("Balçık")
                        .optionC("Barbotin (Slip)")
                        .optionD("Porselen hamuru")
                        .correctIndex(2)
                        .explanation("Barbotin (slip), çamurun çamurla kaynamasını sağlayan seramik yapıştırıcısıdır.")
                        .difficulty("ORTA")
                        .build(),

                // Horse Riding
                TriviaQuestion.builder()
                        .hobby(horse)
                        .question("Binicilikte atın 4 zamanlı, en yavaş ve rahat yürüyüş temposu hangisidir?")
                        .optionA("Tırıs (Trot)")
                        .optionB("Dörtnal (Canter/Gallop)")
                        .optionC("Adeta (Walk)")
                        .optionD("Piaffe")
                        .correctIndex(2)
                        .explanation("Adeta (Walk), atın toynaklarının sırayla 4 ayrı zamanlı bastığı en sakin ve dengeli yürüyüştür.")
                        .difficulty("KOLAY")
                        .build(),
                TriviaQuestion.builder()
                        .hobby(horse)
                        .question("Atın ağzına takılan ve dizginlerle yönlendirmeyi sağlayan metal parçaya ne denir?")
                        .optionA("Gem (Bit)")
                        .optionB("Eyer")
                        .optionC("Kolon Kayışı")
                        .optionD("Üzengi")
                        .correctIndex(0)
                        .explanation("Gem (bit), atın ağzındaki dişsiz boşluğa yerleştirilerek dizgin emirlerini ileten parçadır.")
                        .difficulty("ORTA")
                        .build(),
                TriviaQuestion.builder()
                        .hobby(horse)
                        .question("Binicilikte ayaklarınızı yerleştirdiğiniz ve dengenizi sağlayan asılı halkalara ne denir?")
                        .optionA("Kavşak")
                        .optionB("Üzengi (Stirrup)")
                        .optionC("Chaps")
                        .optionD("Martingal")
                        .correctIndex(1)
                        .explanation("Üzengi (stirrup), eyere bağlı kayışlarla sallanan ve ayak tabanının üçte birinin basıldığı metal halkadır.")
                        .difficulty("KOLAY")
                        .build(),

                // Running
                TriviaQuestion.builder()
                        .hobby(running)
                        .question("Verimli bir koşu formunda ideal adım frekansı (kadans) yaklaşık kaç adım/dakika civarıdır?")
                        .optionA("120 - 130")
                        .optionB("140 - 150")
                        .optionC("170 - 180")
                        .optionD("210 - 220")
                        .correctIndex(2)
                        .explanation("Uzmanlara göre 170-180 kadans, dize ve eklemlere binen darbe kuvvetini minimize eden en ekonomik aralıktır.")
                        .difficulty("ZOR")
                        .build(),
                TriviaQuestion.builder()
                        .hobby(running)
                        .question("Standart bir tam maraton mesafesi tam olarak kaç kilometredir?")
                        .optionA("21.097 km")
                        .optionB("42.195 km")
                        .optionC("50.000 km")
                        .optionD("38.450 km")
                        .correctIndex(1)
                        .explanation("Olimpik standart maraton mesafesi tam 42.195 kilometredir (26 mil 385 yarda).")
                        .difficulty("KOLAY")
                        .build(),

                // Photography
                TriviaQuestion.builder()
                        .hobby(photo)
                        .question("Fotoğrafçılıkta 'Pozlama Üçgeni'ni oluşturan 3 temel parametre hangileridir?")
                        .optionA("Diyafram, Enstantane (Hız), ISO")
                        .optionB("Zoom, Odak, Flaş")
                        .optionC("Tripod, Megapiksel, HDR")
                        .optionD("Lens Çapı, Sensör Boyutu, Kontrast")
                        .correctIndex(0)
                        .explanation("Pozlama diyafram (ışık miktarı/alan derinliği), enstantane (ışık süresi) ve sensör hassasiyeti (ISO) ile dengelenir.")
                        .difficulty("KOLAY")
                        .build(),
                TriviaQuestion.builder()
                        .hobby(photo)
                        .question("Portre çekimlerinde arka planı bulanıklaştırıp modeli öne çıkarmak için diyafram nasıl ayarlanmalıdır?")
                        .optionA("f/16 veya f/22 gibi yüksek diyafram")
                        .optionB("f/1.4 veya f/2.8 gibi açık diyafram")
                        .optionC("ISO 6400 yapılmalı")
                        .optionD("Enstantane 1/4000 yapılmalı")
                        .correctIndex(1)
                        .explanation("f/1.4 gibi küçük f-stop sayıları diyaframı ardına kadar açar ve alan derinliğini sığlaştırarak arka planı flu yapar.")
                        .difficulty("ORTA")
                        .build(),

                // Cooking
                TriviaQuestion.builder()
                        .hobby(cooking)
                        .question("Et veya sebzelerin yüksek ısıda kızarması sonucu ortaya çıkan lezzetli karamelize kimyasal reaksiyonun adı nedir?")
                        .optionA("Fermantasyon")
                        .optionB("Emülsiyon")
                        .optionC("Maillard Reaksiyonu")
                        .optionD("Pastörizasyon")
                        .correctIndex(2)
                        .explanation("Maillard reaksiyonu, aminoasitler ve indirgen şekerler arasındaki 140°C üzeri ısıda oluşan lezzet patlamasıdır.")
                        .difficulty("ZOR")
                        .build(),
                TriviaQuestion.builder()
                        .hobby(cooking)
                        .question("Klasik Fransız mutfağında sebzelerin yaklaşık 2mm kalınlığında ince kibrit çöpü şeklinde doğranmasına ne denir?")
                        .optionA("Julienne (Jülyen)")
                        .optionB("Brunoise (Brunuaz)")
                        .optionC("Chiffonade (Şifone)")
                        .optionD("Mirepoix")
                        .correctIndex(0)
                        .explanation("Jülyen doğrama, sebzelerin ince uzun çubuklar şeklinde kesildiği en temel mutfak kesim tekniğidir.")
                        .difficulty("KOLAY")
                        .build(),

                // Hiking
                TriviaQuestion.builder()
                        .hobby(hiking)
                        .question("Doğa yürüyüşü ve dağcılıkta vücut sıcaklığını korumak için önerilen giyim katmanlama sırası nasıldır?")
                        .optionA("Dış (Pamuk) -> İç (Polar) -> Yağmurluk")
                        .optionB("İç (Termal İçlik) -> Orta (Yalıtım/Polar) -> Dış (Rüzgarlık/Gore-Tex)")
                        .optionC("Kot pantolon ve kalın yün kazak")
                        .optionD("İç (Yağmurluk) -> Dış (Termal)")
                        .correctIndex(1)
                        .explanation("3 katman prensibi: Nemi dışarı atan içlik, ısıyı tutan polar ve rüzgar/yağmura karşı koruyan dış kabuk.")
                        .difficulty("ORTA")
                        .build()
        );

        triviaRepository.saveAll(questions);
        log.info("Successfully seeded {} diverse trivia questions.", questions.size());
    }
}
