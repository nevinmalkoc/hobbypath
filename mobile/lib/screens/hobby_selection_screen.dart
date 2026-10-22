import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/models.dart';
import 'main_layout.dart';

class HobbySelectionScreen extends StatefulWidget {
  const HobbySelectionScreen({super.key});

  @override
  State<HobbySelectionScreen> createState() => _HobbySelectionScreenState();
}

class _HobbySelectionScreenState extends State<HobbySelectionScreen> {
  List<HobbyModel> _hobbies = [];
  final Map<int, String> _selectedHobbies = {}; // hobbyId -> skillLevel
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHobbies();
  }

  Future<void> _fetchHobbies() async {
    try {
      final response = await ApiClient().dio.get('/hobbies');
      final list = (response.data as List)
          .map((e) => HobbyModel.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _hobbies = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Hobiler yüklenemedi. Lütfen internetini kontrol et.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHobbies() async {
    if (_selectedHobbies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir hobi seçin!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      for (final entry in _selectedHobbies.entries) {
        await ApiClient().dio.post(
          '/users/hobbies',
          data: {
            'hobbyId': entry.key,
            'skillLevel': entry.value,
          },
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hobiler kaydedilirken bir hata oluştu.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlgi Alanlarını Seç'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainLayout()),
              );
            },
            child: const Text('Atla'),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Hangi hobilerle ilgileniyorsun ve seviyen ne?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _hobbies.length,
                          itemBuilder: (context, index) {
                            final hobby = _hobbies[index];
                            final isSelected = _selectedHobbies.containsKey(hobby.id);
                            final currentLevel = _selectedHobbies[hobby.id] ?? 'BEGINNER';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          hobby.icon,
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                hobby.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                hobby.category,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Checkbox(
                                          value: isSelected,
                                          activeColor: Theme.of(context).primaryColor,
                                          onChanged: (val) {
                                            setState(() {
                                              if (val == true) {
                                                _selectedHobbies[hobby.id] = 'BEGINNER';
                                              } else {
                                                _selectedHobbies.remove(hobby.id);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    if (isSelected) ...[
                                      const Divider(height: 20),
                                      const Text(
                                        'Seviyen:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _buildLevelChip(hobby.id, 'BEGINNER', 'Başlangıç', currentLevel),
                                          const SizedBox(width: 8),
                                          _buildLevelChip(hobby.id, 'INTERMEDIATE', 'Orta Seviye', currentLevel),
                                          const SizedBox(width: 8),
                                          _buildLevelChip(hobby.id, 'ADVANCED', 'İleri Seviye', currentLevel),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveHobbies,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _selectedHobbies.isEmpty
                                      ? 'Lütfen Hobi Seç'
                                      : '${_selectedHobbies.length} Hobiyle Başla',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLevelChip(int hobbyId, String levelCode, String label, String currentLevel) {
    final isSelected = currentLevel == levelCode;
    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11,
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: const Color(0xFFF1F5F9),
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedHobbies[hobbyId] = levelCode;
          });
        }
      },
    );
  }
}
