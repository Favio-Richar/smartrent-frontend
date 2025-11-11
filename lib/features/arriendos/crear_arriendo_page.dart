// lib/features/arriendos/crear_arriendo_page.dart
// ===============================================================
// SmartRent+ · Crear/Editar Arriendo (vista empresarial)
// Mantiene contratos/rutas. Incluye políticas dinámicas, preview video,
// geocodificación y mapa (flutter_map v6: TileLayer sin const).
// Fixes:
// - Guardado usa PropertyService.create/update con images (sin *Multipart*).
// - Geocoding robusto, preview video (YouTube/MP4/local).
// - Quita localeIdentifier (error undefined_named_parameter) y limpia cast.
// ===============================================================
import 'package:smartrent_plus/data/services/uploads_service.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartrent_plus/core/utils/number_utils.dart';
import 'package:smartrent_plus/core/utils/validators.dart';
import 'package:smartrent_plus/data/services/property_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ====== MEDIA / MAPA ======
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class CrearArriendoPage extends StatefulWidget {
  final String? editId;
  const CrearArriendoPage({super.key, this.editId});

  @override
  State<CrearArriendoPage> createState() => _CrearArriendoPageState();
}

class _CrearArriendoPageState extends State<CrearArriendoPage>
    with TickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _svc = PropertyService();

  int _currentStep = 0;
  late final _stepperCtrl = PageController();

  static const List<String> _typesAll = [
    'propiedad',
    'vehiculo',
    'herramienta',
    'oficina',
    'cancha',
    'piscina',
    'terreno',
  ];

  static const Map<String, List<String>> _categorySuggestions = {
    'propiedad': [
      'Departamento',
      'Casa',
      'Loft',
      'Studio',
      'Bodega',
      'Estacionamiento',
    ],
    'vehiculo': ['Sedán', 'SUV', 'Hatchback', 'Pickup', 'Moto', 'Van'],
    'herramienta': ['Taladro', 'Andamio', 'Generador', 'Compresor'],
    'oficina': ['Co-Work', 'Privada', 'Piso completo', 'Oficina amoblada'],
    'cancha': ['Fútbol 7', 'Fútbol 11', 'Pádel', 'Tenis', 'Básquetbol'],
    'piscina': ['Doméstica', 'Semiolímpica', 'Inflable', 'Jacuzzi'],
    'terreno': ['Residencial', 'Comercial', 'Industrial', 'Agrícola'],
  };

  // Básico
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _category = TextEditingController();
  final _type = ValueNotifier<String>('propiedad');

  // Ubicación
  final _street = TextEditingController();
  final _location = TextEditingController();
  final _comunaCtrl = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();

  // Detalles comunes
  final _area = TextEditingController();
  final _beds = TextEditingController();
  final _baths = TextEditingController();
  final _year = TextEditingController();
  final _videoUrl = TextEditingController();

  // Empresa & contacto
  final _companyName = TextEditingController();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _contactEmail = TextEditingController();
  final _website = TextEditingController();
  final _whatsapp = TextEditingController();

  final _destacado = ValueNotifier<bool>(false);

  // Políticas / servicios base
  final _deposito = TextEditingController();
  final _contratoMeses = TextEditingController();
  final _mascotas = ValueNotifier<bool>(false);
  final _fumar = ValueNotifier<bool>(false);
  final _incAgua = ValueNotifier<bool>(false);
  final _incLuz = ValueNotifier<bool>(false);
  final _incGas = ValueNotifier<bool>(false);
  final _incInternet = ValueNotifier<bool>(false);

  // ====== NUEVO: requisitos extra ======
  final _reqOtros = TextEditingController();
  final _diasMin = TextEditingController();
  final _politicaCancel = TextEditingController();
  final _reqSelected = ValueNotifier<Set<String>>({});

  static const List<String> _reqUniversales = [
    'Documento de identidad (RUT/ID)',
    'Comprobante de domicilio',
    'Medio de pago verificado',
    'Firma de contrato',
  ];
  static const Map<String, List<String>> _reqPorTipo = {
    'vehiculo': [
      'Licencia de conducir vigente',
      'Edad mínima 21+',
      'Garantía reembolsable',
      'Sin multas/partes pendientes',
    ],
    'herramienta': [
      'Garantía reembolsable',
      'Experiencia/uso responsable',
      'Devolución en buen estado',
    ],
    'propiedad': [
      'Informe comercial (opcional)',
      'Renta comprobable',
      'Mes de garantía',
    ],
    'oficina': ['RUT empresa / Giro', 'Contrato mínimo 3 meses'],
    'cancha': ['Pago anticipado', 'Respeto a normas del recinto'],
    'piscina': ['Pago anticipado', 'Respeto a normas de seguridad'],
    'terreno': ['Uso permitido según zonificación', 'Garantía reembolsable'],
  };

  // Media
  final List<File> _images = [];
  String? _remoteImage;
  File? _localVideo;

  List<String> _tipos = const [];
  List<String> _comunas = const [];

  bool _saving = false;
  bool _loadingData = true;

  // Vehículo
  final _vehMarca = TextEditingController();
  final _vehModelo = TextEditingController();
  final _vehKm = TextEditingController();
  final _vehTransmision = ValueNotifier<String?>('Automática');
  final _vehCombustible = ValueNotifier<String?>('Gasolina');

  // Cancha
  final _canchaDeporte = ValueNotifier<String?>('Fútbol 7');
  final _canchaSuperficie = ValueNotifier<String?>('Pasto sintético');
  final _canchaTechada = ValueNotifier<bool>(false);
  final _canchaIluminacion = ValueNotifier<bool>(true);
  final _canchaCapacidad = TextEditingController();
  final _canchaHorario = TextEditingController();

  // Piscina
  final _piscinaLargo = TextEditingController();
  final _piscinaAncho = TextEditingController();
  final _piscinaProfundidad = TextEditingController();
  final _piscinaClimatizada = ValueNotifier<bool>(false);
  final _piscinaInterior = ValueNotifier<bool>(false);

  // Herramienta
  final _herrNombre = TextEditingController();
  final _herrCondicion = ValueNotifier<String?>('Nueva');
  final _herrGarantia = TextEditingController();
  final _herrEntrega = ValueNotifier<String?>('Retiro en tienda');

  // Terreno
  final _terrUso = ValueNotifier<String?>('Residencial');
  final _terrAgua = ValueNotifier<bool>(false);
  final _terrLuz = ValueNotifier<bool>(false);

  // Oficina
  final _ofiM2 = TextEditingController();
  final _ofiAmoblada = ValueNotifier<bool>(false);
  final _ofiSalas = TextEditingController();
  final _ofiEstacionamientos = TextEditingController();

  // Mapa
  LatLng? _point;

  @override
  void initState() {
    super.initState();
    _boot();

    _type.addListener(() {
      _category.clear();
      setState(() {});
    });

    _videoUrl.addListener(() => setState(() {}));
    _lat.addListener(() => _syncPointFromLatLng());
    _lng.addListener(() => _syncPointFromLatLng());
  }

  Future<void> _boot() async {
    try {
      final results = await Future.wait([_svc.getTipos(), _svc.getComunas()]);
      final list0 = (results[0] as List?) ?? const [];
      final back = list0.map((e) => '$e'.toLowerCase()).toList();
      _tipos = {..._typesAll, ...back}.toList();
      _comunas = (results[1] as List).map((e) => '$e').toList();
      if (widget.editId != null) await _loadEdit();
    } catch (_) {
      _tipos = List.from(_typesAll);
    } finally {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  Future<void> _loadEdit() async {
    final p = await _svc.getById(widget.editId!);

    _title.text = _s(p['title'] ?? p['titulo']);
    _price.text = _s(p['price'] ?? p['precio']);
    _desc.text = _s(p['description'] ?? p['descripcion']);
    _type.value = _s(p['type'] ?? p['tipo']).isEmpty
        ? 'propiedad'
        : _s(p['type'] ?? p['tipo']);
    _category.text = _s(p['category'] ?? p['categoria']);

    _street.text = _s(p['street']);
    _location.text = _s(p['location'] ?? p['ubicacion']);
    _comunaCtrl.text = _s(p['comuna']);
    _lat.text = _s(p['latitude']);
    _lng.text = _s(p['longitude']);

    _area.text = _s(p['area']);
    _beds.text = _s(p['bedrooms'] ?? p['dormitorios']);
    _baths.text = _s(p['bathrooms'] ?? p['banos']);
    _year.text = _s(p['year'] ?? p['anio']);
    _videoUrl.text = _s(p['video_url'] ?? p['videoUrl']);

    final meta = (p['metadata'] as Map?) ?? {};
    _hydrateMeta(meta);

    _companyName.text = _s(p['companyName']);
    _contactName.text = _s(p['contactName']);
    _contactPhone.text = _s(p['phone'] ?? p['contactPhone']);
    _contactEmail.text = _s(p['email'] ?? p['contactEmail']);
    _website.text = _s(p['website']);
    _whatsapp.text = _s(p['whatsapp']);

    _destacado.value = (p['featured'] ?? p['destacado'] ?? false) == true;
    _remoteImage = _s(p['image_url'] ?? p['imageUrl']);

    _syncPointFromLatLng();
  }

  void _hydrateMeta(Map meta) {
    // Vehículo
    _vehMarca.text = _s(meta['veh_marca']);
    _vehModelo.text = _s(meta['veh_modelo']);
    _vehKm.text = _s(meta['veh_km']);
    _vehTransmision.value = meta['veh_transmision'] ?? _vehTransmision.value;
    _vehCombustible.value = meta['veh_combustible'] ?? _vehCombustible.value;

    // Cancha
    _canchaDeporte.value = meta['cancha_deporte'] ?? _canchaDeporte.value;
    _canchaSuperficie.value =
        meta['cancha_superficie'] ?? _canchaSuperficie.value;
    _canchaTechada.value =
        (meta['cancha_techada'] ?? _canchaTechada.value) == true;
    _canchaIluminacion.value =
        (meta['cancha_iluminacion'] ?? _canchaIluminacion.value) == true;
    _canchaCapacidad.text = _s(meta['cancha_capacidad']);
    _canchaHorario.text = _s(meta['cancha_horario']);

    // Piscina
    _piscinaLargo.text = _s(meta['pisc_largo']);
    _piscinaAncho.text = _s(meta['pisc_ancho']);
    _piscinaProfundidad.text = _s(meta['pisc_prof']);
    _piscinaClimatizada.value =
        (meta['pisc_clima'] ?? _piscinaClimatizada.value) == true;
    _piscinaInterior.value =
        (meta['pisc_inter'] ?? _piscinaInterior.value) == true;

    // Herramienta
    _herrNombre.text = _s(meta['herr_nombre']);
    _herrCondicion.value = meta['herr_cond'] ?? _herrCondicion.value;
    _herrGarantia.text = _s(meta['herr_garantia']);
    _herrEntrega.value = meta['herr_entrega'] ?? _herrEntrega.value;

    // Terreno
    _terrUso.value = meta['terr_uso'] ?? _terrUso.value;
    _terrAgua.value = (meta['terr_agua'] ?? _terrAgua.value) == true;
    _terrLuz.value = (meta['terr_luz'] ?? _terrLuz.value) == true;

    // Oficina
    _ofiM2.text = _s(meta['ofi_m2']);
    _ofiAmoblada.value = (meta['ofi_amobl'] ?? _ofiAmoblada.value) == true;
    _ofiSalas.text = _s(meta['ofi_salas']);
    _ofiEstacionamientos.text = _s(meta['ofi_est']);

    // Base políticas
    _deposito.text = _s(meta['dep_monto']);
    _contratoMeses.text = _s(meta['contrato_meses']);
    _mascotas.value = (meta['mascotas'] ?? false) == true;
    _fumar.value = (meta['fumar'] ?? false) == true;
    _incAgua.value = (meta['inc_agua'] ?? false) == true;
    _incLuz.value = (meta['inc_luz'] ?? false) == true;
    _incGas.value = (meta['inc_gas'] ?? false) == true;
    _incInternet.value = (meta['inc_internet'] ?? false) == true;

    // Requisitos extra
    final reqList = (meta['req'] as List?)?.map((e) => '$e').toSet() ?? {};
    _reqSelected.value = reqList;
    _reqOtros.text = _s(meta['req_otros']);
    _diasMin.text = _s(meta['dias_min']);
    _politicaCancel.text = _s(meta['politica_cancel']);
  }

  Map<String, dynamic> _collectMetadata() {
    final base = <String, dynamic>{
      'street': _optText(_street),
      'dep_monto': NumberUtils.toDoubleSafe(_deposito.text),
      'contrato_meses': NumberUtils.toIntSafe(_contratoMeses.text),
      'mascotas': _mascotas.value,
      'fumar': _fumar.value,
      'inc_agua': _incAgua.value,
      'inc_luz': _incLuz.value,
      'inc_gas': _incGas.value,
      'inc_internet': _incInternet.value,
      'req': _reqSelected.value.isEmpty ? null : _reqSelected.value.toList(),
      'req_otros': _optText(_reqOtros),
      'dias_min': NumberUtils.toIntSafe(_diasMin.text),
      'politica_cancel': _optText(_politicaCancel),
    };

    switch (_type.value) {
      case 'vehiculo':
        base.addAll({
          'veh_marca': _optText(_vehMarca),
          'veh_modelo': _optText(_vehModelo),
          'veh_km': NumberUtils.toIntSafe(_vehKm.text),
          'veh_transmision': _vehTransmision.value,
          'veh_combustible': _vehCombustible.value,
        });
        break;
      case 'cancha':
        base.addAll({
          'cancha_deporte': _canchaDeporte.value,
          'cancha_superficie': _canchaSuperficie.value,
          'cancha_techada': _canchaTechada.value,
          'cancha_iluminacion': _canchaIluminacion.value,
          'cancha_capacidad': NumberUtils.toIntSafe(_canchaCapacidad.text),
          'cancha_horario': _optText(_canchaHorario),
        });
        break;
      case 'piscina':
        base.addAll({
          'pisc_largo': NumberUtils.toDoubleSafe(_piscinaLargo.text),
          'pisc_ancho': NumberUtils.toDoubleSafe(_piscinaAncho.text),
          'pisc_prof': NumberUtils.toDoubleSafe(_piscinaProfundidad.text),
          'pisc_clima': _piscinaClimatizada.value,
          'pisc_inter': _piscinaInterior.value,
        });
        break;
      case 'herramienta':
        base.addAll({
          'herr_nombre': _optText(_herrNombre),
          'herr_cond': _herrCondicion.value,
          'herr_garantia': _optText(_herrGarantia),
          'herr_entrega': _herrEntrega.value,
        });
        break;
      case 'terreno':
        base.addAll({
          'terr_uso': _terrUso.value,
          'terr_agua': _terrAgua.value,
          'terr_luz': _terrLuz.value,
        });
        break;
      case 'oficina':
        base.addAll({
          'ofi_m2': NumberUtils.toIntSafe(_ofiM2.text),
          'ofi_amobl': _ofiAmoblada.value,
          'ofi_salas': NumberUtils.toIntSafe(_ofiSalas.text),
          'ofi_est': NumberUtils.toIntSafe(_ofiEstacionamientos.text),
        });
        break;
    }

    base.removeWhere((k, v) => v == null || v == '');
    return base;
  }

  String _s(dynamic v) => (v == null) ? '' : '$v';
  String? _optText(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  // -------------------- Media (fotos) --------------------
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final list = await picker.pickMultiImage(imageQuality: 85);
    if (list.isEmpty) return;
    setState(() {
      _images.addAll(list.map((x) => File(x.path)));
      _remoteImage = null;
    });
  }

  // -------------------- Validadores --------------------
  String? _reqIfPropiedad(String? v) {
    if (!(_type.value == 'propiedad' ||
        _type.value == 'terreno' ||
        _type.value == 'oficina')) {
      return null;
    }
    return (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;
  }

  String? _reqIfVehiculo(String? v) {
    if (_type.value != 'vehiculo') return null;
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    final n = NumberUtils.toIntSafe(v);
    return (n == null || n < 1900) ? 'Año inválido' : null;
  }

  // -------------------- Helpers --------------------
  String _waLink() {
    final phone = _whatsapp.text.replaceAll(RegExp(r'[^0-9+]'), '');
    final msg = Uri.encodeComponent(
      'Hola, vi tu anuncio "${_title.text.trim()}" en SmartRent+ y me interesa.',
    );
    if (phone.isEmpty) return '';
    return 'https://wa.me/$phone?text=$msg';
  }

  Future<void> _openMaps() async {
    final lat = NumberUtils.toDoubleSafe(_lat.text);
    final lng = NumberUtils.toDoubleSafe(_lng.text);
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _title.text.trim(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _category.text.isEmpty ? _cap(_type.value) : _category.text,
                ),
                trailing: Text(
                  '\$${NumberUtils.toDoubleSafe(_price.text)?.toStringAsFixed(0) ?? '0'} CLP',
                ),
              ),
              if (_images.isNotEmpty || (_remoteImage?.isNotEmpty ?? false))
                _MediaPreview(images: _images, remoteImage: _remoteImage),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('${_street.text} ${_comunaCtrl.text}'.trim()),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_desc.text.trim()),
              ),
              if (_videoUrl.text.trim().isNotEmpty || _localVideo != null) ...[
                const SizedBox(height: 12),
                _videoPreview(_videoUrl.text.trim()),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    return {
      "title": _title.text.trim(),
      "price": NumberUtils.toDoubleSafe(_price.text) ?? 0.0,
      "description": _desc.text.trim(),
      "type": _type.value,
      "category": _category.text.trim(),
      "location": _location.text.trim(),
      "comuna": _optText(_comunaCtrl),
      "latitude": NumberUtils.toDoubleSafe(_lat.text),
      "longitude": NumberUtils.toDoubleSafe(_lng.text),
      "area": NumberUtils.toIntSafe(_area.text),
      "bedrooms": NumberUtils.toIntSafe(_beds.text),
      "bathrooms": NumberUtils.toIntSafe(_baths.text),
      "year": NumberUtils.toIntSafe(_year.text),
      "video_url": _optText(_videoUrl),
      "featured": _destacado.value,
      "companyName": _optText(_companyName),
      "contactName": _optText(_contactName),
      "phone": _optText(_contactPhone),
      "email": _optText(_contactEmail),
      "website": _optText(_website),
      "whatsapp": _optText(_whatsapp),
      // Si no adjuntas archivos y tienes URL remota, irá como image_url.
      "image_url": (_remoteImage?.isNotEmpty ?? false) && _images.isEmpty
          ? _remoteImage
          : null,
      "metadata": {
        ..._collectMetadata(),
        "street": _optText(_street),
        "map_link": (_lat.text.isNotEmpty && _lng.text.isNotEmpty)
            ? 'https://www.google.com/maps?q=${_lat.text},${_lng.text}'
            : null,
        "wa_link": _waLink().isEmpty ? null : _waLink(),
      }..removeWhere((k, v) => v == null || (v is String && v.isEmpty)),
    }..removeWhere((k, v) => v == null);
  }

  // -------------------- Importar / Exportar --------------------
  Future<void> _exportJson() async {
    final data = await _buildPayload();
    final tmp = await getTemporaryDirectory();
    final file = File(
      '${tmp.path}/arriendo_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Ficha de arriendo SmartRent+');
  }

  Future<void> _importJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.single.path!);
    final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    _title.text = _s(map['title']);
    _price.text = _s(map['price']);
    _desc.text = _s(map['description']);
    final t = _s(map['type']).toLowerCase();
    if (_tipos.contains(t)) _type.value = t;
    _category.text = _s(map['category']);

    _street.text = _s(map['metadata']?['street']);
    _location.text = _s(map['location']);
    _comunaCtrl.text = _s(map['comuna']);
    _lat.text = _s(map['latitude']);
    _lng.text = _s(map['longitude']);

    _area.text = _s(map['area']);
    _beds.text = _s(map['bedrooms']);
    _baths.text = _s(map['bathrooms']);
    _year.text = _s(map['year']);
    _videoUrl.text = _s(map['video_url']);

    final meta = (map['metadata'] as Map?) ?? {};
    _hydrateMeta(meta);

    _companyName.text = _s(map['companyName']);
    _contactName.text = _s(map['contactName']);
    _contactPhone.text = _s(map['phone']);
    _contactEmail.text = _s(map['email']);
    _website.text = _s(map['website']);
    _whatsapp.text = _s(map['whatsapp']);

    _destacado.value = (map['featured'] ?? false) == true;

    _syncPointFromLatLng();

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ficha importada')));
  }

  // -------------------- Guardar (CORREGIDO) --------------------
