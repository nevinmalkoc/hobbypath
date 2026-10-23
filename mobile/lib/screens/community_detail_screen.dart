import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/models.dart';
import 'community_chat_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  late CommunityModel _community;
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await ApiClient().dio.get('/communities/${_community.id}/posts');
      final list = (response.data as List)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _posts = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleJoin() async {
    final endpoint = _community.isMember ? 'leave' : 'join';
    try {
      final response = await ApiClient().dio.post('/communities/${_community.id}/$endpoint');
      if (!mounted) return;
      setState(() {
        _community = CommunityModel.fromJson(response.data as Map<String, dynamic>);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşlem başarısız oldu.')),
      );
    }
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${_community.name} İçinde Paylaş',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Başlık (Örn: Ekipman tavsiyesi var mı?)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Sorun veya Deneyimin...',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                    return;
                  }
                  Navigator.pop(ctx);
                  try {
                    await ApiClient().dio.post(
                      '/communities/${_community.id}/posts',
                      data: {
                        'title': titleController.text.trim(),
                        'content': contentController.text.trim(),
                      },
                    );
                    _fetchPosts();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gönderi paylaşılamadı.')),
                      );
                    }
                  }
                },
                child: const Text('Paylaş'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_community.name),
        actions: [
          if (_community.isMember)
            IconButton(
              icon: const Icon(Icons.forum_outlined),
              tooltip: 'Topluluk Sohbeti',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommunityChatScreen(community: _community),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Soru Sor / Paylaş'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Topluluk Başlığı Kartı
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(_community.hobbyIcon, style: const TextStyle(fontSize: 36)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _community.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_community.memberCount} Üye · ${_community.hobbyName}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_community.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _community.description,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _toggleJoin,
                              icon: Icon(
                                _community.isMember ? Icons.check : Icons.group_add_outlined,
                                size: 18,
                              ),
                              label: Text(_community.isMember ? 'Üyesin (Ayrıl)' : 'Topluluğa Katıl'),
                            ),
                            if (_community.isMember)
                              FilledButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CommunityChatScreen(community: _community),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                label: const Text('Canlı Sohbet Odası'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tartışmalar & Paylaşımlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_posts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Henüz paylaşım yapılmamış.\nİlk soruyu sen sor!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  ..._posts.map((post) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
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
                                  Text(
                                    post.authorFullName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                post.content,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      )),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}
