// ===========================================================
// 🔹 MENÚ PRINCIPAL - SmartRent+
// Contenedor con menú lateral y navegación entre módulos
// ===========================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/features/dashboard/dashboard_page.dart';
import 'package:smartrent_plus/features/arriendos/arriendos_page.dart';
import 'package:smartrent_plus/features/ventas/ventas_page.dart';
import 'package:smartrent_plus/features/empleos/empleos_page.dart';
import 'package:smartrent_plus/features/suscripciones/suscripciones_page.dart';
import 'package:smartrent_plus/features/perfil/perfil_page.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ArriendosPage(),
    VentasPage(),
    EmpleosPage(),
    SuscripcionesPage(),
    PerfilPage(),
  ];

  final List<String> _titles = const [
    "Dashboard",
    "Arriendos",
    "Ventas",
    "Empleos",
    "Suscripciones",
    "Perfil",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            _buildMenuItem(Icons.dashboard, "Dashboard", 0),
            _buildMenuItem(Icons.house_outlined, "Arriendos", 1),
            _buildMenuItem(Icons.store_mall_directory, "Ventas", 2),
            _buildMenuItem(Icons.work_outline, "Empleos", 3),
            _buildMenuItem(Icons.star_border, "Suscripciones", 4),
            _buildMenuItem(Icons.person_outline, "Perfil", 5),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
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
