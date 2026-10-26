import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/models.dart';

class BuddyMatchScreen extends StatefulWidget {
  const BuddyMatchScreen({super.key});

  @override
  State<BuddyMatchScreen> createState() => _BuddyMatchScreenState();
}

class _BuddyMatchScreenState extends State<BuddyMatchScreen> {
  List<BuddyRequestModel> _requests = [];
  List<HobbyModel> _hobbies = [];
  bool _isLoading = true;

  int? _selectedHobbyId;
  String _selectedIntention = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchHobbies();
    _fetchBuddyRequests();
  }

  Future<void> _fetchHobbies() async {
    try {
      final response = await ApiClient().dio.get('/hobbies');
      final list = (response.data as List)
          .map((e) => HobbyModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() => _hobbies = list);
    } catch (_) {}
  }

  Future<void> _fetchBuddyRequests() async {
    setState(() => _isLoading = true);
    try {
      String url = '/buddy/requests';
      final params = <String>[];
      if (_selectedHobbyId != null) params.add('hobbyId=$_selectedHobbyId');
      if (_selectedIntention != 'ALL') params.add('intention=$_selectedIntention');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await ApiClient().dio.get(url);
      final list = (response.data as List)
          .map((e) => BuddyRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _requests = list;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCreateBuddyModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController(text: 'Kadıköy, İstanbul');
    final timeController = TextEditingController(text: 'Hafta Sonu Öğleden Sonra');
    int? selectedHobby = _hobbies.isNotEmpty ? _hobbies.first.id : 1;
    String selectedIntention = 'FRIENDSHIP';
    String selectedGenderPref = 'ANY';
    String myGender = 'KADIN';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hobi Partneri İlanı Ver 🤝',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Birlikte spor, atölye veya hobi sohbeti yapacak bir partner bul.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'İlan Başlığı *',
                    hintText: 'Örn: Tenis / Seramik / Koşu Arkadaşı Aranıyor',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedHobby,
                  decoration: const InputDecoration(
                    labelText: 'Hobi *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _hobbies.map((h) {
                    return DropdownMenuItem<int>(
                      value: h.id,
                      child: Text('${h.icon} ${h.name}'),
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => selectedHobby = val),
                ),
                const SizedBox(height: 12),
                const Text('Buluşma Amacı / Türü:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('🤝 Arkadaşlık'),
                      selected: selectedIntention == 'FRIENDSHIP',
                      onSelected: (_) => setModalState(() => selectedIntention = 'FRIENDSHIP'),
                    ),
                    ChoiceChip(
                      label: const Text('🎾 Spor Partneri'),
                      selected: selectedIntention == 'ACTIVITY',
                      onSelected: (_) => setModalState(() => selectedIntention = 'ACTIVITY'),
                    ),
                    ChoiceChip(
                      label: const Text('☕❤️ Hobi Flörtü'),
                      selected: selectedIntention == 'DATE',
                      onSelected: (_) => setModalState(() => selectedIntention = 'DATE'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Partner Tercihi (Cinsiyet):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('🌟 Fark Etmez'),
                      selected: selectedGenderPref == 'ANY',
                      onSelected: (_) => setModalState(() => selectedGenderPref = 'ANY'),
                    ),
                    ChoiceChip(
                      label: const Text('👩 Yalnızca Kadınlar'),
                      selected: selectedGenderPref == 'FEMALE_ONLY',
                      onSelected: (_) => setModalState(() => selectedGenderPref = 'FEMALE_ONLY'),
                    ),
                    ChoiceChip(
                      label: const Text('👨 Yalnızca Erkekler'),
                      selected: selectedGenderPref == 'MALE_ONLY',
                      onSelected: (_) => setModalState(() => selectedGenderPref = 'MALE_ONLY'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama & Notun *',
                    hintText: 'Neler yapmayı planlıyorsun, seviyen nedir?',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Bölge / Konum',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          labelText: 'Planlanan Vakit',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final nav = Navigator.of(ctx);

                      if (titleController.text.trim().isEmpty ||
                          descController.text.trim().isEmpty ||
                          selectedHobby == null) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Lütfen zorunlu alanları doldurun')),
                        );
                        return;
                      }

                      try {
                        await ApiClient().dio.post(
                          '/buddy/requests',
                          data: {
                            'hobbyId': selectedHobby,
                            'title': titleController.text.trim(),
                            'description': descController.text.trim(),
                            'intention': selectedIntention,
                            'genderPreference': selectedGenderPref,
                            'creatorGender': myGender,
                            'location': locationController.text.trim(),
                            'preferredTime': timeController.text.trim(),
                          },
                        );
                        nav.pop();
                        _fetchBuddyRequests();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Partner ilanınız başarıyla paylaşıldı! 🤝🎉'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('İlanı Paylaş', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConnectDialog(BuddyRequestModel request) {
    final messageController = TextEditingController(
      text: 'Merhaba, ben de bu hobiyle ilgileniyorum. Birlikte katılabiliriz! 😊',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(request.hobbyIcon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Bağlantı İsteği Gönder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.creatorFullName} (@${request.creatorUsername}) kullanıcısının "${request.title}" ilanına eşleşme isteği göndermek üzeresiniz.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mesajın',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);

              try {
                await ApiClient().dio.post(
                  '/buddy/requests/${request.id}/connect',
                  data: {'message': messageController.text.trim()},
                );
                nav.pop();
                _fetchBuddyRequests();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Bağlantı isteğiniz ilan sahibine iletildi! 🤝🎉'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hobi Partneri Bul 🤝')),
      body: RefreshIndicator(
        onRefresh: _fetchBuddyRequests,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade900, Colors.pink.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🤝', style: TextStyle(fontSize: 38)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tek Başına Hobi Yapma! 🌟',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'İster spor partneri, ister seramik atölyesi arkadaşı, ister ortak hobili bir kahve buluşması!',
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Intention Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('🌟 Tümü'),
                    selected: _selectedIntention == 'ALL',
                    onSelected: (_) {
                      setState(() => _selectedIntention = 'ALL');
                      _fetchBuddyRequests();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('🤝 Arkadaşlık'),
                    selected: _selectedIntention == 'FRIENDSHIP',
                    onSelected: (_) {
                      setState(() => _selectedIntention = 'FRIENDSHIP');
                      _fetchBuddyRequests();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('🎾 Spor Partneri'),
                    selected: _selectedIntention == 'ACTIVITY',
                    onSelected: (_) {
                      setState(() => _selectedIntention = 'ACTIVITY');
                      _fetchBuddyRequests();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('☕❤️ Hobi Flörtü'),
                    selected: _selectedIntention == 'DATE',
                    onSelected: (_) {
                      setState(() => _selectedIntention = 'DATE');
                      _fetchBuddyRequests();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_requests.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Text('👥', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text(
                      'Bu filtrede henüz partner ilanı yok.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'İlk partner ilanını sen ver ve ortak hobini paylaşacak biriyle tanış!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              ..._requests.map((req) => _buildBuddyCard(req)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBuddyModal,
        icon: const Icon(Icons.add),
        label: const Text('Partner İlanı Ver'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBuddyCard(BuddyRequestModel item) {
    Color intentionColor = Colors.blue;
    String intentionText = '🤝 Arkadaşlık';
    if (item.intention == 'ACTIVITY') {
      intentionColor = Colors.orange.shade800;
      intentionText = '🎾 Spor Partneri';
    } else if (item.intention == 'DATE') {
      intentionColor = Colors.pink.shade700;
      intentionText = '☕❤️ Hobi Flörtü';
    }

    String genderPrefText = '🌟 Herkese Açık';
    if (item.genderPreference == 'FEMALE_ONLY') {
      genderPrefText = '👩 Yalnızca Kadınlar';
    } else if (item.genderPreference == 'MALE_ONLY') {
      genderPrefText = '👨 Yalnızca Erkekler';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.purple.shade50,
                  child: Text(
                    item.creatorAvatar?.isNotEmpty == true
                        ? item.creatorAvatar!
                        : item.creatorFullName.isNotEmpty
                            ? item.creatorFullName[0].toUpperCase()
                            : 'U',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.creatorFullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.creatorGender,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '@${item.creatorUsername}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: intentionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    intentionText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: intentionColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(item.hobbyIcon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.35),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    genderPrefText,
                    style: TextStyle(fontSize: 11, color: Colors.purple.shade900, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    item.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  item.preferredTime,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Text(
                  '${item.matchCount} İlgilenen',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: item.hasApplied
                  ? ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('İstek Gönderildi'),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: intentionColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _showConnectDialog(item),
                      icon: const Icon(Icons.handshake_outlined, size: 16),
                      label: const Text('Bağlantı Kur / Mesaj İlet'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
