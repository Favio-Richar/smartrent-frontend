// ===============================================================
// 🧩 PANEL ADMINISTRATIVO – SmartRent+
// ---------------------------------------------------------------
// - Interfaz moderna con pestañas superiores (TabBar)
// - Secciones: Dashboard | Usuarios | Empresas | Publicaciones |
//   Soporte | Suscripciones | Roles | Configuración
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';

// ✅ Importa las subpáginas desde la carpeta admin
import 'package:smartrent_plus/features/admin/admin_dashboard_page.dart';
import 'package:smartrent_plus/features/admin/admin_users_page.dart';
import 'package:smartrent_plus/features/admin/admin_empresas_page.dart';
import 'package:smartrent_plus/features/admin/admin_publicaciones_page.dart';
import 'package:smartrent_plus/features/admin/admin_soporte_page.dart';
import 'package:smartrent_plus/features/admin/admin_suscripciones_page.dart';
import 'package:smartrent_plus/features/admin/admin_roles_page.dart';
import 'package:smartrent_plus/features/admin/admin_config_page.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 🔹 Pestañas superiores
  final List<Tab> _tabs = const [
    Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
    Tab(icon: Icon(Icons.people_outline), text: 'Usuarios'),
    Tab(icon: Icon(Icons.apartment_outlined), text: 'Empresas'),
    Tab(icon: Icon(Icons.article_outlined), text: 'Publicaciones'),
    Tab(icon: Icon(Icons.support_agent_outlined), text: 'Soporte'),
    Tab(icon: Icon(Icons.workspace_premium_outlined), text: 'Suscripciones'),
    Tab(icon: Icon(Icons.verified_user_outlined), text: 'Roles'),
    Tab(icon: Icon(Icons.settings_outlined), text: 'Configuración'),
  ];

  // 🔹 Contenido de cada pestaña
  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminUsersPage(),
    const AdminEmpresasPage(),
    const AdminPublicacionesPage(),
    const AdminSoportePage(),
    const AdminSuscripcionesPage(),
    const AdminRolesPage(),
    const AdminConfigPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 3,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: _tabs,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: _pages,
        ),
      ),
    );
  }
}
