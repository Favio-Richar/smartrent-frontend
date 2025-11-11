// ===============================================================
// SmartRent+ · CardPropiedadMap (v4 estable)
// - Miniatura real de video (video_thumbnail)
// - Ícono 📹 si hay video
// - 100% compatible Flutter 3.24+
// ===============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartrent_plus/core/utils/constants.dart';
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
  String? _videoThumb;

  @override
  void initState() {
    super.initState();
    _fav = (widget.data['is_favorite'] ?? widget.data['isFavorite'] ?? false) ==
        true;
    _generateVideoThumb();
  }

  Future<void> _generateVideoThumb() async {
    final vid = _pickVideo(widget.data);
    if (vid.isEmpty) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: vid,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        quality: 50,
      );
      if (thumbPath != null && mounted) {
        setState(() => _videoThumb = thumbPath);
      }
    } catch (e) {
      debugPrint('⚠️ Error generando miniatura: $e');
    }
  }

  Future<void> _toggleFav() async {
    final id = (widget.data['id'] ??
            widget.data['propertyId'] ??
            widget.data['property_id'] ??
            '')
        .toString();
    if (id.isEmpty) return;
    final ok = await _svc.toggleFavorite(id);
    if (ok && mounted) setState(() => _fav = !_fav);
  }

  String _s(dynamic v) => (v ?? '').toString();
  bool _isHttp(String u) => u.startsWith('http://') || u.startsWith('https://');
  bool _isFile(String u) => u.startsWith('file:/');
  String _abs(String? raw) => ApiConstants.media(_s(raw));

  /// Obtiene primera imagen disponible
  String _pickImage(Map<String, dynamic> p) {
    if (p['images'] is List && (p['images'] as List).isNotEmpty) {
      return _abs((p['images'] as List).first);
    }
    for (final k in ['image_url', 'imageUrl', 'imagen', '_thumb']) {
      final v = _s(p[k]);
      if (v.isNotEmpty) return _abs(v);
    }
    if (p['_images'] is List && (p['_images'] as List).isNotEmpty) {
      return _abs((p['_images'] as List).first);
    }
    if (p['media'] is List && (p['media'] as List).isNotEmpty) {
      return _abs((p['media'] as List).first);
    }
    return '';
  }

  /// Obtiene primer video disponible
  String _pickVideo(Map<String, dynamic> p) {
    if (p['videos'] is List && (p['videos'] as List).isNotEmpty) {
      return _abs((p['videos'] as List).first);
    }
    final v = _s(p['video_url'] ?? p['videoUrl']);
    return v.isNotEmpty ? _abs(v) : '';
  }

  Widget _mediaPreview(String img, String vid) {
    if (img.isNotEmpty) return _thumbWidget(img, false, vid.isNotEmpty);
    if (vid.isNotEmpty) return _thumbWidget(_videoThumb ?? vid, true, true);
    return _placeholder();
  }

  Widget _thumbWidget(String url, bool isVideo, bool hasVideo) {
    Widget content;
    if (_isHttp(url)) {
      content = Image.network(url,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
    } else if (_isFile(url)) {
      final path = url.startsWith('file:/') ? Uri.parse(url).toFilePath() : url;
      content = Image.file(File(path),
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
    } else {
      content = _placeholder();
    }

    return Stack(
      children: [
        Positioned.fill(child: content),
        if (hasVideo)
          Positioned(
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.videocam, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
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
    final location =
        _s(p['location'] ?? p['ubicacion'] ?? p['ciudad'] ?? p['comuna']);
    final img = _pickImage(p);
    final vid = _pickVideo(p);

    return GestureDetector(
      onTap: () {
        if (id.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DetalleArriendoPage(propertyId: id)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        elevation: 2.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              AspectRatio(aspectRatio: 16 / 10, child: _mediaPreview(img, vid)),
              Positioned(
                right: 8,
                top: 8,
                child: InkWell(
                  onTap: _toggleFav,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withAlpha(230),
                    child: Icon(
                      _fav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ]),
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
                    Text('$price CLP / mes',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFEFEFEF),
        child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.black38)),
      );
}
