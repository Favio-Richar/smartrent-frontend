// ===============================================================
// 🔹 POSTULANTES DE EMPRESA - SmartRent+
// ===============================================================
// Permite a las empresas ver quién se ha postulado a sus empleos.
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/data/services/job_service.dart';

class PostulantesEmpresaPage extends StatefulWidget {
  final int jobId;

  const PostulantesEmpresaPage({super.key, required this.jobId});

  @override
  State<PostulantesEmpresaPage> createState() => _PostulantesEmpresaPageState();
}

class _PostulantesEmpresaPageState extends State<PostulantesEmpresaPage> {
  List<dynamic> postulantes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPostulantes();
  }

  Future<void> _cargarPostulantes() async {
    try {
      final data = await JobService.obtenerPostulantesPorEmpleo(widget.jobId);
      if (!mounted) return;
      setState(() {
        postulantes = data;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar: $e")));
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postulantes'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : postulantes.isEmpty
          ? const Center(child: Text('No hay postulantes disponibles.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: postulantes.length,
              itemBuilder: (context, i) {
                final p = postulantes[i];
                final user = p['user'] ?? {};
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.indigo,
                    ),
                    title: Text(user['nombre'] ?? 'Usuario sin nombre'),
                    subtitle: Text(user['correo'] ?? 'Correo no disponible'),
                    trailing: Text(
                      p['estado'] ?? 'Pendiente',
                      style: TextStyle(
                        color: p['estado'] == 'Aprobado'
                            ? Colors.green
                            : (p['estado'] == 'Rechazado'
                                  ? Colors.red
                                  : Colors.orange),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
