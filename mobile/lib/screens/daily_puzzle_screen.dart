import 'dart:async';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/models.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🎮 Hobi Oyun Salonu'),
            SizedBox(width: 8),
            Text(
              'Arcade',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: const [
            Tab(icon: Icon(Icons.extension_outlined), text: 'Kelime Avı'),
            Tab(icon: Icon(Icons.bolt_outlined), text: '5 Soru Trivia'),
            Tab(icon: Icon(Icons.style_outlined), text: 'Hafıza Kartı'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WordPuzzleGameView(),
          _TriviaGameView(),
          _MemoryMatchGameView(),
        ],
      ),
    );
  }
}

// ==========================================
// GAME 1: KELİME AVI (WORDLE / ANAGRAM)
// ==========================================
class _WordPuzzleGameView extends StatefulWidget {
  const _WordPuzzleGameView();

  @override
  State<_WordPuzzleGameView> createState() => _WordPuzzleGameViewState();
}

class _WordPuzzleGameViewState extends State<_WordPuzzleGameView> {
  DailyPuzzleModel? _puzzle;
  List<LeaderboardEntryModel> _leaderboard = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  int _selectedHobbyId = 1; // 1: Horse Riding, 2: Ceramics, 3: Photography, 5: Running
  final List<Map<String, dynamic>> _hobbyOptions = [
    {'id': 1, 'name': 'Binicilik', 'icon': '🐎'},
    {'id': 2, 'name': 'Seramik', 'icon': '🏺'},
    {'id': 3, 'name': 'Fotoğraf', 'icon': '📸'},
    {'id': 5, 'name': 'Koşu', 'icon': '🏃'},
  ];

  int _timerSeconds = 0;
  Timer? _timer;

  List<String> _availableLetters = [];
  final List<String> _selectedLetters = [];