// -------------------- Guardar (CORREGIDO con video) --------------------
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      setState(() {});
      return;
    }

    setState(() => _saving = true);
    try {
      final editing = widget.editId != null;

      // ✅ Subida del video si hay uno local
      if (_localVideo != null) {
        try {
          final uploadedUrl = await UploadsService.uploadVideo(_localVideo!);
          _videoUrl.text = uploadedUrl; // guarda la URL generada por el backend
        } catch (e) {
          debugPrint('Error al subir video: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al subir el video')),
            );
          }
        }
      }

      final payload = await _buildPayload();

      // ✅ Usa los métodos reales del servicio que ya manejan JSON/multipart
      final bool ok = editing
          ? await _svc.update(widget.editId!, payload, images: _images)
          : await _svc.create(payload, images: _images);

      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(editing ? 'Actualizado' : 'Publicado')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No se pudo guardar')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final editing = widget.editId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar arriendo' : 'Crear arriendo'),
        actions: [
          IconButton(
            tooltip: 'Importar JSON',
            onPressed: _importJson,
            icon: const Icon(Icons.file_open_outlined),
          ),
          IconButton(
            tooltip: 'Exportar/Compartir',
            onPressed: _exportJson,
            icon: const Icon(Icons.ios_share_outlined),
          ),
          IconButton(
            tooltip: 'Vista previa',
            onPressed: _showPreview,
            icon: const Icon(Icons.visibility_outlined),
          ),
          IconButton(
            tooltip: 'Agregar fotos',
            onPressed: _pickImages,
            icon: const Icon(Icons.photo_library_rounded),
          ),
        ],
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: PageView(
                controller: _stepperCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _stepBasico(),
                  _stepUbicacion(),
                  _stepDetalles(),
                  _stepPoliticas(),
                  _stepEmpresa(),
                  _stepFotos(),
                  _stepPublicar(),
                ],
              ),
            ),
      bottomNavigationBar: _BottomStepper(
        current: _currentStep,
        total: 7,
        onBack: _currentStep == 0
            ? null
            : () {
                setState(() => _currentStep--);
                _stepperCtrl.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
        onNext: _currentStep == 6
            ? null
            : () {
                setState(() => _currentStep++);
                _stepperCtrl.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
      ),
    );
  }

  // ------------- STEPS -------------
  Widget _stepBasico() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _SectionCard(
          title: 'Básico',
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio (CLP)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Campo obligatorio';
                  return NumberUtils.toDoubleSafe(t) == null
                      ? 'Formato inválido (usa 1234.56)'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tipo de arriendo',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tipos.map((t) {
                    final sel = _type.value == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_cap(t)),
                        selected: sel,
                        avatar: Icon(
                          _iconForType(t),
                          size: 18,
                          color: sel ? Colors.white : null,
                        ),
                        onSelected: (_) => setState(() => _type.value = t),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: _type,
                builder: (_, currentType, __) {
                  final suggestions =
                      _categorySuggestions[currentType] ?? const <String>[];
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    child: _CategoryAutocomplete(
                      controller: _category,
                      suggestions: suggestions,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepUbicacion() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _SectionCard(
          title: 'Ubicación',
          child: Column(
            children: [
              TextFormField(
                controller: _street,
                decoration: const InputDecoration(
                  labelText: 'Calle y número',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: 'Referencia / barrio',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 12),
              _ComunaAutocomplete(all: _comunas, controller: _comunaCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Latitud (opcional)',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lng,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Longitud (opcional)',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Abrir en Google Maps',
                    onPressed: _openMaps,
                    icon: const Icon(Icons.pin_drop_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _geocodeAddress,
                    icon: const Icon(Icons.travel_explore),
                    label: const Text('Buscar en mapa'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _openMaps,
                    icon: const Icon(Icons.directions),
                    label: const Text('Navegar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _miniMap(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepDetalles() {
    return ValueListenableBuilder(
      valueListenable: _type,
      builder: (_, t, __) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SectionCard(
              title: 'Detalles',
              child: Column(
                children: [
                  if (t == 'propiedad' || t == 'terreno' || t == 'oficina') ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _area,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Superficie (m²)',
                              prefixIcon: Icon(Icons.square_foot_outlined),
                            ),
                            validator: _reqIfPropiedad,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _beds,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dormitorios',
                              prefixIcon: Icon(Icons.bed_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _baths,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Baños',
                        prefixIcon: Icon(Icons.bathroom_outlined),
                      ),
                      validator: _reqIfPropiedad,
                    ),
                  ],
                  if (t == 'vehiculo')
                    ..._vehiculoFields()
                  else if (t == 'cancha')
                    ..._canchaFields()
                  else if (t == 'piscina')
                    ..._piscinaFields()
                  else if (t == 'herramienta')
                    ..._herramientaFields()
                  else if (t == 'terreno')
                    ..._terrenoFields()
                  else if (t == 'oficina')
                    ..._oficinaFields(),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Año (si aplica)',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    validator: _reqIfVehiculo,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _videoUrl,
                    decoration: const InputDecoration(
                      labelText: 'Video URL (opcional)',
                      prefixIcon: Icon(Icons.ondemand_video_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _recordVideo,
                        icon: const Icon(Icons.videocam_outlined),
                        label: const Text('Grabar'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _pickVideoFromGallery,
                        icon: const Icon(Icons.video_library_outlined),
                        label: const Text('Subir'),
                      ),
                      const SizedBox(width: 8),
                      if (_localVideo != null ||
                          _videoUrl.text.trim().isNotEmpty)
                        IconButton(
                          tooltip: 'Quitar video',
                          onPressed: _clearVideo,
                          icon: const Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _videoPreview(_videoUrl.text),
                  const SizedBox(height: 6),
                  ValueListenableBuilder(
                    valueListenable: _destacado,
                    builder: (_, v, __) => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: v,
                      onChanged: (x) => _destacado.value = x,
                      title: const Text('Destacado'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ======================= POLÍTICAS DINÁMICAS =======================
  Widget _stepPoliticas() {
    return ValueListenableBuilder<String>(
      valueListenable: _type,
      builder: (_, t, __) {
        final esProp = (t == 'propiedad' || t == 'oficina');
        final esVeh = t == 'vehiculo';
        final esHerr = t == 'herramienta';

        final labelDeposito =
            (esHerr || esVeh) ? 'Garantía (CLP)' : 'Depósito (CLP)';
        final showContratoMeses = esProp;
        final showServicios = esProp;
        final showDiasMin = !esProp;

        final req = {
          ..._reqUniversales,
          ...(_reqPorTipo[t] ?? const <String>[]),
        }.toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SectionCard(
              title: 'Políticas y servicios',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _deposito,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: labelDeposito,
                            prefixIcon: const Icon(Icons.savings_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (showContratoMeses)
                        Expanded(
                          child: TextFormField(
                            controller: _contratoMeses,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Contrato mínimo (meses)',
                              prefixIcon: Icon(Icons.event_note_outlined),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (showDiasMin) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _diasMin,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Días mínimos (opcional)',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (esProp) ...[
                    Wrap(
                      spacing: 6,
                      children: [
                        _chipBool('Mascotas', _mascotas),
                        _chipBool('Fumar', _fumar),
                      ],
                    ),
                    if (showServicios) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          _chipBool('Agua', _incAgua),
                          _chipBool('Luz', _incLuz),
                          _chipBool('Gas', _incGas),
                          _chipBool('Internet', _incInternet),
                        ],
                      ),
                    ],
                  ] else if (esHerr) ...[
                    Wrap(
                      spacing: 6,
                      children: [
                        _chipTextStatic('Incluye accesorios'),
                        _chipTextStatic('Mantenimiento incluido'),
                        _chipTextStatic('Entrega/Retiro coordinado'),
                      ],
                    ),
                  ] else if (esVeh) ...[
                    Wrap(
                      spacing: 6,
                      children: [
                        _chipTextStatic('Combustible según entrega'),
                        _chipTextStatic('Kilometraje según contrato'),
                        _chipTextStatic('Multa por atraso'),
                      ],
                    ),
                  ] else ...[
                    Wrap(
                      spacing: 6,
                      children: [
                        _chipTextStatic('Pago anticipado'),
                        _chipTextStatic('Respeto a normas del recinto'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _politicaCancel,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Política de cancelación (opcional)',
                      prefixIcon: Icon(Icons.rule_folder_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Requisitos',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: _reqSelected,
                    builder: (_, sel, __) {
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: req.map((r) {
                          final picked = sel.contains(r);
                          return FilterChip(
                            label: Text(r),
                            selected: picked,
                            onSelected: (v) {
                              final s = Set<String>.from(sel);
                              v ? s.add(r) : s.remove(r);
                              _reqSelected.value = s;
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reqOtros,
                    decoration: const InputDecoration(
                      labelText: 'Otros requisitos (opcional)',
                      prefixIcon: Icon(Icons.playlist_add_check_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stepEmpresa() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _SectionCard(
          title: 'Empresa y contacto',
          child: Column(
            children: [
              TextFormField(
                controller: _companyName,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la empresa (opcional)',
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contactName,
                      decoration: const InputDecoration(
                        labelText: 'Nombre contacto',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _contactPhone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.call_outlined),
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
                      controller: _contactEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (v) => (v != null && v.isNotEmpty)
                          ? Validators.email(v)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _whatsapp,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp (opcional)',
                        prefixIcon: Icon(Icons.chat_outlined),
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
                      controller: _website,
                      decoration: const InputDecoration(
                        labelText: 'Sitio web (opcional)',
                        prefixIcon: Icon(Icons.public_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Abrir chat WhatsApp',
                    onPressed: () {
                      final link = _waLink();
                      if (link.isEmpty) return;
                      launchUrl(
                        Uri.parse(link),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepFotos() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _SectionCard(
          title: 'Fotos',
          trailing: TextButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Agregar'),
          ),
          child: _MediaPreview(
            images: _images,
            remoteImage: _remoteImage,
            onRemoveLocal: (i) => setState(() => _images.removeAt(i)),
            onClearRemote: () => setState(() => _remoteImage = null),
          ),
        ),
      ],
    );
  }

  Widget _stepPublicar() {
    final editing = widget.editId != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _SectionCard(
          title: 'Revisión final',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Revisa los datos antes de publicar.'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _showPreview,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Previsualizar'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: Icon(
                    _saving ? Icons.hourglass_top : Icons.cloud_upload_outlined,
                  ),
                  label: Text(
                    _saving
                        ? 'Guardando...'
                        : (editing ? 'Actualizar' : 'Publicar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- Sub-secciones específicas ----
  List<Widget> _vehiculoFields() => [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _vehMarca,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  prefixIcon: Icon(Icons.directions_car_filled_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _vehModelo,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  prefixIcon: Icon(Icons.local_taxi_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  prefixIcon: Icon(Icons.time_to_leave_outlined),
                ),
                validator: _reqIfVehiculo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _vehKm,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kilometraje',
                  prefixIcon: Icon(Icons.speed_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Select<String>(
                label: 'Transmisión',
                icon: Icons.settings_suggest_outlined,
                valueListenable: _vehTransmision,
                options: const ['Automática', 'Manual'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Select<String>(
                label: 'Combustible',
                icon: Icons.local_gas_station_outlined,
                valueListenable: _vehCombustible,
                options: const ['Gasolina', 'Diésel', 'Híbrido', 'Eléctrico'],
              ),
            ),
          ],
        ),
      ];

  List<Widget> _canchaFields() => [
        Row(
          children: [
            Expanded(
              child: _Select<String>(
                label: 'Deporte',
                icon: Icons.sports_soccer_outlined,
                valueListenable: _canchaDeporte,
                options: const [
                  'Fútbol 7',
                  'Fútbol 11',
                  'Pádel',
                  'Tenis',
                  'Básquetbol',
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Select<String>(
                label: 'Superficie',
                icon: Icons.landscape_outlined,
                valueListenable: _canchaSuperficie,
                options: const [
                  'Pasto sintético',
                  'Cemento',
                  'Tierra',
                  'Madera'
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _canchaCapacidad,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (personas)',
                  prefixIcon: Icon(Icons.groups_2_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _canchaHorario,
                decoration: const InputDecoration(
                  labelText: 'Horario (ej: 10:00-22:00)',
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SwitchListTile(
          value: _canchaTechada.value,
          onChanged: (v) => setState(() => _canchaTechada.value = v),
          title: const Text('Techada'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: _canchaIluminacion.value,
          onChanged: (v) => setState(() => _canchaIluminacion.value = v),
          title: const Text('Iluminación'),
          contentPadding: EdgeInsets.zero,
        ),
      ];

  List<Widget> _piscinaFields() => [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _piscinaLargo,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Largo (m)',
                  prefixIcon: Icon(Icons.straighten_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _piscinaAncho,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ancho (m)',
                  prefixIcon: Icon(Icons.straighten_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _piscinaProfundidad,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Profundidad (m)',
            prefixIcon: Icon(Icons.waves_outlined),
          ),
        ),
        const SizedBox(height: 6),
        SwitchListTile(
          value: _piscinaClimatizada.value,
          onChanged: (v) => setState(() => _piscinaClimatizada.value = v),
          title: const Text('Climatizada'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: _piscinaInterior.value,
          onChanged: (v) => setState(() => _piscinaInterior.value = v),
          title: const Text('Interior'),
          contentPadding: EdgeInsets.zero,
        ),
      ];

  List<Widget> _herramientaFields() => [
        TextFormField(
          controller: _herrNombre,
          decoration: const InputDecoration(
            labelText: 'Nombre / modelo',
            prefixIcon: Icon(Icons.handyman_outlined),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Select<String>(
                label: 'Condición',
                icon: Icons.check_circle_outline,
                valueListenable: _herrCondicion,
                options: const ['Nueva', 'Usada'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Select<String>(
                label: 'Entrega',
                icon: Icons.local_shipping_outlined,
                valueListenable: _herrEntrega,
                options: const ['Retiro en tienda', 'Despacho', 'A convenir'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _herrGarantia,
          decoration: const InputDecoration(
            labelText: 'Garantía/Depósito (opcional)',
            prefixIcon: Icon(Icons.safety_check_outlined),
          ),
        ),
      ];

  List<Widget> _terrenoFields() => [
        _Select<String>(
          label: 'Uso/Zonificación',
          icon: Icons.layers_outlined,
          valueListenable: _terrUso,
          options: const ['Residencial', 'Comercial', 'Industrial', 'Agrícola'],
        ),
        const SizedBox(height: 6),
        SwitchListTile(
          value: _terrAgua.value,
          onChanged: (v) => setState(() => _terrAgua.value = v),
          title: const Text('Agua disponible'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: _terrLuz.value,
          onChanged: (v) => setState(() => _terrLuz.value = v),
          title: const Text('Electricidad disponible'),
          contentPadding: EdgeInsets.zero,
        ),
      ];

  List<Widget> _oficinaFields() => [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ofiM2,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'm² útiles',
                  prefixIcon: Icon(Icons.square_foot_outlined),
                ),
                validator: (v) =>
                    _type.value == 'oficina' && (v == null || v.isEmpty)
                        ? 'Obligatorio'
                        : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _ofiSalas,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Salas de reunión',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
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
                controller: _ofiEstacionamientos,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estacionamientos',
                  prefixIcon: Icon(Icons.local_parking_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SwitchListTile(
                value: _ofiAmoblada.value,
                onChanged: (v) => setState(() => _ofiAmoblada.value = v),
                title: const Text('Amoblada'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ];

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  IconData _iconForType(String t) {
    switch (t) {
      case 'vehiculo':
        return Icons.directions_car;
      case 'cancha':
        return Icons.sports_soccer;
      case 'piscina':
        return Icons.pool;
      case 'herramienta':
        return Icons.handyman;
      case 'oficina':
        return Icons.apartment;
      case 'terreno':
        return Icons.terrain_outlined;
      default:
        return Icons.home_work_outlined;
    }
  }

  // ====== VIDEO: grabar / elegir / limpiar ======
  Future<void> _recordVideo() async {
    final picker = ImagePicker();
    final XFile? x = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 2),
    );
    if (x == null) return;
    setState(() {
      _localVideo = File(x.path);
      _videoUrl.clear();
    });
  }

  Future<void> _pickVideoFromGallery() async {
    final picker = ImagePicker();
    final XFile? x = await picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return;
    setState(() {
      _localVideo = File(x.path);
      _videoUrl.clear();
    });
  }

  void _clearVideo() {
    setState(() {
      _localVideo = null;
      _videoUrl.clear();
    });
  }

  // ====== VIDEO & MAPA ======
  bool _isYouTube(String u) {
    final lu = u.toLowerCase();
    return lu.contains('youtube.com') ||
        lu.contains('youtu.be') ||
        lu.length == 11;
  }

  String? _extractYouTubeId(String input) {
    final s = input.trim();
    final idOnly = RegExp(r'^[0-9A-Za-z_-]{11}$');
    if (idOnly.hasMatch(s)) return s;

    Uri? uri;
    try {
      uri = Uri.parse(s);
    } catch (_) {}

    if (uri != null && uri.host.isNotEmpty) {
      final v = uri.queryParameters['v'];
      if (v != null && idOnly.hasMatch(v)) return v;

      final segs = uri.pathSegments;
      if (uri.host.contains('youtu.be') && segs.isNotEmpty) {
        final cand = segs.last;
        if (idOnly.hasMatch(cand)) return cand;
      }
      if (segs.isNotEmpty) {
        final cand = segs.last;
        if (idOnly.hasMatch(cand)) return cand;
      }
    }

    final m = RegExp(r'([0-9A-Za-z_-]{11})').firstMatch(s);
    return m?.group(1);
  }

  String _ytWatchUrl(String id) => 'https://www.youtube.com/watch?v=$id';

  bool _isLocalPath(String u) => u.startsWith('/') || u.startsWith('file:');
  bool _isMp4(String u) => u.toLowerCase().endsWith('.mp4') || _isLocalPath(u);

  Future<Widget> _mp4Player(String url) async {
    final VideoPlayerController vc = _isLocalPath(url)
        ? VideoPlayerController.file(File(url.replaceFirst('file://', '')))
        : VideoPlayerController.networkUrl(Uri.parse(url));
    await vc.initialize();
    return Chewie(
      controller: ChewieController(
        videoPlayerController: vc,
        autoInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
      ),
    );
  }

  Widget _videoPreview(String? url) {
    if ((url == null || url.trim().isEmpty) && _localVideo == null) {
      return const SizedBox.shrink();
    }
    if (_localVideo != null) {
      return FutureBuilder<Widget>(
        future: _mp4Player(_localVideo!.path),
        builder: (_, s) => s.hasData
            ? AspectRatio(aspectRatio: 16 / 9, child: s.data!)
            : const SizedBox(height: 180),
      );
    }
    final u = url!.trim();
    if (_isYouTube(u)) {
      final id = _extractYouTubeId(u);
      if (id == null) return const Text('Link de YouTube inválido');

      final ctrl = YoutubePlayerController.fromVideoId(
        videoId: id,
        params: const YoutubePlayerParams(showFullscreenButton: true),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: ctrl),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(_ytWatchUrl(id)),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir en YouTube'),
          ),
        ],
      );
    }
    if (_isMp4(u)) {
      return FutureBuilder<Widget>(
        future: _mp4Player(u),
        builder: (_, s) => s.hasData
            ? AspectRatio(aspectRatio: 16 / 9, child: s.data!)
            : const SizedBox(height: 180),
      );
    }
    return TextButton.icon(
      onPressed: () =>
          launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication),
      icon: const Icon(Icons.open_in_new),
      label: const Text('Abrir video'),
    );
  }

  // ====== MAPA ======
  void _syncPointFromLatLng() {
    final la = NumberUtils.toDoubleSafe(_lat.text);
    final lo = NumberUtils.toDoubleSafe(_lng.text);
    if (la != null && lo != null) setState(() => _point = LatLng(la, lo));
  }

  Future<void> _geocodeAddress() async {
    // FIX: compone correctamente la query y valida vacío
    final parts = <String>[
      _street.text.trim(),
      _location.text.trim(),
      _comunaCtrl.text.trim(),
      'Chile',
    ]..removeWhere((e) => e.isEmpty);

    final query = parts.join(', ');
    if (query.isEmpty) return;

    try {
      // 🔧 Se elimina localeIdentifier para evitar undefined_named_parameter
      final list = await locationFromAddress(query);
      if (list.isNotEmpty) {
        final la = list.first.latitude;
        final lo = list.first.longitude;
        _lat.text = la.toStringAsFixed(6);
        _lng.text = lo.toStringAsFixed(6);
        setState(() => _point = LatLng(la, lo));
      }
    } catch (_) {}
  }

  Widget _miniMap() {
    if (_point == null) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Escribe la dirección o lat/lng para ver el mapa'),
      );
    }
    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(initialCenter: _point!, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _point!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ====== Chips helpers ======
  Widget _chipBool(String label, ValueNotifier<bool> notifier) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (_, v, __) => FilterChip(
        label: Text(label),
        selected: v,
        onSelected: (nv) => setState(() => notifier.value = nv),
      ),
    );
  }

  Widget _chipTextStatic(String label) {
    return FilterChip(label: Text(label), selected: true, onSelected: null);
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    _category.dispose();
    _type.dispose();
    _street.dispose();
    _location.dispose();
    _comunaCtrl.dispose();
    _lat.dispose();
    _lng.dispose();
    _area.dispose();
    _beds.dispose();
    _baths.dispose();
    _year.dispose();
    _videoUrl.dispose();
    _companyName.dispose();
    _contactName.dispose();
    _contactPhone.dispose();
    _contactEmail.dispose();
    _website.dispose();
    _whatsapp.dispose();
    _vehMarca.dispose();
    _vehModelo.dispose();
    _vehKm.dispose();
    _vehTransmision.dispose();
    _vehCombustible.dispose();
    _canchaDeporte.dispose();
    _canchaSuperficie.dispose();
    _canchaTechada.dispose();
    _canchaIluminacion.dispose();
    _canchaCapacidad.dispose();
    _canchaHorario.dispose();
    _piscinaLargo.dispose();
    _piscinaAncho.dispose();
    _piscinaProfundidad.dispose();
    _piscinaClimatizada.dispose();
    _piscinaInterior.dispose();
    _herrNombre.dispose();
    _herrCondicion.dispose();
    _herrGarantia.dispose();
    _herrEntrega.dispose();
    _terrUso.dispose();
    _terrAgua.dispose();
    _terrLuz.dispose();
    _ofiM2.dispose();
    _ofiAmoblada.dispose();
    _ofiSalas.dispose();
    _ofiEstacionamientos.dispose();
    _deposito.dispose();
    _contratoMeses.dispose();
    _destacado.dispose();
    _reqOtros.dispose();
    _diasMin.dispose();
    _politicaCancel.dispose();
    _reqSelected.dispose();
    _stepperCtrl.dispose();
    super.dispose();
  }
}

// ====================== Widgets auxiliares ======================

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Select<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final ValueNotifier<T?> valueListenable;
  final List<T> options;
  const _Select({
    required this.label,
    required this.icon,
    required this.valueListenable,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T?>(
      valueListenable: valueListenable,
      builder: (_, v, __) {
        return DropdownButtonFormField<T>(
          initialValue: v ?? (options.isNotEmpty ? options.first : null),
          decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
          items: options
              .map((e) => DropdownMenuItem<T>(value: e, child: Text('$e')))
              .toList(),
          onChanged: (nv) => valueListenable.value = nv,
        );
      },
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final List<File> images;
  final String? remoteImage;
  final void Function(int index)? onRemoveLocal;
  final VoidCallback? onClearRemote;

  const _MediaPreview({
    required this.images,
    this.remoteImage,
    this.onRemoveLocal,
    this.onClearRemote,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty && (remoteImage == null || remoteImage!.isEmpty)) {
      return const Text('Aún no has seleccionado imágenes.');
    }

    final tiles = <Widget>[];

    if (remoteImage != null && remoteImage!.isNotEmpty) {
      tiles.add(
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: remoteImage!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: const Color(0xFFEFF2F7)),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFEFF2F7),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: InkWell(
                onTap: onClearRemote,
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    for (var i = 0; i < images.length; i++) {
      final f = images[i];
      tiles.add(
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(f, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: InkWell(
                onTap: () => onRemoveLocal?.call(i),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black54,
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      itemCount: tiles.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 16 / 10,
      ),
      itemBuilder: (_, i) => tiles[i],
    );
  }
}

class _ComunaAutocomplete extends StatelessWidget {
  final List<String> all;
  final TextEditingController controller;
  const _ComunaAutocomplete({required this.all, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (all.isEmpty) {
      return TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Comuna',
          prefixIcon: Icon(Icons.location_city_outlined),
        ),
      );
    }
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (t) {
        final q = t.text.toLowerCase();
        if (q.isEmpty) return const Iterable<String>.empty();
        return all.where((c) => c.toLowerCase().contains(q));
      },
      onSelected: (v) => controller.text = v,
      fieldViewBuilder: (_, fieldCtrl, focus, __) {
        fieldCtrl.text = controller.text;
        fieldCtrl.addListener(() => controller.text = fieldCtrl.text);
        return TextFormField(
          controller: fieldCtrl,
          focusNode: focus,
          decoration: const InputDecoration(
            labelText: 'Comuna',
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
        );
      },
    );
  }
}

class _CategoryAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  const _CategoryAutocomplete({
    required this.controller,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (t) {
        final q = t.text.toLowerCase();
        if (q.isEmpty) return suggestions;
        return suggestions.where((c) => c.toLowerCase().contains(q));
      },
      onSelected: (v) => controller.text = v,
      fieldViewBuilder: (_, fieldCtrl, focus, __) {
        fieldCtrl.text = controller.text;
        fieldCtrl.addListener(() => controller.text = fieldCtrl.text);
        return TextFormField(
          controller: fieldCtrl,
          focusNode: focus,
          decoration: const InputDecoration(
            labelText: 'Categoría (departamento, SUV, etc.)',
            prefixIcon: Icon(Icons.list_alt_outlined),
          ),
        );
      },
    );
  }
}

class _BottomStepper extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  const _BottomStepper({
    required this.current,
    required this.total,
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: const Border(top: BorderSide(color: Color(0x0F000000))),
        ),
        child: Row(
          children: [
            Text(
              '${current + 1}/$total',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Atrás'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              label: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}
