// ===============================================================
// 🔹 BUSCADOR DE EMPLEOS (USUARIOS)
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/data/services/job_service.dart';
import 'package:smartrent_plus/features/empleos/detalle_empleo_page.dart';

class UsuarioEmpleosPage extends StatefulWidget {
  const UsuarioEmpleosPage({super.key});

  @override
  State<UsuarioEmpleosPage> createState() => _UsuarioEmpleosPageState();
}

class _UsuarioEmpleosPageState extends State<UsuarioEmpleosPage> {
  List<dynamic> empleos = [];
  bool cargando = false;
  String query = '';

  Future<void> _buscar() async {
    setState(() => cargando = true);
    try {
      final data = await JobService.buscarEmpleos(query);
      if (!mounted) return;
      setState(() {
        empleos = data;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Empleos'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por empresa, título o ubicación...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => query = v,
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 15),
            cargando
                ? const CircularProgressIndicator()
                : Expanded(
                    child: empleos.isEmpty
                        ? const Center(
                            child: Text('No se encontraron resultados.'),
                          )
                        : ListView.builder(
                            itemCount: empleos.length,
                            itemBuilder: (context, i) {
                              final job = empleos[i];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: ListTile(
                                  title: Text(job['titulo'] ?? ''),
                                  subtitle: Text(
                                    '${job['company']?['nombreEmpresa'] ?? ''} • ${job['ubicacion'] ?? ''}',
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetalleEmpleoPage(
                                        empleoId: job['id'],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
