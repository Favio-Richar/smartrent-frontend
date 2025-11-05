// lib/features/arriendos/arriendos_page.dart
import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/property_service.dart';
import 'package:smartrent_plus/features/arriendos/widgets/card_propiedad.dart';
import 'package:smartrent_plus/features/arriendos/widgets/filtro_arriendos_widget.dart';

class ArriendosPage extends StatefulWidget {
  const ArriendosPage({super.key});

  @override
  State<ArriendosPage> createState() => _ArriendosPageState();
}

class _ArriendosPageState extends State<ArriendosPage> {
  // --- Servicios & Scroll ---
  final _service = PropertyService();
  final _scroll = ScrollController();

  // --- Estado de datos ---
  List<Map<String, dynamic>> _items = [];
  bool _loading = true; // primera carga
  bool _loadingMore = false; // paginación
  bool _hasMore = true; // hay más páginas
  int _page = 1;
  final int _limit = 12;

  // --- Filtros / Orden / Vista ---
  Map<String, dynamic> _filters = {};
  String _sort = 'Recientes'; // Recientes | Precio ↑ | Precio ↓
  bool _grid = true; // true = Grid, false = Lista

  // Categorías rápidas (ampliadas)
  final List<_QuickCat> _quickCats = const [
    _QuickCat('propiedad', Icons.home_work_outlined),
    _QuickCat('vehiculo', Icons.directions_car),
    _QuickCat('cancha', Icons.sports_soccer),
    _QuickCat('piscina', Icons.pool),
    _QuickCat('herramienta', Icons.handyman),
    _QuickCat('terreno', Icons.terrain),
    _QuickCat('oficina', Icons.apartment),
    _QuickCat('maquinaria', Icons.agriculture),
    _QuickCat('evento', Icons.event_seat),
  ];
  String? _selectedQuick; // categoría rápida activa

  // --- Comunas (selector) ---
  // --TODO:reemplazar por lista desde backend si la tienes disponible.//
  final List<String> _comunas = const [
    'Santiago',
    'Las Condes',
    'Providencia',
    'Ñuñoa',
    'La Florida',
    'Maipú',
    'Puente Alto',
    'Vitacura',
    'Huechuraba',
    'La Reina',
    'Antofagasta',
    'Valparaíso',
    'Viña del Mar',
    'Rancagua',
    'Concepción',
  ];
  String? _selectedComuna;

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

