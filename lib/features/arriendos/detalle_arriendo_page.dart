import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:smartrent_plus/data/services/property_service.dart';
import 'package:smartrent_plus/features/arriendos/widgets/formulario_reserva.dart';

// Media
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// Mapa
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  // video
  VideoPlayerController? _v;
  ChewieController? _chewie;

  // -------- helpers básicos --------
  String _s(dynamic v) => (v ?? '').toString();
  num _n(dynamic v) => (v is num) ? v : (num.tryParse(_s(v)) ?? 0);
  bool _has(dynamic v) => _s(v).trim().isNotEmpty;
  bool _isHttp(String u) => u.startsWith('http://') || u.startsWith('https://');
  bool _isFile(String u) =>
      u.startsWith('file:/') || (!u.contains('://') && u.isNotEmpty);

  String? _pickVideo(Map<String, dynamic> p) {
    final list = <dynamic>[
      p['video_url'], p['videoUrl'],
      (p['videos'] is List && (p['videos'] as List).isNotEmpty)
          ? (p['videos'] as List).first
          : null,
      // a veces guardan en meta
      (p['meta'] is String ? jsonDecode(p['meta']) : p['meta'])?['video'],
      (p['metadata'] is String
          ? jsonDecode(p['metadata'])
          : p['metadata'])?['video'],
    ].map((e) => e?.toString()).where((e) => (e ?? '').isNotEmpty).toList();
    return list.isEmpty ? null : list.first;
  }

  List<String> _pickImages(Map<String, dynamic> p) {
    final out = <String>[];
    void add(dynamic v) {
      final s = v?.toString() ?? '';
      if (s.isNotEmpty) out.add(s);
    }

    add(p['image_url']);
    add(p['imageUrl']);
    add(p['imagen']);
    if (p['images'] is List) for (final v in (p['images'] as List)) add(v);
    if (p['media'] is List) for (final v in (p['media'] as List)) add(v);

    // meta/metadata pueden traer arrays
    final meta = p['meta'] is String ? jsonDecode(p['meta']) : p['meta'];
    final metadata = p['metadata'] is String
        ? jsonDecode(p['metadata'])
        : p['metadata'];
    for (final m in [meta, metadata]) {
      if (m is Map && m['images'] is List) {
        for (final v in (m['images'] as List)) add(v);
      }
    }
    return out;
  }

  Map<String, dynamic> _mergedMeta(Map<String, dynamic> p) {
    final meta = p['meta'] is String
        ? (jsonDecode(p['meta']) as Map)
        : (p['meta'] as Map?);
    final metadata = p['metadata'] is String
        ? (jsonDecode(p['metadata']) as Map)
        : (p['metadata'] as Map?);
    final extras = p['extras'] is String
        ? (jsonDecode(p['extras']) as Map)
        : (p['extras'] as Map?);
    final out = <String, dynamic>{};
    for (final m in [meta, metadata, extras]) {
      if (m is Map) out.addAll(Map<String, dynamic>.from(m));
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _v?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final d = await _svc.getById(widget.propertyId);
      if (!mounted) return;
      _p = d;
      _loading = false;

      final v = _pickVideo(d);
      if (v != null) {
        if (_isHttp(v)) {
          _v = VideoPlayerController.networkUrl(Uri.parse(v));
        } else if (_isFile(v)) {
          final path = v.startsWith('file:/') ? Uri.parse(v).toFilePath() : v;
          _v = VideoPlayerController.file(File(path));
        }
        if (_v != null) {
          await _v!.initialize();
          _chewie = ChewieController(videoPlayerController: _v!);
        }
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      _loading = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar el detalle')),
      );
    }
  }

  // -------- contacto --------
  Future<void> _contactWhatsApp() async {
    final phoneRaw =
        _p?['ownerPhone'] ?? _p?['whatsapp'] ?? _p?['contactPhone'];
    final phone = _s(phoneRaw).replaceAll(RegExp(r'[^0-9]+'), '');
    if (phone.isEmpty) return;
    final m = Uri.encodeComponent(
      'Hola, me interesa: ${_s(_p?['title'] ?? _p?['titulo'])}',
    );
    final url = 'https://wa.me/$phone?text=$m';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  // -------- media widgets --------
  Widget _videoOrGallery() {
    final p = _p!;
    final imgs = _pickImages(p);

    if (_chewie != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewie!),
      );
    }

    if (imgs.isEmpty) {
      return Container(
        height: 220,
        color: const Color(0xFFE9ECF1),
        child: const Icon(Icons.image_not_supported, size: 48),
      );
    }

    return _Gallery(images: imgs);
  }

  bool get _hasLatLng {
    final lat = _n(_p?['latitude'] ?? _p?['lat']);
    final lng = _n(_p?['longitude'] ?? _p?['lng'] ?? _p?['lon']);
    return lat != 0 && lng != 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_p == null) {
      return const Scaffold(
        body: Center(child: Text('Publicación no encontrada')),
      );
    }

    final p = _p!;
    final titulo = _s(p['title'] ?? p['titulo'] ?? 'Detalle');
    final precio = _s(p['price'] ?? p['precio']);
    final direccion = _s(p['address'] ?? p['direccion']);
    final ubic = _s(p['location'] ?? p['ubicacion'] ?? p['comuna']);
    final tipo = _s(p['type'] ?? p['tipo']).toLowerCase();
    final esVehiculo =
        tipo.contains('vehic') ||
        tipo.contains('auto') ||
        tipo.contains('moto');
    final esInmueble = !esVehiculo;

    // meta/metadata/extra combinados
    final meta = _mergedMeta(p);

    // amenities / servicios / características
    final amenities = <String>{
      ...(_toStringList(p['amenities'])),
      ...(_toStringList(p['servicios'])),
      ...(_toStringList(p['features'])),
      ...(_toStringList(meta['amenities'])),
      ...(_toStringList(meta['servicios'])),
      ...(_toStringList(meta['features'])),
    }.toList();

    // costos/condiciones/horarios/reglas
    final precioPeriodo = _s(
      p['precio_periodo'] ?? meta['precio_periodo'] ?? meta['periodo'],
    );
    final garantia = _s(
      p['garantia'] ?? p['deposito'] ?? meta['garantia'] ?? meta['deposito'],
    );
    final costosExtra = _s(p['costos_extra'] ?? meta['costos_extra']);
    final hInicio = _s(p['horario_inicio'] ?? meta['horario_inicio']);
    final hFin = _s(p['horario_fin'] ?? meta['horario_fin']);
    final reglas = _s(
      p['reglas'] ?? meta['reglas'] ?? p['normas'] ?? meta['normas'],
    );
    final politicas = _s(p['politicas'] ?? meta['politicas']);

    // contacto
    final empresa = _s(p['companyName'] ?? p['empresa'] ?? meta['companyName']);
    final contacto = _s(p['contactName'] ?? meta['contactName']);
    final fono = _s(
      p['contactPhone'] ??
          p['whatsapp'] ??
          meta['contactPhone'] ??
          meta['whatsapp'],
    );
    final email = _s(p['contactEmail'] ?? meta['contactEmail']);
    final web = _s(p['website'] ?? meta['website']);

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      floatingActionButton: (_has(fono))
          ? FloatingActionButton.extended(
              onPressed: _contactWhatsApp,
              icon: const Icon(Icons.chat),
              label: const Text('WhatsApp'),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _videoOrGallery(),
            ),
            const SizedBox(height: 12),

            if (_has(precio))
              Text(
                '$precio CLP / mes',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            if (_has(ubic))
              Text(ubic, style: TextStyle(color: Colors.grey[700])),
            if (_has(direccion))
              Text(direccion, style: TextStyle(color: Colors.grey[600])),
            const Divider(height: 24),

            // descripción
            if (_has(p['description'] ?? p['descripcion']))
              Text(
                _s(p['description'] ?? p['descripcion']),
                textAlign: TextAlign.justify,
              ),

            const SizedBox(height: 16),

            // ---------- ESPECIFICACIONES ----------
            Text(
              'Especificaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (esInmueble && _n(p['area']) > 0)
                  _ChipInfo(
                    icon: Icons.square_foot,
                    label: '${_n(p["area"])} m²',
                  ),
                if (esInmueble && _n(p['bedrooms'] ?? p['dormitorios']) > 0)
                  _ChipInfo(
                    icon: Icons.bed,
                    label: '${_n(p["bedrooms"] ?? p["dormitorios"])} dorm',
                  ),
                if (esInmueble && _n(p['bathrooms'] ?? p['banos']) > 0)
                  _ChipInfo(
                    icon: Icons.shower,
                    label: '${_n(p["bathrooms"] ?? p["banos"])} baños',
                  ),
                if (p['year'] != null)
                  _ChipInfo(
                    icon: Icons.calendar_month,
                    label: 'Año ${_s(p["year"])}',
                  ),

                // Vehículos
                if (esVehiculo && _has(p['brand'] ?? p['marca']))
                  _ChipInfo(
                    icon: Icons.directions_car_filled,
                    label: _s(p['brand'] ?? p['marca']),
                  ),
                if (esVehiculo && _has(p['model'] ?? p['modelo']))
                  _ChipInfo(
                    icon: Icons.badge,
                    label: _s(p['model'] ?? p['modelo']),
                  ),
                if (esVehiculo && _has(p['fuel'] ?? p['combustible']))
                  _ChipInfo(
                    icon: Icons.local_gas_station,
                    label: _s(p['fuel'] ?? p['combustible']),
                  ),
                if (esVehiculo && _has(p['transmission'] ?? p['transmision']))
                  _ChipInfo(
                    icon: Icons.settings,
                    label: _s(p['transmission'] ?? p['transmision']),
                  ),
                if (esVehiculo && _n(p['seats'] ?? p['asientos']) > 0)
                  _ChipInfo(
                    icon: Icons.event_seat,
                    label: '${_n(p["seats"] ?? p["asientos"])} asientos',
                  ),

                // Campos comunes desde meta
                if (_n(meta['capacidad']) > 0)
                  _ChipInfo(
                    icon: Icons.groups,
                    label: 'Capacidad ${_n(meta["capacidad"])}',
                  ),
                if (_has(meta['deporte']))
                  _ChipInfo(icon: Icons.sports, label: _s(meta['deporte'])),
                if (_has(meta['superficie']))
                  _ChipInfo(icon: Icons.texture, label: _s(meta['superficie'])),
                if (_has(meta['iluminacion']))
                  _ChipInfo(
                    icon: Icons.light_mode,
                    label: _s(meta['iluminacion']),
                  ),
                if (_has(meta['categoria']))
                  _ChipInfo(icon: Icons.category, label: _s(meta['categoria'])),
              ],
            ),

            const SizedBox(height: 16),

            // ---------- AMENITIES / SERVICIOS ----------
            if (amenities.isNotEmpty) ...[
              Text(
                'Servicios y características',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: amenities.map((e) => Chip(label: Text(e))).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // ---------- COSTOS / CONDICIONES ----------
            if (_has(precioPeriodo) || _has(garantia) || _has(costosExtra)) ...[
              Text(
                'Condiciones',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_has(precioPeriodo))
                _InfoRow(icon: Icons.schedule, text: 'Periodo: $precioPeriodo'),
              if (_has(garantia))
                _InfoRow(
                  icon: Icons.security,
                  text: 'Garantía/Depósito: $garantia',
                ),
              if (_has(costosExtra))
                _InfoRow(
                  icon: Icons.price_change,
                  text: 'Costos extra: $costosExtra',
                ),
              const SizedBox(height: 16),
            ],

            // ---------- HORARIOS ----------
            if (_has(hInicio) || _has(hFin)) ...[
              Text('Horarios', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.access_time,
                text:
                    '${_has(hInicio) ? 'Inicio: $hInicio' : ''}'
                    '${_has(hInicio) && _has(hFin) ? ' · ' : ''}'
                    '${_has(hFin) ? 'Fin: $hFin' : ''}',
              ),
              const SizedBox(height: 16),
            ],

            // ---------- REGLAS / POLÍTICAS ----------
            if (_has(reglas) || _has(politicas)) ...[
              Text(
                'Reglas y políticas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_has(reglas)) _BulletText(text: reglas),
              if (_has(politicas)) _BulletText(text: politicas),
              const SizedBox(height: 16),
            ],

            // ---------- MAPA ----------
            if (_hasLatLng) ...[
              Text('Ubicación', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        _n(_p!['latitude'] ?? _p!['lat']).toDouble(),
                        _n(
                          _p!['longitude'] ?? _p!['lng'] ?? _p!['lon'],
                        ).toDouble(),
                      ),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'smartrent_plus',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              _n(_p!['latitude'] ?? _p!['lat']).toDouble(),
                              _n(
                                _p!['longitude'] ?? _p!['lng'] ?? _p!['lon'],
                              ).toDouble(),
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Abrir en Google Maps'),
                onPressed: () {
                  final lat = _s(_p!['latitude'] ?? _p!['lat']);
                  final lng = _s(_p!['longitude'] ?? _p!['lng'] ?? _p!['lon']);
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                  launchUrlString(url, mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 16),
            ],

            // ---------- CONTACTO ----------
            Text(
              'Contacto del anunciante',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_has(empresa)) _InfoRow(icon: Icons.business, text: empresa),
            if (_has(contacto)) _InfoRow(icon: Icons.person, text: contacto),
            if (_has(fono)) _InfoRow(icon: Icons.phone, text: fono),
            if (_has(email))
              InkWell(
                onTap: () => launchUrlString('mailto:$email'),
                child: _InfoRow(icon: Icons.email, text: email),
              ),
            if (_has(web))
              InkWell(
                onTap: () =>
                    launchUrlString(web, mode: LaunchMode.externalApplication),
                child: _InfoRow(icon: Icons.link, text: web),
              ),

            const SizedBox(height: 16),

            // ---------- CTA RESERVA ----------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Reservar'),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => FormularioReservaMap(propiedad: p),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<String> _toStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => _s(e)).where((e) => e.isNotEmpty).toList();
    }
    if (v is String && v.trim().isNotEmpty) {
      // permitir "wifi,estacionamiento,mascotas"
      return v
          .split(RegExp(r'[;,]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText({required this.text});
  @override
  Widget build(BuildContext context) {
    final items = text
        .split(RegExp(r'\n|;'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (items.length <= 1) return Text(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(e)),
                ],
              ),
            ),
          )
          .toList(),
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

class _Gallery extends StatefulWidget {
  final List<String> images;
  const _Gallery({required this.images});

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _i = 0;

  bool _isHttp(String u) => u.startsWith('http://') || u.startsWith('https://');
  bool _isFile(String u) =>
      u.startsWith('file:/') || (!u.contains('://') && u.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (v) => setState(() => _i = v),
            itemBuilder: (_, idx) {
              final url = widget.images[idx];
              if (_isHttp(url)) {
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ph(),
                );
              }
              if (_isFile(url)) {
                final path = url.startsWith('file:/')
                    ? Uri.parse(url).toFilePath()
                    : url;
                return Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ph(),
                );
              }
              return _ph();
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (j) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _i == j ? Colors.blue : Colors.black26,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ph() => Container(
    color: const Color(0xFFE9ECF1),
    child: const Icon(Icons.broken_image_outlined),
  );
}
