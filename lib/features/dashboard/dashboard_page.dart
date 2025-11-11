// lib/features/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_controller.dart';
import 'dashboard_widgets.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(),
      child: Consumer<DashboardController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final nombre = ctrl.usuarioActual?['nombre'] ?? 'Usuario';
          final rol = ctrl.isCompany ? 'Empresa' : 'Usuario';
          final avatarUrl = ctrl.usuarioActual?['imagen'] ??
              'https://i.pravatar.cc/150?img=8';

          return Scaffold(
            backgroundColor: const Color(0xFFF4F6FA),
            body: RefreshIndicator(
              onRefresh: ctrl.initDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(avatarUrl),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola, $nombre 👋',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                rol == 'Empresa'
                                    ? 'Administra tus anuncios y métricas'
                                    : 'Explora arriendos, ventas y empleos',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      SearchBarWidget(onSearch: (v) {}),
                      const SizedBox(height: 25),
                      const Text(
                        "Tu resumen general",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          _StatButton(
                            icon: Icons.house_rounded,
                            color: Colors.indigo,
                            label: "Arriendos",
                            value: "12",
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.arriendos,
                            ),
                          ),
                          _StatButton(
                            icon: Icons.sell_rounded,
                            color: Colors.green,
                            label: "Ventas",
                            value: "8",
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.ventas),
                          ),
                          _StatButton(
                            icon: Icons.work_rounded,
                            color: Colors.deepOrange,
                            label: "Empleos",
                            value: "5",
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.empleos),
                          ),
                          _StatButton(
                            icon: Icons.favorite_rounded,
                            color: Colors.pinkAccent,
                            label: "Favoritos",
                            value: "7",
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.empleosFavoritos,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _sectionTitle('🏠 Propiedades destacadas'),
                      PropertyCarousel(listado: ctrl.propiedades),
                      const SizedBox(height: 25),
                      _sectionTitle('💼 Ofertas laborales'),
                      JobsCarousel(listado: ctrl.empleos),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );
}

class _StatButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      // 🔧 Reemplazo sin deprecations:
      splashColor: color.withValues(alpha: 0.2),
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // 🔧 Reemplazo sin deprecations:
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
