import 'dart:async';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/models.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  DailyPuzzleModel? _puzzle;
  List<LeaderboardEntryModel> _leaderboard = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

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
    try {
      final response = await ApiClient().dio.get('/puzzles/today');
      final puzzle = DailyPuzzleModel.fromJson(response.data as Map<String, dynamic>);

      setState(() {
        _puzzle = puzzle;
        _isLoading = false;
        _availableLetters = puzzle.scrambledLetters.split(',').map((s) => s.trim()).toList();
      });

      if (puzzle.alreadySolved) {
        _fetchLeaderboard(puzzle.id);
      } else {
        _startTimer();
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

  Future<void> _submitAnswer() async {
    if (_puzzle == null || _isSubmitting) return;

    final answer = _selectedLetters.join();
    if (answer.length != _puzzle!.answerLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen ${_puzzle!.answerLength} harfi de tamamlayın.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiClient().dio.post(
        '/puzzles/${_puzzle!.id}/solve',
        data: {
          'answer': answer,
          'completionTimeSeconds': _timerSeconds,
        },
      );

      _timer?.cancel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text('🎉 Tebrikler! Bulmacayı $_timerSeconds saniyede çözdünüz!'),
          ),
        );
        _fetchTodayPuzzle();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Cevap doğru değil! İpucuna tekrar bakın.'),
          ),
        );
      }
    }
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günün Hobi Bulmacası 🧩'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _puzzle == null
              ? const Center(child: Text('Bugünün bulmacası bulunamadı.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Başlık & İpucu Kartı
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_puzzle!.hobbyIcon, style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    _puzzle!.title,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _puzzle!.clue,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Colors.blue.shade900),
                            ),
                            const SizedBox(height: 16),
                            // Canlı Sayaç veya Tamamlandı Rozeti
                            if (_puzzle!.alreadySolved)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tamamlandı · ${_puzzle!.myCompletionTimeSeconds ?? 0} saniye',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_outlined, color: Colors.deepOrange, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTimer(_timerSeconds),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Harf Yuvaları (Seçilen Harfler)
                    if (!_puzzle!.alreadySolved) ...[
                      const Text(
                        'Cevabını Oluştur:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_puzzle!.answerLength, (index) {
                          final hasLetter = index < _selectedLetters.length;
                          return GestureDetector(
                            onTap: hasLetter ? () => _unselectLetter(index) : null,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 48,
                              height: 52,
                              decoration: BoxDecoration(
                                color: hasLetter ? Theme.of(context).primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: hasLetter ? Theme.of(context).primaryColor : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                hasLetter ? _selectedLetters[index] : '',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // Kullanılabilir Harfler
                      const Text(
                        'Harflere Dokun:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_availableLetters.length, (index) {
                          return ActionChip(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            label: Text(
                              _availableLetters[index],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _selectLetter(index),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _submitAnswer,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check),
                        label: const Text('Cevabı Gönder'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],

                    // Liderlik Tablosu
                    if (_puzzle!.alreadySolved) ...[
                      const SizedBox(height: 10),
                      const Text(
                        '🏆 Günün Liderlik Tablosu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (_leaderboard.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('Henüz başka çözen olmadı. İlk sen oldun! 🚀')),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _leaderboard.length,
                          separatorBuilder: (_, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final entry = _leaderboard[index];
                            final medal = index == 0
                                ? '🥇'
                                : index == 1
                                    ? '🥈'
                                    : index == 2
                                        ? '🥉'
                                        : '${entry.rank}.';

                            return ListTile(
                              leading: Text(medal, style: const TextStyle(fontSize: 22)),
                              title: Text(
                                entry.fullName.isNotEmpty ? entry.fullName : entry.username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${entry.completionTimeSeconds} sn',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ],
                ),
    );
  }
}
