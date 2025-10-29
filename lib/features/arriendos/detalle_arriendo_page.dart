import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:smartrent_plus/data/services/property_service.dart';
import 'package:smartrent_plus/features/arriendos/widgets/formulario_reserva.dart';

class DetalleArriendoPage extends StatefulWidget {
  final String propertyId;
  const DetalleArriendoPage({super.key, required this.propertyId});

  @override
  State<DetalleArriendoPage> createState() => _DetalleArriendoPageState();
}

class _DetalleArriendoPageState extends State<DetalleArriendoPage> {
  final _svc = PropertyService();
  Map<String, dynamic>? _p;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _svc.getById(widget.propertyId);
      if (!mounted) return;
      setState(() {
        _p = d;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar el detalle')),
      );
    }
  }

  Future<void> _contactWhatsApp() async {
    final phone = _p?['ownerPhone']?.toString();
    if (phone == null || phone.isEmpty) return;
    final m = Uri.encodeComponent('Hola, me interesa: ${_p?['title'] ?? ''}');
    final url = 'https://wa.me/$phone?text=$m';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final p = _p!;
    final image = p['image_url'] ?? p['imageUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text((p['title'] ?? 'Detalle').toString())),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _contactWhatsApp,
        icon: const Icon(Icons.chat),
        label: const Text('WhatsApp'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(p['price'] ?? 0)} CLP / mes',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${p['type'] ?? ''} • ${p['category'] ?? ''} • ${p['location'] ?? ''}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const Divider(height: 24),

            // descripción segura (sin if suelto)
            (p['description'] != null && p['description'].toString().isNotEmpty)
                ? Text(
                    p['description'].toString(),
                    textAlign: TextAlign.justify,
                  )
                : const SizedBox.shrink(),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipInfo(
                  icon: Icons.square_foot,
                  label: '${p['area'] ?? '-'} m²',
                ),
                _ChipInfo(
                  icon: Icons.bed,
                  label: '${p['bedrooms'] ?? '-'} dorm',
                ),
                _ChipInfo(
                  icon: Icons.shower,
                  label: '${p['bathrooms'] ?? '-'} baños',
                ),
                if (p['year'] != null)
                  _ChipInfo(
                    icon: Icons.calendar_month,
                    label: 'Año ${p['year']}',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Reservar'),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => FormularioReservaMap(propiedad: p),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Ver en mapa'),
              onPressed: () {
                final lat = p['latitude']?.toString();
                final lng = p['longitude']?.toString();
                if (lat == null || lng == null) return;
                final url =
                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                launchUrlString(url, mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ChipInfo({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
