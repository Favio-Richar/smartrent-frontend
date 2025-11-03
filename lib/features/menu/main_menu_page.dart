// lib/features/menu/main_menu_page.dart
// ===========================================================
// 🔹 MENÚ PRINCIPAL - SmartRent+ (con submenú de Arriendos)
// ===========================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';

// Páginas principales
import 'package:smartrent_plus/features/dashboard/dashboard_page.dart';
import 'package:smartrent_plus/features/arriendos/arriendos_page.dart';
import 'package:smartrent_plus/features/ventas/ventas_page.dart';
import 'package:smartrent_plus/features/empresas/empresas_page.dart';
import 'package:smartrent_plus/features/empleos/usuario_empleos_page.dart';
import 'package:smartrent_plus/features/perfil/perfil_page.dart';

// Submódulos de Arriendos
import 'package:smartrent_plus/features/arriendos/mis_arriendos_page.dart';
import 'package:smartrent_plus/features/arriendos/crear_arriendo_page.dart';
import 'package:smartrent_plus/features/arriendos/reservas_page.dart';
import 'package:smartrent_plus/features/arriendos/estadisticas_arriendo_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _selectedIndex = 0;

  // Orden de páginas que se muestran en el body según el índice seleccionado
  final List<Widget> _pages = const [
    DashboardPage(), // 0
    ArriendosPage(), // 1 (Catálogo)
    VentasPage(), // 2
    EmpresasPage(), // 3
    UsuarioEmpleosPage(), // 4
    PerfilPage(), // 5
  ];

  final List<String> _titles = const [
    "Dashboard",
    "Arriendos",
    "Ventas",
    "Empresas",
    "Empleos",
    "Perfil",
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SmartRent+ ${_titles[_selectedIndex]}"),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0066FF)),
              child: Center(
                child: Text(
                  'SmartRent+ Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

            // General
            _buildSectionTitle("General"),
            _buildMenuItem(Icons.dashboard, "Dashboard", 0),

            // Módulos
            _buildSectionTitle("Módulos"),
            _buildArriendosSubmenu(), // 👈 Submenú Arriendos
            _buildMenuItem(Icons.store_mall_directory, "Ventas", 2),
            _buildMenuItem(Icons.apartment_outlined, "Empresas", 3),
            _buildMenuItem(Icons.work_outline, "Empleos", 4),

            // Cuenta
            _buildSectionTitle("Cuenta"),
            _buildMenuItem(Icons.person_outline, "Perfil", 5),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  // ---------- Submenú de Arriendos ----------
  Widget _buildArriendosSubmenu() {
    final selectedColor = AppTheme.primaryColor;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(
          Icons.house_outlined,
          color: _selectedIndex == 1 ? selectedColor : Colors.grey[700],
        ),
        title: const Text('Arriendos'),
        childrenPadding: const EdgeInsets.only(left: 16, right: 8),
        children: [
          // Catálogo (usa índice 1 del body principal)
          ListTile(
            leading: const Icon(Icons.grid_view_outlined),
            title: const Text('Catálogo'),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          // Crear arriendo
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Crear arriendo'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrearArriendoPage()),
              );
            },
          ),
          // Mis arriendos
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Mis arriendos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MisArriendosPage()),
              );
            },
          ),
          // Reservas recibidas (empresa)
          ListTile(
            leading: const Icon(Icons.inbox_outlined),
            title: const Text('Reservas recibidas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReservasPage(empresa: true),
                ),
              );
            },
          ),
          // Mis reservas (usuario)
          ListTile(
            leading: const Icon(Icons.event_available_outlined),
            title: const Text('Mis reservas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReservasPage(empresa: false),
                ),
              );
            },
          ),
          // Estadísticas
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: const Text('Estadísticas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EstadisticasArriendoPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------- Helpers UI ----------
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index
            ? AppTheme.primaryColor
            : Colors.grey[700],
      ),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () => _onItemTapped(index),
    );
  }
}
