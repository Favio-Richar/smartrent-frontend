import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/api_service.dart';
import 'package:smartrent_plus/data/services/soporte_service.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  final _svc = SoporteService(ApiService());
  List<Map<String, dynamic>> posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      posts = await _svc.fetchCommunityPosts();
    } catch (e) {
      debugPrint('Error comunidad: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadPosts,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (_, i) {
                final p = posts[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.forum),
                    title: Text(p['title'] ?? 'Sin título'),
                    subtitle: Text(p['body'] ?? 'Sin contenido'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Función eliminar publicación en desarrollo')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
  }
}
