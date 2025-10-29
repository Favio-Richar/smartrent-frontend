// lib/features/arriendos/crear_arriendo_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smartrent_plus/core/utils/validators.dart';
import 'package:smartrent_plus/data/services/property_service.dart';

class CrearArriendoPage extends StatefulWidget {
  final String? editId; // si viene, es edición
  const CrearArriendoPage({super.key, this.editId});

  @override
  State<CrearArriendoPage> createState() => _CrearArriendoPageState();
}

class _CrearArriendoPageState extends State<CrearArriendoPage> {
  final _form = GlobalKey<FormState>();
  final _svc = PropertyService();

  // -------------------- Controllers --------------------
  // Básicos
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();

  // Clasificación
  final _category = TextEditingController();
  final _type = ValueNotifier<String>('propiedad');

  // Ubicación
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

  // Media
  final List<File> _images = [];
  String? _remoteImage;

  // Catálogos
  List<String> _tipos = const [];
  List<String> _comunas = const [];

  // Estado
  bool _saving = false;
  bool _loadingData = true;

  // -------------------- Detalles por TIPO (metadata) --------------------
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

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final results = await Future.wait([_svc.getTipos(), _svc.getComunas()]);
      _tipos = results[0].isEmpty
          ? [
              'propiedad',
              'vehiculo',
              'cancha',
              'piscina',
              'herramienta',
              'terreno',
              'oficina',
            ]
          : results[0];
      _comunas = results[1];

