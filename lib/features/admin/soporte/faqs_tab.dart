import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/api_service.dart';
import 'package:smartrent_plus/data/services/soporte_service.dart';

class FaqsTab extends StatefulWidget {
  const FaqsTab({super.key});

  @override
  State<FaqsTab> createState() => _FaqsTabState();
}

class _FaqsTabState extends State<FaqsTab> {
  final _svc = SoporteService(ApiService());
  List<Map<String, String>> faqs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      faqs = await _svc.fetchFaqs();
    } catch (e) {
      debugPrint('Error FAQ: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadFaqs,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: faqs.length,
              itemBuilder: (_, i) {
                final q = faqs[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    leading: const Icon(Icons.help_outline),
                    title: Text(q['q'] ?? 'Sin pregunta'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(q['a'] ?? 'Sin respuesta'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