  // --- Scroll infinito ---
  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // --- Carga (API) ---
  Future<void> _load({bool reset = false}) async {
    try {
      if (reset) {
        setState(() {
          _loading = true;
          _page = 1;
          _hasMore = true;
          _items = [];
        });
      }

      // Construir query combinando filtros + sort + categoría rápida + comuna
      final q = Map<String, dynamic>.from(_filters);
      if (_selectedQuick != null && _selectedQuick!.isNotEmpty) {
        q['tipo'] = _selectedQuick; // integra chips con tu filtro
      }
      if (_selectedComuna != null && _selectedComuna!.isNotEmpty) {
        q['comuna'] = _selectedComuna; // clave de backend para comuna
      }
      // Ordenamiento (si el backend lo soporta)
      if (_sort == 'Precio ↑') q['sort'] = 'price_asc';
      if (_sort == 'Precio ↓') q['sort'] = 'price_desc';

      final data = await _service.getAll(
        filters: q,
        page: _page,
        limit: _limit,
      );

      if (!mounted) return;
      final list = data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      // Fallback de orden local si el backend aún no ordena
      if (_sort == 'Precio ↑') {
        list.sort(
          (a, b) => ((a['price'] ?? a['precio'] ?? 0) as num).compareTo(
            (b['price'] ?? b['precio'] ?? 0) as num,
          ),
        );
      } else if (_sort == 'Precio ↓') {
        list.sort(
          (a, b) => ((b['price'] ?? b['precio'] ?? 0) as num).compareTo(
            (a['price'] ?? a['precio'] ?? 0) as num,
          ),
        );
      }

      setState(() {
        _items = reset ? list : [..._items, ...list];
        _hasMore = list.length == _limit;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando catálogo: $e'),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: () => _load(reset: true),
          ),
        ),
      );
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore) return;
    setState(() => _loadingMore = true);
    _page += 1;
    try {
      final q = Map<String, dynamic>.from(_filters);
      // ✅ Envolver en bloques para evitar la alerta (sin cambiar lógica)
      if (_selectedQuick != null && _selectedQuick!.isNotEmpty) {
        q['tipo'] = _selectedQuick;
      }
      if (_selectedComuna != null && _selectedComuna!.isNotEmpty) {
        q['comuna'] = _selectedComuna;
      }
      if (_sort == 'Precio ↑') q['sort'] = 'price_asc';
      if (_sort == 'Precio ↓') q['sort'] = 'price_desc';

      final more = await _service.getAll(
        filters: q,
        page: _page,
        limit: _limit,
      );
      if (!mounted) return;
      final list = more
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      // Fallback de orden local
      if (_sort == 'Precio ↑') {
        list.sort(
          (a, b) => ((a['price'] ?? a['precio'] ?? 0) as num).compareTo(
            (b['price'] ?? b['precio'] ?? 0) as num,
          ),
        );
      } else if (_sort == 'Precio ↓') {
        list.sort(
          (a, b) => ((b['price'] ?? b['precio'] ?? 0) as num).compareTo(
            (a['price'] ?? a['precio'] ?? 0) as num,
          ),
        );
      }

      setState(() {
        _items.addAll(list);
        _hasMore = list.length == _limit;
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // --- UI handlers ---
  void _applyFilters(Map<String, dynamic> f) {
    _filters = f;
    _load(reset: true);
  }

  void _toggleView() => setState(() => _grid = !_grid);

  void _changeSort(String? v) {
    if (v == null) return;
    setState(() => _sort = v);
    _load(reset: true);
  }

  void _tapQuick(String cat) {
    setState(() => _selectedQuick = (_selectedQuick == cat) ? null : cat);
    _load(reset: true);
  }

  Future<void> _openComunasPicker() async {
    String query = '';
    final sel = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        List<String> current = _comunas;
        return StatefulBuilder(
          builder: (ctx, setS) {
            final filtered = current
                .where((c) => c.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Selecciona una comuna',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Buscar comuna…',
                      ),
                      onChanged: (t) => setS(() => query = t),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => ListTile(
                          leading: const Icon(Icons.location_city),
                          title: Text(filtered[i]),
                          onTap: () => Navigator.pop(ctx, filtered[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (sel != null) {
      setState(() => _selectedComuna = sel);
      _load(reset: true);
    }
  }

  void _clearComuna() {
    setState(() => _selectedComuna = null);
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          // Orden
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sort,
                borderRadius: BorderRadius.circular(12),
                alignment: Alignment.centerRight,
                items: const [
                  DropdownMenuItem(
                    value: 'Recientes',
                    child: Text('Recientes'),
                  ),
                  DropdownMenuItem(value: 'Precio ↑', child: Text('Precio ↑')),
                  DropdownMenuItem(value: 'Precio ↓', child: Text('Precio ↓')),
                ],
                onChanged: _changeSort,
              ),
            ),
          ),
          // Toggle Grid/List
          IconButton(
            tooltip: _grid ? 'Ver en lista' : 'Ver en grilla',
            onPressed: _toggleView,
            icon: Icon(
              _grid ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Filtros avanzados (tu widget)
          FiltroArriendosWidget(onApply: _applyFilters),

          // Categorías rápidas
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _quickCats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _quickCats[i];
                final selected = _selectedQuick == cat.key;
                return ChoiceChip(
                  label: Text(cat.key[0].toUpperCase() + cat.key.substring(1)),
                  avatar: Icon(cat.icon, size: 18),
                  selected: selected,
                  onSelected: (_) => _tapQuick(cat.key),
                );
              },
            ),
          ),

          // Barra comuna + resumen + chips activos
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Column(
              children: [
                Row(
                  children: [
                    // Botón comuna
                    OutlinedButton.icon(
                      onPressed: _openComunasPicker,
                      icon: const Icon(Icons.location_on_outlined),
                      label: Text(
                        _selectedComuna == null
                            ? 'Comuna'
                            : 'Comuna: $_selectedComuna',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _loading
                          ? 'Cargando…'
                          : '${_items.length}${_hasMore ? '+' : ''} resultados',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Chips activos (categoría rápida + comuna)
                Wrap(
                  spacing: 8,
                  runSpacing: -8,
                  children: [
                    if (_selectedQuick != null)
                      _ActiveChip(
                        text: _selectedQuick!,
                        onRemove: () => _tapQuick(_selectedQuick!),
                      ),
                    if (_selectedComuna != null)
                      _ActiveChip(
                        text: _selectedComuna!,
                        onRemove: _clearComuna,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: _loading
                ? const _SkeletonList(grid: true)
                : (_items.isEmpty
                      ? _EmptyState(onRetry: () => _load(reset: true))
                      : RefreshIndicator(
                          onRefresh: () => _load(reset: true),
                          child: _grid
                              ? _GridCatalog(
                                  items: _items,
                                  controller: _scroll,
                                  loadingMore: _loadingMore,
                                )
                              : _ListCatalog(
                                  items: _items,
                                  controller: _scroll,
                                  loadingMore: _loadingMore,
                                ),
                        )),
          ),
        ],
      ),
    );
  }
}

// =====================
// Widgets PRIVADOS UI
// =====================

class _ActiveChip extends StatelessWidget {
  final String text;
  final VoidCallback onRemove;
  const _ActiveChip({required this.text, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
    );
  }
}

// Grid con tus cards
class _GridCatalog extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ScrollController controller;
  final bool loadingMore;
  const _GridCatalog({
    required this.items,
    required this.controller,
    required this.loadingMore,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .78,
      ),
      itemCount: items.length + (loadingMore ? 2 : 0),
      itemBuilder: (_, i) {
        if (i >= items.length) return const _CardSkeleton();
        return CardPropiedadMap(data: items[i]);
      },
    );
  }
}

// Lista vertical (misma card pero a ancho completo)
class _ListCatalog extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ScrollController controller;
  final bool loadingMore;
  const _ListCatalog({
    required this.items,
    required this.controller,
    required this.loadingMore,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.all(12),
      itemCount: items.length + (loadingMore ? 2 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        if (i >= items.length) return const _RowSkeleton();
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: CardPropiedadMap(data: items[i]),
        );
      },
    );
  }
}

// Empty state con CTA
class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'No encontramos publicaciones con esos filtros.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Prueba limpiarlos o cambia la categoría.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Volver a buscar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Skeletons/Placeholders
class _SkeletonList extends StatelessWidget {
  final bool grid;
  const _SkeletonList({required this.grid});

  @override
  Widget build(BuildContext context) {
    if (grid) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .78,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const _CardSkeleton(),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _RowSkeleton(),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.black12,
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.black12,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 160,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(width: 180, height: 130, color: Colors.black12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 14, color: Colors.black12),
                  const SizedBox(height: 10),
                  Container(height: 12, color: Colors.black12),
                  const SizedBox(height: 10),
                  Container(height: 12, color: Colors.black12),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _QuickCat {
  final String key;
  final IconData icon;
  const _QuickCat(this.key, this.icon);
}
