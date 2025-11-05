import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/property_service.dart';
import 'package:smartrent_plus/features/arriendos/detalle_arriendo_page.dart';

class CardPropiedadMap extends StatefulWidget {
  final Map<String, dynamic> data;
  const CardPropiedadMap({super.key, required this.data});

  @override
  State<CardPropiedadMap> createState() => _CardPropiedadMapState();
}

class _CardPropiedadMapState extends State<CardPropiedadMap> {
  final _svc = PropertyService();
  late bool _fav;

  @override
  void initState() {
    super.initState();
    _fav =
        (widget.data['is_favorite'] ?? widget.data['isFavorite'] ?? false) ==
        true;
  }

  Future<void> _toggleFav() async {
    final id =
        (widget.data['id'] ??
                widget.data['propertyId'] ??
                widget.data['property_id'] ??
                '')
            .toString();
    if (id.isEmpty) return;
    final ok = await _svc.toggleFavorite(id);
    if (ok && mounted) setState(() => _fav = !_fav);
  }

  // ---------- helpers ----------
  String _s(dynamic v) => (v ?? '').toString();
  bool _isHttp(String u) => u.startsWith('http://') || u.startsWith('https://');
  bool _isFile(String u) =>
      u.startsWith('file:/') || (!u.contains('://') && u.isNotEmpty);

  String? _pickImage(Map<String, dynamic> p) {
    final list = <dynamic>[
      p['image_url'],
      p['imageUrl'],
      p['imagen'],
      (p['images'] is List && (p['images'] as List).isNotEmpty)
          ? (p['images'] as List).first
          : null,
      (p['media'] is List && (p['media'] as List).isNotEmpty)
          ? (p['media'] as List).first
          : null,
    ].map((e) => e?.toString()).where((e) => (e ?? '').isNotEmpty).toList();
    return list.isEmpty ? null : list.first;
  }

  Widget _thumb(String? url) {
    if (url == null) {
      return const ColoredBox(color: Color(0xFFEFEFEF));
    }
    if (_isHttp(url)) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const ColoredBox(color: Color(0xFFEFEFEF)),
      );
    }
    if (_isFile(url)) {
      final path = url.startsWith('file:/') ? Uri.parse(url).toFilePath() : url;
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const ColoredBox(color: Color(0xFFEFEFEF)),
      );
    }
    return const ColoredBox(color: Color(0xFFEFEFEF));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.data;

    final id = _s(p['id'] ?? p['propertyId'] ?? p['property_id']);
    final title = _s(p['title'] ?? p['titulo'] ?? p['nombre']);
    final priceRaw = p['price'] ?? p['precio'];
    final price = priceRaw == null
        ? ''
        : (priceRaw is num ? priceRaw.toStringAsFixed(0) : priceRaw.toString());
    final location = _s(
      p['location'] ?? p['ubicacion'] ?? p['ciudad'] ?? p['comuna'],
    );
    final img = _pickImage(p);

    return GestureDetector(
      onTap: () {
        if (id.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleArriendoPage(propertyId: id),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        elevation: 2.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(aspectRatio: 16 / 10, child: _thumb(img)),
                Positioned(
                  right: 8,
                  top: 8,
                  child: InkWell(
                    onTap: _toggleFav,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withOpacity(.9),
                      child: Icon(
                        _fav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty
                        ? (p['tipo']?.toString() ?? 'Publicación')
                        : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  if (location.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 2),
                  if (price.isNotEmpty)
                    Text(
                      '$price CLP / mes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