  @override
  void initState() {
    super.initState();
    _fetchTodayPuzzle();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTodayPuzzle() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().dio.get('/puzzles/today', queryParameters: {
        'hobbyId': _selectedHobbyId,
      });
      final puzzle = DailyPuzzleModel.fromJson(response.data as Map<String, dynamic>);

      if (mounted) {
        setState(() {
          _puzzle = puzzle;
          _isLoading = false;
          _selectedLetters.clear();
          _availableLetters = puzzle.scrambledLetters.split(',').map((s) => s.trim()).toList();
        });

        if (puzzle.alreadySolved) {
          _fetchLeaderboard(puzzle.id);
        } else {
          _startTimer();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => _timerSeconds++);
      }
    });
  }

  Future<void> _fetchLeaderboard(int puzzleId) async {
    try {
      final response = await ApiClient().dio.get('/puzzles/$puzzleId/leaderboard');
      final list = (response.data as List)
          .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _leaderboard = list;
        });
      }
    } catch (_) {}
  }

  void _selectLetter(int index) {
    if (_puzzle == null || _puzzle!.alreadySolved) return;
    if (_selectedLetters.length >= _puzzle!.answerLength) return;

    setState(() {
      final letter = _availableLetters.removeAt(index);
      _selectedLetters.add(letter);
    });
  }

  void _unselectLetter(int index) {
    if (_puzzle == null || _puzzle!.alreadySolved) return;
    if (index >= _selectedLetters.length) return;

    setState(() {
      final letter = _selectedLetters.removeAt(index);
      _availableLetters.add(letter);
    });
  }

  void _clearSelection() {
    if (_puzzle == null || _puzzle!.alreadySolved) return;
    setState(() {
      _availableLetters.addAll(_selectedLetters);
      _selectedLetters.clear();
    });
  }

  Future<void> _submitAnswer() async {
    if (_puzzle == null) return;
    final submittedWord = _selectedLetters.join();

    if (submittedWord.length != _puzzle!.answerLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen ${_puzzle!.answerLength} harfi de tamamlayın!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiClient().dio.post(
        '/puzzles/${_puzzle!.id}/solve',
        data: {
          'answer': submittedWord,
          'completionTimeSeconds': _timerSeconds,
        },
      );

      _timer?.cancel();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('🎉'),
              SizedBox(width: 8),
              Text('Tebrikler!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelime: $submittedWord',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              Text('Çözüm süren: $_timerSeconds saniye! ⚡'),
              const SizedBox(height: 8),
              const Text('Profiline +100 Hobi Puanı eklendi!'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _fetchTodayPuzzle();
              },
              child: const Text('Liderlik Tablosunu Gör'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Hatalı cevap! Harfleri ve ipucunu tekrar gözden geçir.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_puzzle == null) {
      return const Center(child: Text('Bugün için bulmaca bulunamadı.'));
    }

    final p = _puzzle!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hobby Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _hobbyOptions.map((opt) {
                final isSelected = _selectedHobbyId == opt['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Text(opt['icon'] as String, style: const TextStyle(fontSize: 16)),
                    label: Text(opt['name'] as String),
                    selected: isSelected,
                    selectedColor: Colors.deepOrange.shade100,
                    onSelected: (val) {
                      if (val && _selectedHobbyId != opt['id']) {
                        setState(() {
                          _selectedHobbyId = opt['id'] as int;
                        });
                        _fetchTodayPuzzle();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Header Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(p.hobbyIcon, style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 8),
                          Text(
                            p.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              p.alreadySolved
                                  ? '${p.myCompletionTimeSeconds ?? 0}s'
                                  : '$_timerSeconds s',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    p.clue,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Answer Slots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(p.answerLength, (index) {
              final hasLetter = index < _selectedLetters.length;
              final letter = hasLetter ? _selectedLetters[index] : '';

              return InkWell(
                onTap: hasLetter ? () => _unselectLetter(index) : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: hasLetter ? Colors.deepOrange.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasLetter ? Colors.deepOrange : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Scrambled Letters Keyboard
          if (!p.alreadySolved) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_availableLetters.length, (i) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _selectLetter(i),
                  child: Text(
                    _availableLetters[i],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedLetters.isNotEmpty ? _clearSelection : null,
                    icon: const Icon(Icons.backspace_outlined, size: 18),
                    label: const Text('Temizle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isSubmitting || _selectedLetters.length != p.answerLength
                        ? null
                        : _submitAnswer,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(_isSubmitting ? 'Kontrol...' : 'Cevabı Gönder'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bu hobi bulmacasını başarıyla çözdün! 🏅',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        Text(
                          'Süren: ${p.myCompletionTimeSeconds ?? 0} saniye',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Leaderboard
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 22),
              SizedBox(width: 8),
              Text(
                'Günün En Hızlıları 🏆',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_leaderboard.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  p.alreadySolved
                      ? 'İlk çözen sen oldun! 🚀'
                      : 'Henüz çözen olmadı. İlk sen ol ve zirveye otur!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ..._leaderboard.map((entry) {
              final isMe = p.alreadySolved && entry.completionTimeSeconds == p.myCompletionTimeSeconds;
              return Card(
                color: isMe ? Colors.amber.shade50 : null,
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: entry.rank == 1
                        ? Colors.amber
                        : (entry.rank == 2 ? Colors.grey.shade400 : Colors.brown.shade300),
                    child: Text(
                      '#${entry.rank}',
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    entry.fullName.isNotEmpty ? entry.fullName : entry.username,
                    style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.w600),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${entry.completionTimeSeconds}s ⚡',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ==========================================
// GAME 2: 5 SORULUK HIZLI TRIVIA
// ==========================================
class _TriviaGameView extends StatefulWidget {
  const _TriviaGameView();

  @override
  State<_TriviaGameView> createState() => _TriviaGameViewState();
}

class _TriviaGameViewState extends State<_TriviaGameView> {
  List<TriviaQuestionModel> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _score = 0;
  int _timerSeconds = 15;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchTriviaQuestions();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTriviaQuestions() async {
    setState(() {
      _isLoading = true;
      _currentIndex = 0;
      _score = 0;
      _selectedOptionIndex = null;
      _answered = false;
    });

    try {
      final response = await ApiClient().dio.get('/puzzles/trivia');
      final list = (response.data as List)
          .map((e) => TriviaQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _questions = list;
          _isLoading = false;
        });
        _startQuestionTimer();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startQuestionTimer() {
    _countdownTimer?.cancel();
    _timerSeconds = 15;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timerSeconds <= 1) {
        t.cancel();
        if (!_answered) {
          _selectAnswer(-1); // Time out
        }
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  void _selectAnswer(int optionIndex) {
    if (_answered) return;
    _countdownTimer?.cancel();

    final currentQ = _questions[_currentIndex];
    final isCorrect = optionIndex == currentQ.correctIndex;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _answered = true;
      if (isCorrect) {
        _score += 100 + (_timerSeconds * 5); // Speed bonus
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _answered = false;
      });
      _startQuestionTimer();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🏆'),
            SizedBox(width: 8),
            Text('Trivia Tamamlandı!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Toplam Skorun: $_score Puan',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            const SizedBox(height: 12),
            const Text(
              'Farklı hobilerden genel kültür sorularını başarıyla yanıtladın. Harika bir hobi meraklısısın!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _fetchTriviaQuestions();
            },
            child: const Text('Yeni Sorularla Tekrar Oyna'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Soru yüklenemedi.'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _fetchTriviaQuestions, child: const Text('Tekrar Dene')),
          ],
        ),
      );
    }

    final q = _questions[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Info Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Soru ${_currentIndex + 1} / ${_questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$_score Puan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _timerSeconds <= 5 ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: _timerSeconds <= 5 ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_timerSeconds}s',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _timerSeconds <= 5 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(q.hobbyIcon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        q.hobbyName,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          q.difficulty,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    q.question,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Options
          ...List.generate(q.options.length, (idx) {
            Color? bgColor;
            Color borderColor = Colors.grey.shade300;
            Color textColor = Colors.black87;

            if (_answered) {
              if (idx == q.correctIndex) {
                bgColor = Colors.green.shade50;
                borderColor = Colors.green;
                textColor = Colors.green.shade900;
              } else if (idx == _selectedOptionIndex) {
                bgColor = Colors.red.shade50;
                borderColor = Colors.red;
                textColor = Colors.red.shade900;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: _answered ? null : () => _selectAnswer(idx),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor ?? Colors.white,
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: borderColor.withValues(alpha: 0.2),
                        child: Text(
                          String.fromCharCode(65 + idx),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.options[idx],
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                        ),
                      ),
                      if (_answered && idx == q.correctIndex)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      if (_answered && idx == _selectedOptionIndex && idx != q.correctIndex)
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Explanation Box & Next Button
          if (_answered) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      q.explanation ?? 'Doğru cevap açıklandı.',
                      style: TextStyle(fontSize: 13, color: Colors.brown.shade800, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _nextQuestion,
              child: Text(
                _currentIndex + 1 < _questions.length ? 'Sonraki Soruya Geç ➔' : 'Sonuçları Gör 🏆',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// GAME 3: HAFIZA KARTLARI (MEMORY MATCH)
// ==========================================
class _MemoryCard {
  final int id;
  final String icon;
  final String name;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.id,
    required this.icon,
    required this.name,
  })  : isFlipped = false,
        isMatched = false;
}

class _MemoryMatchGameView extends StatefulWidget {
  const _MemoryMatchGameView();

  @override
  State<_MemoryMatchGameView> createState() => _MemoryMatchGameViewState();
}

class _MemoryMatchGameViewState extends State<_MemoryMatchGameView> {
  List<_MemoryCard> _cards = [];
  _MemoryCard? _firstSelected;
  bool _isBusy = false;
  int _moves = 0;
  int _matchedPairs = 0;
  int _timerSeconds = 0;
  Timer? _timer;

  final List<Map<String, String>> _pairs = [
    {'icon': '🐎', 'name': 'Chaps'},
    {'icon': '🏺', 'name': 'Ebesuar'},
    {'icon': '📸', 'name': 'Bokeh Lens'},
    {'icon': '🏃', 'name': 'Kadans'},
    {'icon': '🍳', 'name': 'Al Dente'},
    {'icon': '🌲', 'name': 'Baton'},
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _timer?.cancel();
    _timerSeconds = 0;
    _moves = 0;
    _matchedPairs = 0;
    _firstSelected = null;
    _isBusy = false;

    List<_MemoryCard> list = [];
    int idCounter = 1;

    for (var p in _pairs) {
      list.add(_MemoryCard(id: idCounter++, icon: p['icon']!, name: p['name']!));
      list.add(_MemoryCard(id: idCounter++, icon: p['icon']!, name: p['name']!));
    }

    list.shuffle();

    setState(() {
      _cards = list;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => _timerSeconds++);
      }
    });
  }

  void _onCardTap(_MemoryCard card) {
    if (_isBusy || card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
    } else {
      _moves++;
      final first = _firstSelected!;
      _firstSelected = null;

      if (first.name == card.name) {
        // Match!
        setState(() {
          first.isMatched = true;
          card.isMatched = true;
          _matchedPairs++;
        });

        if (_matchedPairs == _pairs.length) {
          _timer?.cancel();
          _showWinDialog();
        }
      } else {
        // Not a match, flip back after 800ms
        _isBusy = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              first.isFlipped = false;
              card.isFlipped = false;
              _isBusy = false;
            });
          }
        });
      }
    }
  }

  void _showWinDialog() {
    final stars = _moves <= 10 ? '⭐⭐⭐' : (_moves <= 14 ? '⭐⭐' : '⭐');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🃏'),
            SizedBox(width: 8),
            Text('Harika Eşleştirme!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(stars, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text('Tüm hobi kartlarını $_moves hamlede ve $_timerSeconds saniyede buldun! 🎉'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startNewGame();
            },
            child: const Text('Yeniden Karıştır & Oyna'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stat Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('Hamle: $_moves', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$_timerSeconds s', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Yeniden Başlat',
                onPressed: _startNewGame,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4x3 Grid Cards
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _cards.length,
              itemBuilder: (ctx, i) {
                final card = _cards[i];
                final isOpen = card.isFlipped || card.isMatched;

                return GestureDetector(
                  onTap: () => _onCardTap(card),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isOpen
                          ? (card.isMatched ? Colors.green.shade50 : Colors.white)
                          : Colors.deepOrange,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: card.isMatched
                            ? Colors.green
                            : (isOpen ? Colors.deepOrange.shade300 : Colors.deepOrange),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: isOpen
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(card.icon, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 4),
                              Text(
                                card.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: card.isMatched ? Colors.green.shade900 : Colors.black87,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            '❓',
                            style: TextStyle(fontSize: 26, color: Colors.white),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
