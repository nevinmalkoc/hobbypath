import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/models.dart';

class StarterGearScreen extends StatefulWidget {
  const StarterGearScreen({super.key});

  @override
  State<StarterGearScreen> createState() => _StarterGearScreenState();
}

class _StarterGearScreenState extends State<StarterGearScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<StarterGearModel> _starterGears = [];
  List<GearTransferModel> _transfers = [];
  List<HobbyModel> _hobbies = [];

  bool _isLoadingGears = true;
  bool _isLoadingTransfers = true;

  int? _selectedHobbyId;
  String _selectedTransferType = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchHobbies();
    _fetchStarterGears();
    _fetchTransfers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _fetchStarterGears() async {
    setState(() => _isLoadingGears = true);
    try {
      final url = _selectedHobbyId != null
          ? '/gear/guide?hobbyId=$_selectedHobbyId'
          : '/gear/guide';
      final response = await ApiClient().dio.get(url);
      final list = (response.data as List)
          .map((e) => StarterGearModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _starterGears = list;
        _isLoadingGears = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingGears = false);
    }
  }

  Future<void> _fetchTransfers() async {
    setState(() => _isLoadingTransfers = true);
    try {
      String url = '/gear/transfers';
      final params = <String>[];
      if (_selectedHobbyId != null) params.add('hobbyId=$_selectedHobbyId');
      if (_selectedTransferType != 'ALL') {
        params.add('type=$_selectedTransferType');
      }
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await ApiClient().dio.get(url);
      final list = (response.data as List)
          .map((e) => GearTransferModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _transfers = list;
        _isLoadingTransfers = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingTransfers = false);
    }
  }

  void _showCreateTransferModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final conditionController = TextEditingController(text: 'Az Kullanılmış / Çok Temiz');
    final locationController = TextEditingController(text: 'Kadıköy, İstanbul');
    final contactController = TextEditingController();
    int? selectedHobby = _hobbies.isNotEmpty ? _hobbies.first.id : 1;
    String transferType = 'GIFT';

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
                  'Ekipmanını Birine Devret ♻️',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kullanmadığın ekipmanı yeni başlayan bir öğrenci arkadaşına ulaştır.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'İlan Başlığı *',
                    hintText: 'Örn: 38 Numara Temiz Chaps & Binicilik Botu',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedHobby,
                  decoration: const InputDecoration(
                    labelText: 'İlgili Hobi *',
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
                const Text('Paylaşım Türü:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('🎁 Ücretsiz Hediye'),
                      selected: transferType == 'GIFT',
                      onSelected: (_) => setModalState(() => transferType = 'GIFT'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('🔄 Sembolik'),
                      selected: transferType == 'SYMBOLIC',
                      onSelected: (_) => setModalState(() => transferType = 'SYMBOLIC'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('⏳ Ödünç'),
                      selected: transferType == 'BORROW',
                      onSelected: (_) => setModalState(() => transferType = 'BORROW'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama *',
                    hintText: 'Ürünün durumu, neden devrettiğin ve kimlere uygun olduğu...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: conditionController,
                        decoration: const InputDecoration(
                          labelText: 'Kullanım Durumu',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Teslim Konumu',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'İletişim Bilgisi (DM / WhatsApp / Instagram)',
                    hintText: 'Örn: @kullaniciadi veya Uygulama İçi DM',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);

                      if (titleController.text.trim().isEmpty ||
                          descController.text.trim().isEmpty ||
                          selectedHobby == null) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text('Lütfen zorunlu alanları doldurun')),
                        );
                        return;
                      }

                      try {
                        await ApiClient().dio.post(
                          '/gear/transfers',
                          data: {
                            'hobbyId': selectedHobby,
                            'title': titleController.text.trim(),
                            'description': descController.text.trim(),
                            'transferType': transferType,
                            'itemCondition': conditionController.text.trim(),
                            'location': locationController.text.trim(),
                            'contactInfo': contactController.text.trim().isNotEmpty
                                ? contactController.text.trim()
                                : 'Uygulama İçi Mesaj',
                          },
                        );
                        navigator.pop();
                        _fetchTransfers();
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Ekipman devir ilanın başarıyla paylaşıldı! 🤝🎉'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('İlanı Yayınla & Paylaş', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(GearTransferModel transfer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(transfer.hobbyIcon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                transfer.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    transfer.ownerAvatar?.isNotEmpty == true
                        ? transfer.ownerAvatar!
                        : transfer.ownerFullName.isNotEmpty
                            ? transfer.ownerFullName[0].toUpperCase()
                            : 'U',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transfer.ownerFullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '@${transfer.ownerUsername}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'İletişim & Teslimat Bilgisi: 📍',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📍 Konum: ${transfer.location}', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('💬 İletişim: ${transfer.contactInfo}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Açıklama: "${transfer.description}"',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${transfer.ownerFullName} kullanıcısına mesaj isteği iletildi! 💬'),
                  backgroundColor: Colors.blue.shade700,
                ),
              );
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Mesaj Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acemi Çantası & Ekipman'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade800,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade700,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.backpack_outlined), text: 'Minimum Rehber'),
            Tab(icon: Icon(Icons.handshake_outlined), text: 'Elden Ele Devir'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStarterGuideTab(),
          _buildTransfersTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _showCreateTransferModal,
              icon: const Icon(Icons.add),
              label: const Text('Ekipman Devret'),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildHobbyFilterBar(VoidCallback onRefresh) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Tüm Hobiler 🌟'),
              selected: _selectedHobbyId == null,
              onSelected: (_) {
                setState(() => _selectedHobbyId = null);
                onRefresh();
              },
            ),
          ),
          ..._hobbies.map((h) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('${h.icon} ${h.name}'),
                  selected: _selectedHobbyId == h.id,
                  onSelected: (_) {
                    setState(() => _selectedHobbyId = h.id);
                    onRefresh();
                  },
                ),
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: MINIMUM STARTER GEAR GUIDE
  // ---------------------------------------------------------------------------
  Widget _buildStarterGuideTab() {
    final mandatoryGears = _starterGears.where((g) => g.mandatory).toList();
    final optionalGears = _starterGears.where((g) => !g.mandatory).toList();

    return RefreshIndicator(
      onRefresh: _fetchStarterGears,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.indigo.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🎒', style: TextStyle(fontSize: 38)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Gereksiz Masraf Yapma! 💡',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Yeni başladığın bir hobide ilk günden binlerce lira harcamana gerek yok. Gerçekten olmazsa olmazları öğren!',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hobby Filter Bar
          _buildHobbyFilterBar(_fetchStarterGears),
          const SizedBox(height: 16),

          if (_isLoadingGears)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else ...[
            // Mandatory Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    '🚨 Olmazsa Olmaz Temel Ekipmanlar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${mandatoryGears.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (mandatoryGears.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Bu filtrede ekipman bulunamadı.', style: TextStyle(color: Colors.grey.shade600)),
              )
            else
              ...mandatoryGears.map((gear) => _buildGearCard(gear, isMandatory: true)),

            const SizedBox(height: 24),

            // Optional Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    '💡 İleride Alınabilecekler (Lüks / Opsiyonel)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${optionalGears.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (optionalGears.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Bu filtrede opsiyonel ekipman bulunamadı.', style: TextStyle(color: Colors.grey.shade600)),
              )
            else
              ...optionalGears.map((gear) => _buildGearCard(gear, isMandatory: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildGearCard(StarterGearModel gear, {required bool isMandatory}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMandatory ? Colors.red.shade100 : Colors.amber.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(gear.icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gear.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        gear.hobbyName,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMandatory ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    gear.estimatedBudget,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isMandatory ? Colors.green.shade800 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isMandatory ? Icons.verified_outlined : Icons.lightbulb_outline,
                    size: 16,
                    color: isMandatory ? Colors.blue.shade700 : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gear.advice,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: ELDEN ELE DEVİR (PAY-IT-FORWARD)
  // ---------------------------------------------------------------------------
  Widget _buildTransfersTab() {
    return RefreshIndicator(
      onRefresh: _fetchTransfers,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
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
                        'Elden Ele Devret (Pay-It-Forward) ♻️',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kullanmadığın ekipmanı yeni başlayan birine devret, hobi topluluğunu dayanışmayla büyüt!',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hobby Filter Bar
          _buildHobbyFilterBar(_fetchTransfers),
          const SizedBox(height: 10),

          // Type Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tümü'),
                  selected: _selectedTransferType == 'ALL',
                  onSelected: (_) {
                    setState(() => _selectedTransferType = 'ALL');
                    _fetchTransfers();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('🎁 Hediye'),
                  selected: _selectedTransferType == 'GIFT',
                  onSelected: (_) {
                    setState(() => _selectedTransferType = 'GIFT');
                    _fetchTransfers();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('🔄 Sembolik'),
                  selected: _selectedTransferType == 'SYMBOLIC',
                  onSelected: (_) {
                    setState(() => _selectedTransferType = 'SYMBOLIC');
                    _fetchTransfers();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('⏳ Ödünç'),
                  selected: _selectedTransferType == 'BORROW',
                  onSelected: (_) {
                    setState(() => _selectedTransferType = 'BORROW');
                    _fetchTransfers();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoadingTransfers)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (_transfers.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text(
                    'Henüz bu kategoride devredilen ekipman yok.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'İlk paylaşan sen ol! Boşta duran malzemeni yeni başlayan birine devret.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ..._transfers.map((item) => _buildTransferCard(item)),
          const SizedBox(height: 80), // Fab spacing
        ],
      ),
    );
  }

  Widget _buildTransferCard(GearTransferModel item) {
    Color badgeColor = Colors.green;
    String badgeText = '🎁 Ücretsiz Hediye';
    if (item.transferType == 'SYMBOLIC') {
      badgeColor = Colors.purple;
      badgeText = '🔄 Sembolik Devir';
    } else if (item.transferType == 'BORROW') {
      badgeColor = Colors.orange.shade800;
      badgeText = '⏳ Ödünç Verme';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    item.ownerAvatar?.isNotEmpty == true
                        ? item.ownerAvatar!
                        : item.ownerFullName.isNotEmpty
                            ? item.ownerFullName[0].toUpperCase()
                            : 'U',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.ownerFullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '@${item.ownerUsername}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Durum: ${item.itemCondition}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
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
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showContactDialog(item),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Sahibiyle İletişime Geç'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