      if (widget.editId != null) {
        await _loadEdit();
      }
    } catch (_) {
      _tipos = [
        'propiedad',
        'vehiculo',
        'cancha',
        'piscina',
        'herramienta',
        'terreno',
        'oficina',
      ];
    } finally {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  Future<void> _loadEdit() async {
    final p = await _svc.getById(widget.editId!);

    _title.text = _s(p['title']);
    _price.text = _s(p['price']);
    _desc.text = _s(p['description']);
    _type.value = _s(p['type']).isEmpty ? 'propiedad' : _s(p['type']);
    _category.text = _s(p['category']);

    _location.text = _s(p['location']);
    _comunaCtrl.text = _s(p['comuna']);
    _lat.text = _s(p['latitude']);
    _lng.text = _s(p['longitude']);

    _area.text = _s(p['area']);
    _beds.text = _s(p['bedrooms']);
    _baths.text = _s(p['bathrooms']);
    _year.text = _s(p['year']);
    _videoUrl.text = _s(p['video_url'] ?? p['videoUrl']);

    final meta = (p['metadata'] as Map?) ?? {};
    _hydrateMeta(meta);

    final contact = (p['contact'] ?? {}) as Map?;
    _companyName.text = _s(p['company_name'] ?? contact?['company_name']);
    _contactName.text = _s(p['contact_name'] ?? contact?['name']);
    _contactPhone.text = _s(p['contact_phone'] ?? contact?['phone']);
    _contactEmail.text = _s(p['contact_email'] ?? contact?['email']);
    _website.text = _s(p['website'] ?? contact?['website']);
    _whatsapp.text = _s(p['whatsapp'] ?? contact?['whatsapp']);

    _destacado.value = (p['featured'] ?? false) == true;
    _remoteImage = _s(p['image_url'] ?? p['imageUrl']);
  }

  void _hydrateMeta(Map meta) {
    _vehMarca.text = _s(meta['veh_marca']);
    _vehModelo.text = _s(meta['veh_modelo']);
    _vehKm.text = _s(meta['veh_km']);
    _vehTransmision.value = meta['veh_transmision'] ?? _vehTransmision.value;
    _vehCombustible.value = meta['veh_combustible'] ?? _vehCombustible.value;

    _canchaDeporte.value = meta['cancha_deporte'] ?? _canchaDeporte.value;
    _canchaSuperficie.value =
        meta['cancha_superficie'] ?? _canchaSuperficie.value;
    _canchaTechada.value =
        (meta['cancha_techada'] ?? _canchaTechada.value) == true;
    _canchaIluminacion.value =
        (meta['cancha_iluminacion'] ?? _canchaIluminacion.value) == true;
    _canchaCapacidad.text = _s(meta['cancha_capacidad']);
    _canchaHorario.text = _s(meta['cancha_horario']);

    _piscinaLargo.text = _s(meta['pisc_largo']);
    _piscinaAncho.text = _s(meta['pisc_ancho']);
    _piscinaProfundidad.text = _s(meta['pisc_prof']);
    _piscinaClimatizada.value =
        (meta['pisc_clima'] ?? _piscinaClimatizada.value) == true;
    _piscinaInterior.value =
        (meta['pisc_inter'] ?? _piscinaInterior.value) == true;

    _herrNombre.text = _s(meta['herr_nombre']);
    _herrCondicion.value = meta['herr_cond'] ?? _herrCondicion.value;
    _herrGarantia.text = _s(meta['herr_garantia']);
    _herrEntrega.value = meta['herr_entrega'] ?? _herrEntrega.value;

    _terrUso.value = meta['terr_uso'] ?? _terrUso.value;
    _terrAgua.value = (meta['terr_agua'] ?? _terrAgua.value) == true;
    _terrLuz.value = (meta['terr_luz'] ?? _terrLuz.value) == true;

    _ofiM2.text = _s(meta['ofi_m2']);
    _ofiAmoblada.value = (meta['ofi_amobl'] ?? _ofiAmoblada.value) == true;
    _ofiSalas.text = _s(meta['ofi_salas']);
    _ofiEstacionamientos.text = _s(meta['ofi_est']);
  }

  Map<String, dynamic> _collectMetadata() {
    switch (_type.value) {
      case 'vehiculo':
        return {
          'veh_marca': _optText(_vehMarca),
          'veh_modelo': _optText(_vehModelo),
          'veh_km': _toInt(_vehKm.text),
          'veh_transmision': _vehTransmision.value,
          'veh_combustible': _vehCombustible.value,
        }..removeWhere((k, v) => v == null || v == '');
      case 'cancha':
        return {
          'cancha_deporte': _canchaDeporte.value,
          'cancha_superficie': _canchaSuperficie.value,
          'cancha_techada': _canchaTechada.value,
          'cancha_iluminacion': _canchaIluminacion.value,
          'cancha_capacidad': _toInt(_canchaCapacidad.text),
          'cancha_horario': _optText(_canchaHorario),
        }..removeWhere((k, v) => v == null || v == '');
      case 'piscina':
        return {
          'pisc_largo': _toDouble(_piscinaLargo.text),
          'pisc_ancho': _toDouble(_piscinaAncho.text),
          'pisc_prof': _toDouble(_piscinaProfundidad.text),
          'pisc_clima': _piscinaClimatizada.value,
          'pisc_inter': _piscinaInterior.value,
        }..removeWhere((k, v) => v == null || v == '');
      case 'herramienta':
        return {
          'herr_nombre': _optText(_herrNombre),
          'herr_cond': _herrCondicion.value,
          'herr_garantia': _optText(_herrGarantia),
          'herr_entrega': _herrEntrega.value,
        }..removeWhere((k, v) => v == null || v == '');
      case 'terreno':
        return {
          'terr_uso': _terrUso.value,
          'terr_agua': _terrAgua.value,
          'terr_luz': _terrLuz.value,
        }..removeWhere((k, v) => v == null || v == '');
      case 'oficina':
        return {
          'ofi_m2': _toInt(_ofiM2.text),
          'ofi_amobl': _ofiAmoblada.value,
          'ofi_salas': _toInt(_ofiSalas.text),
          'ofi_est': _toInt(_ofiEstacionamientos.text),
        }..removeWhere((k, v) => v == null || v == '');
      default:
        return {};
    }
  }

  String _s(dynamic v) => (v == null) ? '' : '$v';

  // -------------------- Media --------------------
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final list = await picker.pickMultiImage(imageQuality: 85);
    if (list.isEmpty) return;
    setState(() {
      _images.addAll(list.map((x) => File(x.path)));
      _remoteImage = null;
    });
  }

  Future<String?> _uploadFirstImageIfNeeded() async {
    if (_images.isEmpty) return _remoteImage;
    return _svc.uploadImage(_images.first);
  }

  // -------------------- Validadores (como métodos de clase) --------------------
  String? reqIfPropiedad(String? v) {
    if (!(_type.value == 'propiedad' ||
        _type.value == 'terreno' ||
        _type.value == 'oficina')) {
      return null;
    }
    return (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;
  }

  String? reqIfVehiculo(String? v) {
    if (_type.value != 'vehiculo') return null;
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    final n = int.tryParse(v);
    return (n == null || n < 1900) ? 'Año inválido' : null;
  }

  // -------------------- Guardar --------------------
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final imageUrl = await _uploadFirstImageIfNeeded();

      final payload = <String, dynamic>{
        "title": _title.text.trim(),
        "price": double.parse(_price.text.trim()),
        "description": _desc.text.trim(),
        "type": _type.value,
        "category": _category.text.trim(),
        "location": _location.text.trim(),
        "comuna": _optText(_comunaCtrl),
        "latitude": _toDouble(_lat.text),
        "longitude": _toDouble(_lng.text),
        "area": _toInt(_area.text),
        "bedrooms": _toInt(_beds.text),
        "bathrooms": _toInt(_baths.text),
        "year": _toInt(_year.text),
        "video_url": _optText(_videoUrl),
        "featured": _destacado.value,
        if (imageUrl != null) "image_url": imageUrl,

        // contacto/empresa
        "company_name": _optText(_companyName),
        "contact_name": _optText(_contactName),
        "contact_phone": _optText(_contactPhone),
        "contact_email": _optText(_contactEmail),
        "website": _optText(_website),
        "whatsapp": _optText(_whatsapp),

        // detalles por tipo
        "metadata": _collectMetadata(),
      };

      final ok = widget.editId == null
          ? await _svc.create(payload)
          : await _svc.update(widget.editId!, payload);

      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editId == null ? 'Publicado' : 'Actualizado'),
          ),
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

  int? _toInt(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim());
  double? _toDouble(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.trim());
  String? _optText(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final editing = widget.editId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar arriendo' : 'Crear arriendo'),
        actions: [
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _SectionCard(
                    title: 'Información básica',
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
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio (CLP)',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          validator: Validators.requiredNumber,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Clasificación',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tipos.map((t) {
                            final sel = _type.value == t;
                            return ChoiceChip(
                              label: Text(_cap(t)),
                              selected: sel,
                              onSelected: (_) =>
                                  setState(() => _type.value = t),
                              avatar: Icon(
                                _iconForType(t),
                                size: 18,
                                color: sel ? Colors.white : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _category,
                          decoration: const InputDecoration(
                            labelText: 'Categoría (departamento, SUV, etc.)',
                            prefixIcon: Icon(Icons.list_alt_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Ubicación',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _location,
                          decoration: const InputDecoration(
                            labelText: 'Dirección / referencia',
                            prefixIcon: Icon(Icons.place_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ComunaAutocomplete(
                          all: _comunas,
                          controller: _comunaCtrl,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _lat,
                                keyboardType: TextInputType.number,
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
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Longitud (opcional)',
                                  prefixIcon: Icon(Icons.map_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: _type,
                    builder: (_, t, __) {
                      return _SectionCard(
                        title: 'Detalles',
                        child: Column(
                          children: [
                            if (t == 'propiedad' ||
                                t == 'terreno' ||
                                t == 'oficina') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _area,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Superficie (m²)',
                                        prefixIcon: Icon(
                                          Icons.square_foot_outlined,
                                        ),
                                      ),
                                      validator: reqIfPropiedad,
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
                                validator: reqIfPropiedad,
                              ),
                            ],
                            if (t == 'vehiculo') ..._vehiculoFields(),
                            if (t == 'cancha') ..._canchaFields(),
                            if (t == 'piscina') ..._piscinaFields(),
                            if (t == 'herramienta') ..._herramientaFields(),
                            if (t == 'terreno') ..._terrenoFields(),
                            if (t == 'oficina') ..._oficinaFields(),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _videoUrl,
                              decoration: const InputDecoration(
                                labelText: 'Video URL (opcional)',
                                prefixIcon: Icon(Icons.ondemand_video_outlined),
                              ),
                            ),
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
                      );
                    },
                  ),

                  const SizedBox(height: 12),
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
                                validator: (v) {
                                  if (v != null && v.isNotEmpty) {
                                    return Validators.email(v);
                                  }
                                  return null;
                                },
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
                        TextFormField(
                          controller: _website,
                          decoration: const InputDecoration(
                            labelText: 'Sitio web (opcional)',
                            prefixIcon: Icon(Icons.public_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
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

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: Icon(
                        _saving
                            ? Icons.hourglass_top
                            : Icons.cloud_upload_outlined,
                      ),
                      label: Text(
                        _saving
                            ? 'Guardando...'
                            : (editing ? 'Actualizar publicación' : 'Publicar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            validator: reqIfVehiculo,
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
            options: const ['Pasto sintético', 'Cemento', 'Tierra', 'Madera'],
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

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    _category.dispose();
    _type.dispose();

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

    _destacado.dispose();
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
          // Flutter 3.33+: usar initialValue en vez de value
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
                child: Image.network(remoteImage!, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: InkWell(
                onTap: onClearRemote,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black54,
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
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
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black54,
                  child: const Icon(
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
      fieldViewBuilder: (_, fieldCtrl, focus, onFieldSubmitted) {
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
      optionsViewBuilder: (_, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 380),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final o = options.elementAt(i);
                return ListTile(
                  title: Text(o),
                  onTap: () => onSelected(o),
                  dense: true,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
