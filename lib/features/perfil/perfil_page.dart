// ===============================================================
// 🔹 PERFIL AVANZADO DE USUARIO - SmartRent+
// ===============================================================
// Muestra información completa del usuario con avatar, bio, redes,
// estadísticas y acceso al editor conectado al backend.
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/core/utils/constants.dart';
import 'package:smartrent_plus/features/perfil/editar_perfil_page.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  Map<String, dynamic>? user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ============================================================
  // 🔹 CARGAR PERFIL DEL BACKEND
  // ============================================================
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final token = prefs.getString('token');

      if (userId == null || token == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/users/$userId');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          user = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        debugPrint('❌ Error al cargar perfil (${response.statusCode})');
        setState(() => _loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('⚠️ Error al cargar perfil: $e');
      setState(() => _loading = false);
    }
  }

  // ============================================================
  // 🔹 CERRAR SESIÓN
  // ============================================================
  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // 🔹 ABRIR RED SOCIAL / LINK EXTERNO
  // ============================================================
  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al abrir enlace: $e')));
    }
  }

  // ============================================================
  // 🔹 INTERFAZ DE USUARIO
  // ============================================================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: const Center(
          child: Text("No se pudieron cargar los datos del perfil"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- CABECERA ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage(
                        user!['imagen'] ?? 'https://i.pravatar.cc/150?img=11',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user!['nombre'] ?? 'Usuario sin nombre',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user!['tipoCuenta'] ?? 'Usuario',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (user!['bio'] != null && user!['bio'] != '')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          user!['bio'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- INFORMACIÓN DE CONTACTO ---
            _infoTile(Icons.email, 'Correo electrónico', user!['correo']),
            _infoTile(Icons.phone, 'Teléfono', user!['telefono'] ?? '—'),
            _infoTile(Icons.location_on, 'Ciudad', user!['ciudad'] ?? '—'),

            const Divider(height: 30),

            // --- REDES SOCIALES ---
            const Text(
              "Redes Sociales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (user!['facebook']?.isNotEmpty ?? false)
                  _socialButton(Icons.facebook, 'Facebook', user!['facebook']),
                if (user!['instagram']?.isNotEmpty ?? false)
                  _socialButton(
                    Icons.camera_alt,
                    'Instagram',
                    user!['instagram'],
                  ),
                if (user!['linkedin']?.isNotEmpty ?? false)
                  _socialButton(
                    Icons.business_center,
                    'LinkedIn',
                    user!['linkedin'],
                  ),
                if (user!['website']?.isNotEmpty ?? false)
                  _socialButton(Icons.language, 'Sitio Web', user!['website']),
              ],
            ),

            const Divider(height: 30),

            // --- ESTADÍSTICAS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Publicaciones', '8'),
                _buildStat('Favoritos', '15'),
                _buildStat('Postulaciones', '3'),
              ],
            ),

            const SizedBox(height: 30),

            // --- BOTONES ---
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Editar perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarPerfilPage(user: user!),
                  ),
                );
                if (updated == true) {
                  if (!mounted) return;
                  _loadUserProfile(); // ✅ Recarga perfil al volver
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🔹 COMPONENTES REUTILIZABLES
  // ============================================================
  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: TextStyle(color: Colors.grey[700])),
    );
  }

  Widget _socialButton(IconData icon, String name, String url) {
    return ElevatedButton.icon(
      onPressed: () => _openUrl(url),
      icon: Icon(icon, color: Colors.white),
      label: Text(name),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
