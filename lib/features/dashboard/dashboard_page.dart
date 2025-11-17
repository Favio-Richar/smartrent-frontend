// ===============================================================
// 🔹 DASHBOARD PAGE - SmartRent+ (Corregido y mejorado FINAL)
// ===============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_controller.dart';
import 'dashboard_widgets.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? profileImagePath; // Puede ser archivo o URL
  String nombreLocal = "Usuario";
  String descripcionLocal = "";

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  // ============================================================
  // 🔹 Cargar datos guardados localmente (nombre, foto, desc)
  // ============================================================
  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      profileImagePath = prefs.getString("profileImage");
      nombreLocal = prefs.getString("nombreUsuario") ?? "Usuario";
      descripcionLocal = prefs.getString("descripcion") ?? "";
    });
  }

  // ============================================================
  // 🔹 Detectar si la imagen es URL o archivo local
  // ============================================================
  ImageProvider _getProfileImage() {
    if (profileImagePath == null) {
      return const AssetImage("assets/images/profile_placeholder.png");
    }

    // Caso 1: URL
    if (profileImagePath!.startsWith("http")) {
      return NetworkImage(profileImagePath!);
    }

    // Caso 2: archivo interno
    if (File(profileImagePath!).existsSync()) {
      return FileImage(File(profileImagePath!));
    }

    // Fallback
    return const AssetImage("assets/images/profile_placeholder.png");
  }

  // ============================================================
  // 🔵 NAVEGAR A PERFIL Y VOLVER ACTUALIZADO
  // ============================================================
  Future<void> _goToPerfil() async {
    await Navigator.pushNamed(context, AppRoutes.perfil);

    await _loadLocalData(); // 🔥 Recarga nombre + foto al volver
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController()..initDashboard(),
      child: Consumer<DashboardController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Nombre del backend (si existe)
          final nombreBackend = ctrl.usuarioActual?['nombre'];

          // PRIORIDAD:
          // 1) nombreLocal guardado
          // 2) backend
          // 3) "Usuario"
          final nombreFinal =
              (nombreLocal != "Usuario" && nombreLocal.isNotEmpty)
                  ? nombreLocal
                  : (nombreBackend ?? "Usuario");

          return Scaffold(
            backgroundColor: const Color(0xFFF4F6FA),
            body: RefreshIndicator(
              onRefresh: () async {
                await ctrl.initDashboard();
                await _loadLocalData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // ============================================================
                      // 🔵 CABECERA DEL DASHBOARD (con botón en foto)
                      // ============================================================
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _goToPerfil,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: _getProfileImage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola, $nombreFinal 👋',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                descripcionLocal.isNotEmpty
                                    ? descripcionLocal
                                    : "Explora arriendos, ventas y empleos",
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
                                context, AppRoutes.arriendos),
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
                                context, AppRoutes.empleosFavoritos),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withOpacity(0.2),
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
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
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
