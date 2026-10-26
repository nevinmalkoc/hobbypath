import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/models.dart';
import 'community_detail_screen.dart';
import 'daily_puzzle_screen.dart';
import 'login_screen.dart';
import 'starter_gear_screen.dart';
import 'buddy_match_screen.dart';
import 'ai_assistant_screen.dart';
import '../widgets/interactive_event_map.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const FeedTab(),
      const CommunitiesTab(),
      const EventsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Akış',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Topluluklar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Etkinlikler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 0: FEED TAB
// ---------------------------------------------------------------------------
class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  List<PostModel> _posts = [];
  List<EventModel> _events = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await ApiClient().dio.get('/notifications/unread-count');
      if (mounted) {
        setState(() {
          _unreadCount = (response.data['unreadCount'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchFeed() async {
    try {
      final response = await ApiClient().dio.get('/feed');
      final postsData = (response.data['communityPosts'] as List? ?? [])
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final eventsData = (response.data['upcomingEvents'] as List? ?? [])
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _posts = postsData;
        _events = eventsData;
        _isLoading = false;
      });
      _fetchUnreadCount();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNotificationsSheet() async {
    List<NotificationModel> notifications = [];
    bool loadingNotifs = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            if (loadingNotifs) {
              ApiClient().dio.get('/notifications').then((res) {
                final list = (res.data as List)
                    .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
                    .toList();
                if (ctx.mounted) {
                  setSheetState(() {
                    notifications = list;
                    loadingNotifs = false;
                  });
                }
              }).catchError((_) {
                if (ctx.mounted) {
                  setSheetState(() => loadingNotifs = false);
                }
              });
            }

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bildirimler 🔔',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            try {
                              await ApiClient().dio.patch('/notifications/read-all');
                              setState(() => _unreadCount = 0);
                              if (ctx.mounted) {
                                setSheetState(() {
                                  notifications = notifications
                                      .map((n) => NotificationModel(
                                            id: n.id,
                                            title: n.title,
                                            message: n.message,
                                            type: n.type,
                                            referenceId: n.referenceId,
                                            read: true,
                                            createdAt: n.createdAt,
                                          ))
                                      .toList();
                                });
                              }
                            } catch (_) {}
                          },
                          child: const Text('Tümünü Okundu Say'),
                        ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: loadingNotifs
                        ? const Center(child: CircularProgressIndicator())
                        : notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none_outlined,
                                        size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Henüz yeni bir bildiriminiz yok.',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: notifications.length,
                                separatorBuilder: (_, index) => const SizedBox(height: 8),
                                itemBuilder: (c, i) {
                                  final notif = notifications[i];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: notif.read
                                          ? Colors.grey.shade50
                                          : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: notif.read
                                            ? Colors.grey.shade200
                                            : Colors.orange.shade200,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: notif.read
                                            ? Colors.grey.shade200
                                            : Colors.orange.shade100,
                                        child: Text(
                                          notif.type == 'EVENT_PROMOTED'
                                              ? '🎉'
                                              : notif.type == 'COMMUNITY_POST'
                                                  ? '💬'
                                                  : '📢',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      title: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontWeight: notif.read
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        notif.message,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🧭', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('HobbyPath', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'HobbyPath AI Koçu',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
              );
            },
            icon: const Icon(Icons.smart_toy_outlined, color: Colors.deepOrange),
          ),
          IconButton(
            tooltip: 'Hobi Partneri Bul',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuddyMatchScreen()),
              );
            },
            icon: const Icon(Icons.people_outline),
          ),
          IconButton(
            tooltip: 'Acemi Çantası & Devir',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StarterGearScreen()),
              );
            },
            icon: const Icon(Icons.backpack_outlined),
          ),
          IconButton(
            tooltip: 'Bildirimler',
            onPressed: _showNotificationsSheet,
            icon: Badge(
              isLabelVisible: _unreadCount > 0,
              label: Text('$_unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchFeed,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Hobi Oyun Salonu (Arcade - 3 Oyun)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DailyPuzzleScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple.shade700, Colors.purple.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🎮', style: TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'HOBİ ARCADE',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        '3 Yeni Oyun 🔥',
                                        style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Hobi Oyun Salonu',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const Text(
                                    'Kelime Avı · 5 Soru Trivia · Hafıza Kartı',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // HobbyPath AI Koçu Banner'ı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.indigo.shade800, Colors.blue.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🤖', style: TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.cyanAccent.shade400,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'YAPAY ZEKA DESTEĞİ',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'HobbyPath AI Hobi Koçu',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const Text(
                                    'Yeni hobiler, antrenman planları & tüyolar sor! ✨',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Acemi Çantası & Devir Banner'ı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StarterGearScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade800, Colors.teal.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🎒', style: TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade300,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'ÖĞRENCİ & BAŞLANGIÇ REHBERİ',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Acemi Çantası & Devir',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const Text(
                                    'Gerekli ekipmanlar & elden ele dayanışma 🤝',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hobi Partneri Bul Banner'ı (Arkadaşlık / Spor / Flört)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BuddyMatchScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade900, Colors.pink.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🤝', style: TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      '1\'E 1 EŞLEŞME & FLÖRT & SPOR',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Hobi Partneri Bul',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const Text(
                                    'Atölye arkadaşı, tenis partneri ya da kahve! ☕❤️',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Yaklaşan Etkinlikler Başlığı
                  if (_events.isNotEmpty) ...[
                    const Text(
                      'Yaklaşan Etkinlikler 📅',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 175,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(event.hobbyIcon, style: const TextStyle(fontSize: 22)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            event.communityName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      event.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            event.location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${event.currentParticipants}/${event.capacity}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Topluluk Paylaşımları
                  const Text(
                    'Topluluk Paylaşımları 💬',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_posts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Text(
                        'Henüz akışta paylaşım yok. Topluluklara katılıp sorular sorabilirsin!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    ..._posts.map((post) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        post.authorFullName.isNotEmpty
                                            ? post.authorFullName[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.authorFullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          post.communityName,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  post.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 1: COMMUNITIES TAB
// ---------------------------------------------------------------------------
class CommunitiesTab extends StatefulWidget {
  const CommunitiesTab({super.key});

  @override
  State<CommunitiesTab> createState() => _CommunitiesTabState();
}

class _CommunitiesTabState extends State<CommunitiesTab> {
  List<CommunityModel> _communities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  Future<void> _fetchCommunities() async {
    try {
      final response = await ApiClient().dio.get('/communities');
      final list = (response.data as List)
          .map((e) => CommunityModel.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _communities = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Topluluklar')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCommunities,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _communities.length,
                itemBuilder: (context, index) {
                  final community = _communities[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: Text(
                        community.hobbyIcon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        community.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            community.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${community.memberCount} Üye',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              if (community.isMember) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Üyesin',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunityDetailScreen(community: community),
                          ),
                        ).then((_) => _fetchCommunities());
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 2: EVENTS TAB
// ---------------------------------------------------------------------------
class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  List<EventModel> _events = [];
  bool _isLoading = true;
  bool _isMapView = false;
  String _selectedDistrict = 'ALL';
  EventModel? _selectedMapEvent;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await ApiClient().dio.get('/events');
      final list = (response.data as List)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _events = list;
        _isLoading = false;
        if (_selectedMapEvent == null && list.isNotEmpty) {
          _selectedMapEvent = list.first;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleJoin(EventModel event) async {
    final endpoint = (event.userStatus == 'REGISTERED' || event.userStatus == 'WAITLIST')
        ? 'leave'
        : 'join';
    try {
      await ApiClient().dio.post('/events/${event.id}/$endpoint');
      _fetchEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İşlem başarısız oldu.')),
        );
      }
    }
  }

  Future<void> _startReservation(EventModel event) async {
    try {
      final response = await ApiClient().dio.post('/events/${event.id}/reserve');
      final reservation = EventReservationModel.fromJson(response.data as Map<String, dynamic>);

      if (!mounted) return;

      if (reservation.status == 'FULL') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reservation.message),
            action: SnackBarAction(
              label: 'Yedek Liste',
              onPressed: () => _toggleJoin(event),
            ),
          ),
        );
        return;
      }

      _showReservationDialog(event, reservation.remainingSeconds);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervasyon başlatılamadı.')),
        );
      }
    }
  }

  void _showReservationDialog(EventModel event, int initialSeconds) {
    int remainingSeconds = initialSeconds > 0 ? initialSeconds : 300;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (remainingSeconds <= 1) {
                t.cancel();
                Navigator.of(ctx, rootNavigator: true).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('5 dakikalık süreniz doldu. Kontenjan serbest bırakıldı.')),
                );
                _fetchEvents();
              } else {
                setDialogState(() {
                  remainingSeconds--;
                });
              }
            });

            final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
            final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Kontenjan Ayrıldı!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Kalan Kayıt Süreniz',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$minutes:$seconds',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${event.title} için son kontenjan adınıza rezerve edilmiştir. Bu süre içinde başkası yerinizi alamaz.',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    countdownTimer?.cancel();
                    Navigator.of(ctx, rootNavigator: true).pop();
                    try {
                      await ApiClient().dio.delete('/events/${event.id}/reserve');
                    } catch (_) {}
                    _fetchEvents();
                  },
                  child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
                ),
                FilledButton(
                  onPressed: () async {
                    countdownTimer?.cancel();
                    Navigator.of(ctx, rootNavigator: true).pop();
                    try {
                      await ApiClient().dio.post('/events/${event.id}/confirm');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 Tebrikler, kaydınız başarıyla tamamlandı!')),
                        );
                      }
                      _fetchEvents();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kayıt onaylanamadı.')),
                        );
                      }
                    }
                  },
                  child: const Text('Kaydı Tamamla'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    final isRegistered = event.userStatus == 'REGISTERED';
    final isWaitlist = event.userStatus == 'WAITLIST';
    final isFull = event.currentParticipants >= event.capacity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(event.hobbyIcon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.communityName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              event.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFull ? Colors.red.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isFull
                        ? 'DOLU (${event.currentParticipants}/${event.capacity})'
                        : 'Kontenjan: ${event.currentParticipants}/${event.capacity}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isFull ? Colors.red.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isRegistered || isWaitlist)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                onPressed: () => _toggleJoin(event),
                child: Text(
                  isRegistered
                      ? 'Katılıyorsun (İptal Et)'
                      : 'Yedek Listedesin (İptal Et)',
                ),
              )
            else if (isFull)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                ),
                onPressed: () => _toggleJoin(event),
                child: const Text('Kontenjan Dolu · Yedek Listeye Katıl'),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => _toggleJoin(event),
                    child: const Text('Hemen Katıl'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _startReservation(event),
                    icon: const Icon(Icons.timer_outlined, size: 16),
                    label: const Text('5 Dk Ayır (Kilit)'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawDistricts = _events
        .map((e) => e.district)
        .where((d) => d != null && d.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();
    final districts = ['ALL', ...rawDistricts];

    final filteredEvents = _events.where((e) {
      if (_selectedDistrict == 'ALL') return true;
      return e.district == _selectedDistrict;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buluşmalar & Etkinlikler'),
        actions: [
          IconButton(
            tooltip: _isMapView ? 'Liste Görünümüne Geç' : 'Harita Görünümüne Geç',
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
                if (_isMapView && _selectedMapEvent == null && filteredEvents.isNotEmpty) {
                  _selectedMapEvent = filteredEvents.first;
                }
              });
            },
            icon: Icon(_isMapView ? Icons.view_list_outlined : Icons.map_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dual View Toggle & District Filter
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment(
                                    value: false,
                                    icon: Icon(Icons.view_list_outlined, size: 18),
                                    label: Text('Liste Görünümü'),
                                  ),
                                  ButtonSegment(
                                    value: true,
                                    icon: Icon(Icons.map_outlined, size: 18),
                                    label: Text('Harita Görünümü 🗺️'),
                                  ),
                                ],
                                selected: {_isMapView},
                                onSelectionChanged: (val) {
                                  setState(() {
                                    _isMapView = val.first;
                                    if (_isMapView && _selectedMapEvent == null && filteredEvents.isNotEmpty) {
                                      _selectedMapEvent = filteredEvents.first;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // District Filter Chips
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: districts.length,
                          itemBuilder: (context, index) {
                            final d = districts[index];
                            final isSelected = _selectedDistrict == d;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(d == 'ALL' ? 'Tüm İlçeler 📍' : d),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedDistrict = d;
                                    final curFiltered = _events.where((e) => d == 'ALL' || e.district == d).toList();
                                    if (curFiltered.isNotEmpty && (_selectedMapEvent == null || !curFiltered.contains(_selectedMapEvent))) {
                                      _selectedMapEvent = curFiltered.first;
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // View Content
                Expanded(
                  child: _isMapView
                      ? Stack(
                          children: [
                            // Interactive Map Canvas
                            InteractiveEventMap(
                              events: filteredEvents,
                              selectedEvent: _selectedMapEvent,
                              onSelectEvent: (ev) => setState(() => _selectedMapEvent = ev),
                            ),

                            // Floating Selected Event Inspection Card
                            if (_selectedMapEvent != null)
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(_selectedMapEvent!.hobbyIcon, style: const TextStyle(fontSize: 26)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _selectedMapEvent!.communityName,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.blue.shade800,
                                                    ),
                                                  ),
                                                  Text(
                                                    _selectedMapEvent!.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () => setState(() => _selectedMapEvent = null),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '📍 ${_selectedMapEvent!.district ?? "İstanbul"}',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                _selectedMapEvent!.location,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              ),
                                            ),
                                            Text(
                                              '${_selectedMapEvent!.currentParticipants}/${_selectedMapEvent!.capacity}',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => _toggleJoin(_selectedMapEvent!),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  backgroundColor: _selectedMapEvent!.userStatus == 'REGISTERED'
                                                      ? Colors.red.shade700
                                                      : Colors.blue.shade700,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: Text(
                                                  _selectedMapEvent!.userStatus == 'REGISTERED'
                                                      ? 'Katılıyorsun (İptal)'
                                                      : 'Hemen Katıl',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton(
                                              onPressed: () => _startReservation(_selectedMapEvent!),
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                              ),
                                              child: const Text('5 Dk Ayır', style: TextStyle(fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchEvents,
                          child: filteredEvents.isEmpty
                              ? Center(
                                  child: Text(
                                    'Bu ilçede henüz planlanmış etkinlik yok.',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredEvents.length,
                                  itemBuilder: (context, index) => _buildEventCard(filteredEvents[index]),
                                ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 3: PROFILE TAB
// ---------------------------------------------------------------------------
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await ApiClient().dio.get('/users/profile');
      setState(() {
        _user = UserModel.fromJson(response.data as Map<String, dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAvatar(String newAvatar) async {
    try {
      final response = await ApiClient().dio.patch(
        '/users/profile',
        data: {'avatar': newAvatar},
      );
      setState(() {
        _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil avatarın başarıyla güncellendi! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAvatarPicker() {
    final urlController = TextEditingController();
    final avatarPresets = [
      {'icon': '🏇', 'name': 'Binici'},
      {'icon': '🏺', 'name': 'Seramikçi'},
      {'icon': '📸', 'name': 'Fotoğrafçı'},
      {'icon': '🏃', 'name': 'Koşucu'},
      {'icon': '🌲', 'name': 'Gezgin'},
      {'icon': '🍳', 'name': 'Gurme'},
      {'icon': '💻', 'name': 'Geliştirici'},
      {'icon': '🎨', 'name': 'Sanatçı'},
      {'icon': '🧗', 'name': 'Tırmanışçı'},
      {'icon': '🦊', 'name': 'Kurnaz Tilki'},
      {'icon': '🦉', 'name': 'Bilge Baykuş'},
      {'icon': '🦄', 'name': 'Unicorn'},
      {'icon': '🚀', 'name': 'Astronot'},
      {'icon': '🧑‍💻', 'name': 'Hacker'},
      {'icon': '🎧', 'name': 'Müzisyen'},
      {'icon': '☕', 'name': 'Barista'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
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
              'Profil Görselini veya Avatarını Seç 🎨',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'İster hobi karakterlerinden birini seç, ister kendi fotoğraf bağlantını ekle!',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: avatarPresets.length,
                itemBuilder: (context, index) {
                  final preset = avatarPresets[index];
                  final isSelected = _user?.avatar == preset['icon'];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(ctx);
                      _updateAvatar(preset['icon']!);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                        border: Border.all(
                          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(preset['icon']!, style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 4),
                          Text(
                            preset['name']!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.blue.shade900 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Veya Kendi Fotoğraf Bağlantın (URL) 🔗',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: 'https://images.unsplash.com/...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final url = urlController.text.trim();
                    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                      Navigator.pop(ctx);
                      _updateAvatar(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen geçerli bir https:// fotoğraf adresi girin')),
                      );
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildAvatarWidget(String avatar, double radius) {
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue.shade100,
        backgroundImage: NetworkImage(avatar),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade100,
      child: Text(
        avatar.isNotEmpty ? avatar : '👤',
        style: TextStyle(fontSize: radius * 0.95),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Profil yüklenemedi.'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          _buildAvatarWidget(_user!.avatar, 44),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _showAvatarPicker,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blue.shade700,
                                child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: TextButton.icon(
                        onPressed: _showAvatarPicker,
                        icon: const Icon(Icons.photo_library_outlined, size: 15),
                        label: const Text('Avatarı Değiştir', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _user!.fullName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: Text(
                        '@${_user!.username}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                    if (_user!.bio.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _user!.bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (_user!.location.isNotEmpty)
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _user!.location,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 36),
                    const Text(
                      'Hobilerim & Seviyelerim 🎯',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_user!.hobbies.isEmpty)
                      Text(
                        'Henüz bir hobi seçmedin.',
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    else
                      ..._user!.hobbies.map((hobby) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: Text(hobby.icon, style: const TextStyle(fontSize: 28)),
                              title: Text(
                                hobby.hobbyName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(hobby.category),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  hobby.skillLevel == 'BEGINNER'
                                      ? 'Başlangıç'
                                      : hobby.skillLevel == 'INTERMEDIATE'
                                          ? 'Orta Seviye'
                                          : 'İleri Seviye',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
    );
  }
}
