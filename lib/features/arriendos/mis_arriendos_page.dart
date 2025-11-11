// lib/features/arriendos/mis_arriendos_page.dart
// ===============================================================
// 🔹 Mis Arriendos – Vista empresarial completa
// - KPIs
// - Búsqueda, filtros y orden
// - Acciones rápidas: publicar/pausar/borrador/archivar, clonar, editar, eliminar
// - Exportar CSV (de los resultados actuales) → guarda y comparte archivo
// - Paginación local + pull-to-refresh
// - Código limpio (sin deprecaciones, con mounted checks)
// ===============================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  // Datos y estado
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _view = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  final int _limit = 15;
  String? _lastError;

  // Búsqueda / filtros / orden
  String _query = '';
  _Filters _filters = const _Filters();
  _OrderBy _orderBy = _OrderBy.updatedDesc;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  // ====================== Carga de datos ======================
  Future<void> _load({bool reset = false}) async {
    if (reset && mounted) {
      setState(() {
        _loading = true;
        _all = [];
        _view = [];
        _hasMore = true;
        _lastError = null;
      });
    }
    try {
      final data = await _svc.getMyProperties();
      if (!mounted) return;

      _all = data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      _applyFiltersOrderSearch();
      _rebuildPage(reset: true);

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastError = e.toString();
        _loading = false;
      });
      // ok porque ya verificamos mounted arriba
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar: $e')));
    }
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 160) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore) return;
    if (mounted) setState(() => _loadingMore = true);
    _rebuildPage(); // pagina siguiente de la lista filtrada/ordenada
    if (mounted) setState(() => _loadingMore = false);
  }

  // ====================== Búsqueda / filtros / orden ======================
  void _applyFiltersOrderSearch() {
    Iterable<Map<String, dynamic>> list = _all;

    // Filtros
    if (_filters.status != null) {
      final st = _filters.status!;
      list = list.where(
        (p) => (p['status'] ?? 'published').toString().toLowerCase() == st,
      );
    }
    if (_filters.type?.isNotEmpty == true) {
      list = list.where(
        (p) =>
            (p['tipo'] ?? p['type'] ?? '').toString().toLowerCase() ==
            _filters.type!.toLowerCase(),
      );
    }
    if (_filters.category?.isNotEmpty == true) {
      list = list.where(
        (p) =>
            (p['categoria'] ?? p['category'] ?? '').toString().toLowerCase() ==
            _filters.category!.toLowerCase(),
      );
    }
    if (_filters.comuna?.isNotEmpty == true) {
      list = list.where(
        (p) => (p['comuna'] ?? p['ubicacion'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_filters.comuna!.toLowerCase()),
      );
    }
    if (_filters.minPrice != null) {
      list = list.where(
        (p) => (p['precio'] ?? p['price'] ?? 0) >= _filters.minPrice!,
      );
    }
    if (_filters.maxPrice != null) {
      list = list.where(
        (p) => (p['precio'] ?? p['price'] ?? 0) <= _filters.maxPrice!,
      );
    }

    // Búsqueda
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) {
        final title =
            (p['titulo'] ?? p['title'] ?? '').toString().toLowerCase();
        final desc = (p['descripcion'] ?? p['description'] ?? '')
            .toString()
            .toLowerCase();
        return title.contains(q) || desc.contains(q);
      });
    }

    // Orden
    final out = list.toList();
    switch (_orderBy) {
      case _OrderBy.updatedDesc:
        out.sort(
          (a, b) => _str(b['updatedAt']).compareTo(_str(a['updatedAt'])),
        );
        break;
      case _OrderBy.createdDesc:
        out.sort(
          (a, b) => _str(b['createdAt']).compareTo(_str(a['createdAt'])),
        );
        break;
      case _OrderBy.priceAsc:
        out.sort(
          (a, b) => _num(
            a['precio'] ?? a['price'],
          ).compareTo(_num(b['precio'] ?? b['price'])),
        );
        break;
      case _OrderBy.priceDesc:
        out.sort(
          (a, b) => _num(
            b['precio'] ?? b['price'],
          ).compareTo(_num(a['precio'] ?? a['price'])),
        );
        break;
    }

    _filteredOrdered = out;
  }

  String _str(dynamic v) => (v ?? '').toString();
  num _num(dynamic v) {
    if (v is num) return v;
    return num.tryParse((v ?? '0').toString()) ?? 0;
  }

  List<Map<String, dynamic>> _filteredOrdered = [];

  void _rebuildPage({bool reset = false}) {
    final begin = (reset ? 0 : _view.length);
    final next = _filteredOrdered.skip(begin).take(_limit).toList();
    if (reset) {
      _view = next;
    } else {
      _view = [..._view, ...next];
    }
    _hasMore = _view.length < _filteredOrdered.length;
    if (mounted) setState(() {});
  }

  // ====================== Acciones ======================
  Future<void> _goCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CrearArriendoPage()),
    );
    if (!mounted) return;
    if (created == true) await _load(reset: true);
  }

  Future<void> _edit(Map<String, dynamic> p) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CrearArriendoPage(editId: (p['id'] ?? '').toString()),
      ),
    );
    if (!mounted) return;
    if (changed == true) await _load(reset: true);
  }

  Future<void> _delete(String id) async {
    final ok = await _svc.delete(id);
    if (!mounted) return;
    if (ok) {
      _all.removeWhere((e) => (e['id'] ?? '').toString() == id);
      _applyFiltersOrderSearch();
      _rebuildPage(reset: true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Eliminado')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo eliminar')));
    }
  }

  Future<void> _changeStatus(String id, String status) async {
    final ok = await (_svc as dynamic).changeStatus?.call(id, status) ?? true;
    if (!mounted) return;
    if (ok) {
      final i = _all.indexWhere((e) => (e['id'] ?? '').toString() == id);
      if (i >= 0) _all[i]['status'] = status;
      _applyFiltersOrderSearch();
      _rebuildPage(reset: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cambiar el estado')),
      );
    }
  }

  Future<void> _clone(String id) async {
    final ok = await (_svc as dynamic).clone?.call(id) ?? true;
    if (!mounted) return;
    if (ok) {
      await _load(reset: true);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Clonado')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo clonar')));
    }
  }

  Future<void> _exportCsv() async {
    final rows = <List<String>>[
      [
        'ID',
        'Título',
        'Precio',
        'Estado',
        'Tipo',
        'Categoría',
        'Comuna',
        'Creado',
        'Actualizado',
      ],
      ..._filteredOrdered.map(
        (p) => [
          (p['id'] ?? '').toString(),
          (p['titulo'] ?? p['title'] ?? '').toString(),
          (p['precio'] ?? p['price'] ?? '').toString(),
          (p['status'] ?? '').toString(),
          (p['tipo'] ?? p['type'] ?? '').toString(),
          (p['categoria'] ?? p['category'] ?? '').toString(),
          (p['comuna'] ?? p['ubicacion'] ?? '').toString(),
          (p['createdAt'] ?? '').toString(),
          (p['updatedAt'] ?? '').toString(),
        ],
      ),
    ];
    final csvString = const ListToCsv().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/mis_arriendos_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsBytes(utf8.encode(csvString));

    if (!mounted) return;
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Mis arriendos – SmartRent+',
      subject: 'Exportación CSV',
    );
  }

  // ====================== KPIs ======================
  int get _kPublicados => _all
      .where(
        (p) =>
            (p['status'] ?? 'published') == 'published' ||
            (p['status'] ?? '') == 'Publicado',
      )
      .length;
  int get _kBorradores => _all
      .where(
        (p) =>
            (p['status'] ?? 'draft') == 'draft' ||
            (p['status'] ?? '') == 'Borrador',
      )
      .length;
  int get _kVisitas =>
      _all.fold<int>(0, (a, b) => a + ((b['visitas'] ?? 0) as int));
  int get _kReservas =>
      _all.fold<int>(0, (a, b) => a + ((b['reservas'] ?? 0) as int));

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _SearchBox(
          initial: _query,
          onChanged: (v) {
            _query = v;
            _applyFiltersOrderSearch();
            _rebuildPage(reset: true);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Filtros y orden',
            icon: const Icon(Icons.tune),
            onPressed: () async {
              final res = await showModalBottomSheet<_FiltersOrder>(
                context: context,
                isScrollControlled: true,
                builder: (_) => _FiltersSheet(
                  initialFilters: _filters,
                  initialOrder: _orderBy,
                ),
              );
              if (!mounted) return;
              if (res != null) {
                _filters = res.filters;
                _orderBy = res.orderBy;
                _applyFiltersOrderSearch();
                _rebuildPage(reset: true);
              }
            },
          ),
          IconButton(
            tooltip: 'Exportar CSV',
            icon: const Icon(Icons.download),
            onPressed: _exportCsv,
          ),
          IconButton(
            tooltip: 'Crear arriendo',
            onPressed: _goCreate,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                children: [
                  // KPIs
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

                  if (_view.isEmpty)
                    _EmptyState(onCreate: _goCreate)
                  else
                    ..._view.map(
                      (p) => _PropertyTile(
                        data: p,
                        onEdit: () => _edit(p),
                        onDelete: () => _delete((p['id'] ?? '').toString()),
                        onChangeStatus: (st) =>
                            _changeStatus((p['id'] ?? '').toString(), st),
                        onClone: () => _clone((p['id'] ?? '').toString()),
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

// ====================== Widgets auxiliares ======================

class _SearchBox extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const _SearchBox({required this.initial, required this.onChanged});

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  late final TextEditingController _c = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        hintText: 'Buscar por título o descripción…',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 0),
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
      color: const Color(0xFFFF0000).withValues(alpha: 0.05),
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
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.add_business_outlined, size: 36, color: Colors.blue),
          const SizedBox(height: 8),
          const Text(
            'Aún no tienes publicaciones.\nToca “Crear arriendo” para publicar tu primer aviso.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Crear arriendo'),
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
  final Future<void> Function(String status) onChangeStatus;
  final VoidCallback onClone;

  const _PropertyTile({
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onChangeStatus,
    required this.onClone,
  });

  @override
  Widget build(BuildContext context) {
    final image = data['image_url'] ?? data['imageUrl'] ?? '';
    final title = (data['titulo'] ?? data['title'] ?? '').toString();
    final price = (data['precio'] ?? data['price'] ?? 0).toString();
    final status = (data['status'] ?? 'published').toString();

    Color badgeColor(String s) {
      switch (s) {
        case 'published':
        case 'Publicado':
          return const Color(0xFF2E7D32);
        case 'paused':
        case 'Pausado':
          return const Color(0xFFFB8C00);
        case 'draft':
        case 'Borrador':
          return const Color(0xFF546E7A);
        default:
          return const Color(0xFF757575);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: image.toString().isEmpty
              ? Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFE0E0E0),
                  child: const Icon(Icons.image_not_supported),
                )
              : Image.network(
                  image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Text('$price CLP   '),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor(status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                status == 'published'
                    ? 'Publicado'
                    : status == 'paused'
                        ? 'Pausado'
                        : status == 'draft'
                            ? 'Borrador'
                            : status,
                style: TextStyle(color: badgeColor(status), fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            PopupMenuButton<String>(
              tooltip: 'Más',
              onSelected: (v) async {
                if (v == 'publish') await onChangeStatus('published');
                if (v == 'pause') await onChangeStatus('paused');
                if (v == 'draft') await onChangeStatus('draft');
                if (v == 'archive') await onChangeStatus('archived');
                if (v == 'clone') onClone();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'publish', child: Text('Publicar')),
                PopupMenuItem(value: 'pause', child: Text('Pausar')),
                PopupMenuItem(value: 'draft', child: Text('Pasar a borrador')),
                PopupMenuItem(value: 'archive', child: Text('Archivar')),
                PopupMenuDivider(),
                PopupMenuItem(value: 'clone', child: Text('Clonar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== BottomSheet de filtros/orden ======================

class _FiltersSheet extends StatefulWidget {
  final _Filters initialFilters;
  final _OrderBy initialOrder;
  const _FiltersSheet({
    required this.initialFilters,
    required this.initialOrder,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late _Filters f = widget.initialFilters;
  late _OrderBy o = widget.initialOrder;

  final _status = const [null, 'published', 'paused', 'draft', 'archived'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Filtros',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    // value → deprecated; usar initialValue
                    initialValue: f.status,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: _status
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s == null ? 'Todos' : s),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => f = f.copyWith(status: v)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: f.type ?? '',
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    onChanged: (v) => setState(
                      () => f = f.copyWith(type: v.trim().isEmpty ? null : v),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: f.category ?? '',
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    onChanged: (v) => setState(
                      () =>
                          f = f.copyWith(category: v.trim().isEmpty ? null : v),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: f.comuna ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Comuna/Ubicación',
                    ),
                    onChanged: (v) => setState(
                      () => f = f.copyWith(comuna: v.trim().isEmpty ? null : v),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: f.minPrice?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio mínimo',
                    ),
                    onChanged: (v) => setState(
                      () => f = f.copyWith(
                        minPrice: v.isEmpty ? null : int.tryParse(v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: f.maxPrice?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio máximo',
                    ),
                    onChanged: (v) => setState(
                      () => f = f.copyWith(
                        maxPrice: v.isEmpty ? null : int.tryParse(v),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ordenar por',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<_OrderBy>(
              // value → deprecated; usar initialValue
              initialValue: o,
              items: const [
                DropdownMenuItem(
                  value: _OrderBy.updatedDesc,
                  child: Text('Actualizado (recientes primero)'),
                ),
                DropdownMenuItem(
                  value: _OrderBy.createdDesc,
                  child: Text('Creado (recientes primero)'),
                ),
                DropdownMenuItem(
                  value: _OrderBy.priceAsc,
                  child: Text('Precio (menor a mayor)'),
                ),
                DropdownMenuItem(
                  value: _OrderBy.priceDesc,
                  child: Text('Precio (mayor a menor)'),
                ),
              ],
              onChanged: (v) => setState(() => o = v ?? o),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => f = const _Filters()),
                  child: const Text('Limpiar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _FiltersOrder(filters: f, orderBy: o),
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _FiltersOrder {
  final _Filters filters;
  final _OrderBy orderBy;
  const _FiltersOrder({required this.filters, required this.orderBy});
}

class _Filters {
  final String? status; // published | paused | draft | archived
  final String? type; // casa, depto, auto, herramienta, ...
  final String? category; // subcategoría
  final String? comuna;
  final int? minPrice;
  final int? maxPrice;

  const _Filters({
    this.status,
    this.type,
    this.category,
    this.comuna,
    this.minPrice,
    this.maxPrice,
  });

  _Filters copyWith({
    String? status,
    String? type,
    String? category,
    String? comuna,
    int? minPrice,
    int? maxPrice,
  }) {
    return _Filters(
      status: status ?? this.status,
      type: type ?? this.type,
      category: category ?? this.category,
      comuna: comuna ?? this.comuna,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

enum _OrderBy { updatedDesc, createdDesc, priceAsc, priceDesc }

// Utilidad pequeña para CSV local (sin dependencias externas)
class ListToCsv {
  const ListToCsv();
  String convert(List<List<String>> rows) {
    String esc(String s) {
      if (s.contains('"') || s.contains(',') || s.contains('\n')) {
        return '"${s.replaceAll('"', '""')}"';
      }
      return s;
    }

    return rows.map((r) => r.map(esc).join(',')).join('\n');
  }
}
