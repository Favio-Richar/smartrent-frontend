import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartrent_plus/data/providers/soporte_provider.dart';
import 'package:smartrent_plus/data/services/api_service.dart';
import 'package:smartrent_plus/data/services/soporte_service.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  bool _hasProvider(BuildContext context) {
    try {
      Provider.of<SoporteProvider>(context, listen: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasProvider(context)) return const _FaqBody();
    return ChangeNotifierProvider(
      create: (_) => SoporteProvider(SoporteService(ApiService())),
      child: const _FaqBody(),
    );
  }
}

class _FaqBody extends StatefulWidget {
  const _FaqBody();

  @override
  State<_FaqBody> createState() => _FaqBodyState();
}

class _FaqBodyState extends State<_FaqBody> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Cargar FAQs luego del primer frame y tomar el argumento (query inicial)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SoporteProvider>().loadFaqs();

      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String && arg.trim().isNotEmpty) {
        _searchCtrl.text = arg.trim();
        setState(() => _query = _searchCtrl.text);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soporte = context.watch<SoporteProvider>();

    final faqs = soporte.faqs
        .where((f) =>
            (f['q'] ?? '').toLowerCase().contains(_query.toLowerCase()) ||
            (f['a'] ?? '').toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Preguntas frecuentes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar en las FAQs…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),
          if (faqs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('No se encontraron resultados.')),
            ),
          for (final f in faqs) ...[
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const Icon(Icons.help_outline_rounded,
                    color: Colors.indigo),
                title: Text(
                  f['q'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(f['a'] ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
