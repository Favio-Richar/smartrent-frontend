import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/property_service.dart';
import 'package:smartrent_plus/features/arriendos/crear_arriendo_page.dart';

class MisArriendosPage extends StatefulWidget {
  const MisArriendosPage({super.key});

  @override
  State<MisArriendosPage> createState() => _MisArriendosPageState();
}

class _MisArriendosPageState extends State<MisArriendosPage> {
  final _svc = PropertyService();
  final _scroll = ScrollController();

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 160) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _items = [];
        _page = 1;
        _hasMore = true;
        _lastError = null;
      });
    }
    try {
      final data = await _svc.getMyProperties(); // trae todas las del usuario
      if (!mounted) return;

      // Simulamos paginación local si el endpoint no tiene paginación
      final begin = (_page - 1) * _limit;
      final end = _page * _limit;
      final slice = data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList()
          .skip(begin)
          .take(_limit)
          .toList();

      setState(() {
        _items = reset ? slice : [..._items, ...slice];
        _hasMore = slice.length == _limit;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastError = e.toString();
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar: $e')));
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore) return;
    setState(() => _loadingMore = true);
    _page += 1;
    await _load();
    if (mounted) setState(() => _loadingMore = false);
  }

  Future<void> _delete(String id) async {
    final ok = await _svc.delete(id);
    if (!mounted) return;
    if (ok) {
      _items.removeWhere((e) => (e['id'] ?? '').toString() == id);
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Eliminado')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo eliminar')));
    }
  }

  void _edit(Map<String, dynamic> p) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearArriendoPage(editId: (p['id'] ?? '').toString()),
      ),
    );
    if (changed == true) _load(reset: true);
  }

  // ----- KPIs simples (si el back envía contadores, cámbialos aquí) -----
  int get _kPublicados => _items.length;
  int get _kBorradores => 0; // ajusta si manejas estados
  int get _kVisitas =>
      _items.fold<int>(0, (a, b) => a + ((b['visitas'] ?? 0) as int));
  int get _kReservas =>
      _items.fold<int>(0, (a, b) => a + ((b['reservas'] ?? 0) as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Arriendos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearArriendoPage()),
          );
          if (created == true) _load(reset: true);
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                children: [
                  // ---- Mini dashboard arriba
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          label: 'Publicados',
                          value: _kPublicados,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _KpiCard(
                          label: 'Borradores',
                          value: _kBorradores,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(label: 'Visitas', value: _kVisitas),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _KpiCard(label: 'Reservas', value: _kReservas),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_lastError != null) ...[
                    _ErrorCard(message: _lastError!),
                    const SizedBox(height: 12),
                  ],

                  if (_items.isEmpty)
                    const _EmptyState()
                  else
                    ..._items.map(
                      (p) => _PropertyTile(
                        data: p,
                        onEdit: () => _edit(p),
                        onDelete: () => _delete((p['id'] ?? '').toString()),
                      ),
                    ),

                  if (_loadingMore) ...[
                    const SizedBox(height: 12),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final int value;
  const _KpiCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          Icon(Icons.add_business_outlined, size: 36, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            'Aún no tienes publicaciones.\nToca el botón “+” para crear tu primer arriendo.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PropertyTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PropertyTile({
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final image = data['image_url'] ?? data['imageUrl'] ?? '';
    final title = (data['title'] ?? '').toString();
    final price = (data['price'] ?? 0).toString();
    final status = (data['status'] ?? 'Publicado').toString();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: image.toString().isEmpty
              ? Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                )
              : Image.network(
                  image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
        ),
        title: Text(title),
        subtitle: Text('$price CLP • $status'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}
