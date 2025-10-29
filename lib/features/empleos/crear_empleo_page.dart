// ===============================================================
// 🔹 CREAR EMPLEO PROFESIONAL - SmartRent+
// ===============================================================
// Permite a empresas publicar un empleo con:
// - Imagen
// - Campos completos de detalle
// - Geolocalización integrada con Google Maps
// ===============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/data/services/job_service.dart';

class CrearEmpleoPage extends StatefulWidget {
  const CrearEmpleoPage({super.key});

  @override
  State<CrearEmpleoPage> createState() => _CrearEmpleoPageState();
}

class _CrearEmpleoPageState extends State<CrearEmpleoPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _data = {};
  final ImagePicker _picker = ImagePicker();

  File? _imagenFile;
  LatLng? _ubicacion;
  GoogleMapController? _mapController;
  final _direccionController = TextEditingController();

  // ============================================================
  // 📸 Seleccionar imagen
  // ============================================================
  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() => _imagenFile = File(imagen.path));
    }
  }

  // ============================================================
  // 📍 Buscar dirección en el mapa
  // ============================================================
  Future<void> _buscarUbicacionPorDireccion(String direccion) async {
    try {
      List<Location> locations = await locationFromAddress(direccion);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _ubicacion = LatLng(loc.latitude, loc.longitude);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_ubicacion!, 15),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo encontrar la dirección: $e")),
      );
    }
  }

  // ============================================================
  // 💾 Guardar empleo
  // ============================================================
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Se agrega ubicación si se seleccionó
    if (_ubicacion != null) {
      _data['latitud'] = _ubicacion!.latitude;
      _data['longitud'] = _ubicacion!.longitude;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Publicando empleo...")));

    final ok = await JobService.crearEmpleo(_data);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? '✅ Empleo publicado correctamente' : '❌ Error al publicar',
        ),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  // ============================================================
  // 🧱 Campo de formulario reutilizable
  // ============================================================
  Widget _campo(
    String label,
    String key, {
    int maxLines = 1,
    TextInputType tipo = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: tipo,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
        onSaved: (v) => _data[key] = v,
      ),
    );
  }

  // ============================================================
  // 🏗️ UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Empleo'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 📸 Imagen
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                    image: _imagenFile != null
                        ? DecorationImage(
                            image: FileImage(_imagenFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagenFile == null
                      ? const Center(
                          child: Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // 🧾 Campos de formulario
              _campo('Título del empleo', 'titulo'),
              _campo('Descripción del puesto', 'descripcion', maxLines: 4),
              _campo('Categoría laboral', 'categoria'),
              _campo('Tipo de contrato', 'tipoContrato'),
              _campo('Rango salarial', 'salario', tipo: TextInputType.number),
              _campo('Beneficios del empleo', 'beneficios', maxLines: 2),

              // 📍 Dirección y mapa
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección del empleo',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map_outlined),
                    onPressed: () =>
                        _buscarUbicacionPorDireccion(_direccionController.text),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
                onSaved: (v) => _data['ubicacion'] = v,
              ),
              const SizedBox(height: 20),

              // 🗺️ Mapa
              SizedBox(
                height: 200,
                child: _ubicacion == null
                    ? const Center(
                        child: Text('Busca una dirección para ver el mapa'),
                      )
                    : GoogleMap(
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        initialCameraPosition: CameraPosition(
                          target: _ubicacion!,
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('empleo'),
                            position: _ubicacion!,
                          ),
                        },
                      ),
              ),
              const SizedBox(height: 25),

              // ☁️ Botón guardar
              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Publicar empleo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
