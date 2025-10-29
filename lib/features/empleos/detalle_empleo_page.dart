// ===============================================================
// 🔹 DETALLE DE EMPLEO - SmartRent+
// ===============================================================
import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/job_service.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';

class DetalleEmpleoPage extends StatefulWidget {
  final int empleoId;
  const DetalleEmpleoPage({super.key, required this.empleoId});

  @override
  State<DetalleEmpleoPage> createState() => _DetalleEmpleoPageState();
}

class _DetalleEmpleoPageState extends State<DetalleEmpleoPage> {
  Map<String, dynamic>? empleo;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await JobService.obtenerDetalle(widget.empleoId);
      if (!mounted) return;
      setState(() {
        empleo = data;
        cargando = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar: $e')));
      setState(() => cargando = false);
    }
  }

  Future<void> _postular() async {
    final ok = await JobService.postularEmpleo(widget.empleoId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '✅ Postulación enviada' : '❌ Error al postular'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Empleo'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    empleo!['titulo'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(empleo!['descripcion'] ?? ''),
                  const SizedBox(height: 15),
                  Text('Ubicación: ${empleo!['ubicacion'] ?? ''}'),
                  Text('Contrato: ${empleo!['tipoContrato'] ?? ''}'),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _postular,
                    icon: const Icon(Icons.work_outline),
                    label: const Text('Postular ahora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
