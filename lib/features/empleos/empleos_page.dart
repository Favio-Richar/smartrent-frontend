// ===============================================================
// 🔹 CENTRO DE EMPLEOS - SmartRent+
// ===============================================================
// Panel central del módulo. Permite a usuarios y empresas:
// - Buscar empleos
// - Ver postulaciones, favoritos
// - Acceder al panel empresarial y crear ofertas
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/features/empleos/crear_empleo_page.dart';
import 'package:smartrent_plus/features/empleos/mis_postulaciones_page.dart';
import 'package:smartrent_plus/features/empleos/empresa_panel_page.dart';
import 'package:smartrent_plus/features/empleos/favoritos_page.dart';
import 'package:smartrent_plus/features/empleos/usuario_empleos_page.dart';

class EmpleosPage extends StatelessWidget {
  const EmpleosPage({super.key});

  Widget _panelBoton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Centro de Empleos'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Explora y gestiona empleos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar empleo, empresa o categoría...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _panelBoton(
                  icon: Icons.work_outline,
                  label: 'Buscar\nEmpleos',
                  color: Colors.blueAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UsuarioEmpleosPage(),
                    ),
                  ),
                ),
                _panelBoton(
                  icon: Icons.assignment_turned_in_outlined,
                  label: 'Mis\nPostulaciones',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MisPostulacionesPage(),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _panelBoton(
                  icon: Icons.star_border_rounded,
                  label: 'Favoritos',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritosPage()),
                  ),
                ),
                _panelBoton(
                  icon: Icons.add_box_outlined,
                  label: 'Publicar\nEmpleo',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CrearEmpleoPage()),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _panelBoton(
                  icon: Icons.dashboard_customize_outlined,
                  label: 'Panel\nEmpresa',
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmpresaPanelPage()),
                  ),
                ),
                _panelBoton(
                  icon: Icons.people_alt_outlined,
                  label: 'Postulantes',
                  color: Colors.indigo,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Últimos empleos publicados",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            const Center(child: Text("No hay empleos disponibles.")),
          ],
        ),
      ),
    );
  }
}
