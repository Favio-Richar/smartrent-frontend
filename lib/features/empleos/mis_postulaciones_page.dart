// ===============================================================
// 🔹 MIS POSTULACIONES - SmartRent+
// ===============================================================
// Muestra todas las postulaciones del usuario logueado, con su estado.
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/data/services/job_service.dart';

class MisPostulacionesPage extends StatefulWidget {
  const MisPostulacionesPage({super.key});

  @override
  State<MisPostulacionesPage> createState() => _MisPostulacionesPageState();
}

class _MisPostulacionesPageState extends State<MisPostulacionesPage> {
  List<dynamic> postulaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPostulaciones();
  }

  Future<void> _cargarPostulaciones() async {
    try {
      final data = await JobService.obtenerPostulacionesUsuario();
      if (!mounted) return;
      setState(() {
        postulaciones = data;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
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
        title: const Text('Mis Postulaciones'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : postulaciones.isEmpty
          ? const Center(child: Text('No tienes postulaciones registradas.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: postulaciones.length,
              itemBuilder: (context, i) {
                final p = postulaciones[i];
                final job = p['job'] ?? {};
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
                    subtitle: Text(
                      'Ubicación: ${job['ubicacion'] ?? 'No especificada'}\nEstado: ${p['estado'] ?? 'En revisión'}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
