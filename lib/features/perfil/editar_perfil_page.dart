// ===============================================================
// 🔹 EDITAR PERFIL AVANZADO - SmartRent+ (con PUT backend)
// ===============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/core/utils/constants.dart';

class EditarPerfilPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditarPerfilPage({super.key, required this.user});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _ciudadController;
  late TextEditingController _bioController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _linkedinController;
  late TextEditingController _websiteController;

  File? _imageFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nombreController = TextEditingController(text: u['nombre'] ?? '');
    _telefonoController = TextEditingController(text: u['telefono'] ?? '');
    _ciudadController = TextEditingController(text: u['ciudad'] ?? '');
    _bioController = TextEditingController(text: u['bio'] ?? '');
    _facebookController = TextEditingController(text: u['facebook'] ?? '');
    _instagramController = TextEditingController(text: u['instagram'] ?? '');
    _linkedinController = TextEditingController(text: u['linkedin'] ?? '');
    _websiteController = TextEditingController(text: u['website'] ?? '');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _guardarCambios() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = prefs.getString('token');

    if (userId == null || token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: sesión no encontrada.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/users/$userId');

    final body = {
      'nombre': _nombreController.text,
      'telefono': _telefonoController.text,
      'ciudad': _ciudadController.text,
      'bio': _bioController.text,
      'facebook': _facebookController.text,
      'instagram': _instagramController.text,
      'linkedin': _linkedinController.text,
      'website': _websiteController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('🚨 Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : NetworkImage(
                            widget.user['imagen'] ??
                                'https://i.pravatar.cc/150?img=12',
                          ) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildField(_nombreController, 'Nombre completo', Icons.person),
            _buildField(_telefonoController, 'Teléfono', Icons.phone),
            _buildField(_ciudadController, 'Ciudad', Icons.location_on),
            _buildField(
              _bioController,
              'Biografía',
              Icons.edit_note,
              maxLines: 3,
            ),
            const Divider(height: 30),
            const Text(
              'Redes Sociales',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildField(_facebookController, 'Facebook', Icons.facebook),
            _buildField(_instagramController, 'Instagram', Icons.camera_alt),
            _buildField(_linkedinController, 'LinkedIn', Icons.work_outline),
            _buildField(_websiteController, 'Sitio Web', Icons.link),
            const SizedBox(height: 25),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _guardarCambios,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Guardar cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
