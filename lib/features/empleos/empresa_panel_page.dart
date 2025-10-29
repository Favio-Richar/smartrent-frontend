// ===============================================================
// 🔹 PANEL DE EMPRESA - SmartRent+
// ===============================================================
// Permite a una empresa gestionar sus publicaciones de empleo:
// - Ver empleos publicados
// - Crear nuevos
// - Ver postulantes
// - Eliminar empleos
// ===============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/data/services/job_service.dart';
import 'package:smartrent_plus/features/empleos/crear_empleo_page.dart';
import 'package:smartrent_plus/features/empleos/postulantes_empresa_page.dart';
import 'package:smartrent_plus/features/empleos/detalle_empleo_page.dart';

class EmpresaPanelPage extends StatefulWidget {
  const EmpresaPanelPage({super.key});

  @override
  State<EmpresaPanelPage> createState() => _EmpresaPanelPageState();
}

class _EmpresaPanelPageState extends State<EmpresaPanelPage> {
  List<dynamic> empleos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEmpleos();
  }

  // ============================================================
  // 🔹 Cargar empleos de la empresa logueada
  // ============================================================
  Future<void> _cargarEmpleos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getInt('userId');

      if (companyId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ No se encontró ID de empresa.")),
        );
        setState(() => cargando = false);
        return;
      }

      final data = await JobService.obtenerEmpleosEmpresa(companyId);
      if (!mounted) return;
      setState(() {
        empleos = data;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar empleos: $e")));
      setState(() => cargando = false);
    }
  }

  // ============================================================
  // 🔹 Eliminar empleo
  // ============================================================
  Future<void> _eliminar(int id) async {
    final ok = await JobService.eliminarEmpleo(id);
    if (!mounted) return;
    if (ok) {
      _cargarEmpleos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Empleo eliminado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error al eliminar el empleo')),
      );
    }
  }

  // ============================================================
  // 🧱 Interfaz principal
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Empresa'),
        backgroundColor: AppTheme.primaryColor,
      ),

      // ➕ Botón de creación de empleo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearEmpleoPage()),
          );
          if (!mounted) return;
          _cargarEmpleos();
        },
        label: const Text('Nuevo Empleo'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),

      // 🧭 Contenido principal
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : empleos.isEmpty
          ? const Center(
              child: Text(
                'No hay empleos publicados todavía.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarEmpleos,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: empleos.length,
                itemBuilder: (context, i) {
                  final job = empleos[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(
                        Icons.work_outline,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                        job['titulo'] ?? 'Sin título',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(job['ubicacion'] ?? 'Sin ubicación'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'postulantes') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PostulantesEmpresaPage(jobId: job['id']),
                              ),
                            );
                          } else if (value == 'eliminar') {
                            _eliminar(job['id']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'postulantes',
                            child: Text('Ver postulantes'),
                          ),
                          const PopupMenuItem(
                            value: 'eliminar',
                            child: Text('Eliminar'),
                          ),
                        ],
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
            ),
    );
  }
}
