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
    final id = (widget.data['id'] ?? '').toString();
    if (id.isEmpty) return;
    final ok = await _svc.toggleFavorite(id);
    if (ok) setState(() => _fav = !_fav);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.data;

    // ✅ Soporta Prisma (titulo/precio/imagen/ubicacion) y variantes
    final id = (p['id'] ?? '').toString();
    final title = (p['title'] ?? p['titulo'] ?? p['nombre'] ?? '').toString();
    final priceRaw = (p['price'] ?? p['precio'] ?? 0);
    final price = (priceRaw is num)
        ? priceRaw.toStringAsFixed(0)
        : priceRaw.toString();
    final image = (p['image_url'] ?? p['imageUrl'] ?? p['imagen'] ?? '')
        .toString();
    final location = (p['location'] ?? p['ubicacion'] ?? p['ciudad'] ?? '')
        .toString();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetalleArriendoPage(propertyId: id)),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        elevation: 2.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const ColoredBox(color: Color(0xFFEFEFEF)),
                        )
                      : const ColoredBox(color: Color(0xFFEFEFEF)),
                ),
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
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
