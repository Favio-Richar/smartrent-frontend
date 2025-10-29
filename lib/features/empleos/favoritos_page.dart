// ===============================================================
// 🔹 FAVORITOS - SmartRent+
// ===============================================================
// Muestra los empleos marcados como favoritos por el usuario.
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/data/services/job_service.dart';
import 'package:smartrent_plus/features/empleos/detalle_empleo_page.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<dynamic> favoritos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await JobService.obtenerFavoritos();

      if (!mounted) return; // ✅ evita warning

      setState(() {
        favoritos = data;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ Error al cargar favoritos: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar: $e')));
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Empleos Favoritos"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : favoritos.isEmpty
          ? const Center(child: Text('No tienes favoritos guardados.'))
          : ListView.builder(
              itemCount: favoritos.length,
              itemBuilder: (context, i) {
                final job = favoritos[i]['job'];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(
                      Icons.work_outline_rounded,
                      color: Colors.blueAccent,
                    ),
                    title: Text(job['titulo'] ?? 'Sin título'),
                    subtitle: Text(job['ubicacion'] ?? 'Sin ubicación'),
                    trailing: const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetalleEmpleoPage(empleoId: job['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
