// ===============================================================
// 🧭 MENÚ LATERAL PRINCIPAL – SmartRent+
// ---------------------------------------------------------------
// - Incluye módulos de Dashboard, Arriendos, Ventas, Empresas, Empleos
// - Incluye Centro de Soporte (con acceso a panel Admin)
// - Compatible con roles (usuario / empresa / admin)
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

// Tabs principales
import 'package:smartrent_plus/features/dashboard/dashboard_page.dart';
import 'package:smartrent_plus/features/arriendos/arriendos_page.dart';
import 'package:smartrent_plus/features/ventas/ventas_page.dart';
import 'package:smartrent_plus/features/empresas/empresas_page.dart';
import 'package:smartrent_plus/features/empleos/usuario_empleos_page.dart';
import 'package:smartrent_plus/features/perfil/perfil_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _selectedIndex = 0;

  // ===========================================================
  // 🔹 Páginas principales del menú inferior
  // ===========================================================
  final _pages = const <Widget>[
    DashboardPage(), // 0
    ArriendosPage(), // 1
    VentasPage(), // 2
    EmpresasPage(), // 3
    UsuarioEmpleosPage(), // 4
    PerfilPage(), // 5
  ];

  final _titles = const <String>[
    'Dashboard',
    'Arriendos',
    'Ventas',
    'Empresas',
    'Empleos',
    'Perfil',
  ];

  void _selectTab(int i) {
    setState(() => _selectedIndex = i);
    Navigator.of(context).maybePop(); // Cierra el drawer si aplica
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('SmartRent+ ${_titles[_selectedIndex]}'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ===========================================================
            // 🔹 CABECERA DEL MENÚ
            // ===========================================================
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0066FF)),
              child: Center(
                child: Text(
                  'SmartRent+ Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

            // ===========================================================
            // 🔹 SECCIÓN GENERAL
            // ===========================================================
            _section('General'),
            _rootItem(Icons.dashboard, 'Dashboard', () => _selectTab(0)),

            // ===========================================================
            // 🔹 MÓDULOS PRINCIPALES
            // ===========================================================
            _section('Módulos'),
            _submenuArriendos(),
            _submenuVentas(),
            _submenuEmpresas(),
            _submenuEmpleos(),

            // ===========================================================
            // 🔹 AYUDA Y SOPORTE
            // ===========================================================
            _section('Ayuda'),
            _submenuSoporte(),
            _rootItem(
              Icons.workspace_premium_outlined,
              'Suscripciones',
              () => Navigator.pushNamed(context, AppRoutes.suscripciones),
            ),

            // ===========================================================
            // 🔹 CUENTA
            // ===========================================================
            _section('Cuenta'),
            _rootItem(Icons.person_outline, 'Perfil', () => _selectTab(5)),

            const Divider(),

            // ===========================================================
            // 🔹 CERRAR SESIÓN
            // ===========================================================
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
            ),
          ],
        ),
      ),

      // ===========================================================
      // 🔹 CONTENIDO PRINCIPAL (según pestaña seleccionada)
      // ===========================================================
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
    );
  }

  // ===========================================================
  // 🔹 SUBMENÚ: ARRIENDOS
  // ===========================================================
  Widget _submenuArriendos() => _expansionMenu(
        icon: Icons.house_outlined,
        title: 'Arriendos',
        index: 1,
        items: [
          _miniItem(Icons.grid_view_outlined, 'Catálogo', () => _selectTab(1)),
          _miniItem(Icons.add_circle_outline, 'Crear arriendo',
              () => Navigator.pushNamed(context, AppRoutes.arriendosCrear)),
          _miniItem(Icons.inventory_2_outlined, 'Mis arriendos',
              () => Navigator.pushNamed(context, AppRoutes.arriendosMis)),
          _miniItem(
              Icons.inbox_outlined,
              'Reservas recibidas',
              () => Navigator.pushNamed(
                  context, AppRoutes.arriendosReservasEmpresa)),
          _miniItem(
              Icons.event_available_outlined,
              'Mis reservas',
              () => Navigator.pushNamed(
                  context, AppRoutes.arriendosReservasUsuario)),
          _miniItem(
              Icons.insights_outlined,
              'Estadísticas',
              () => Navigator.pushNamed(
                  context, AppRoutes.arriendosEstadisticas)),
        ],
      );

  // ===========================================================
  // 🔹 SUBMENÚ: VENTAS
  // ===========================================================
  Widget _submenuVentas() => _expansionMenu(
        icon: Icons.store_mall_directory_outlined,
        title: 'Ventas',
        index: 2,
        items: [
          _miniItem(Icons.grid_view_outlined, 'Catálogo', () => _selectTab(2)),
          _miniItem(Icons.add_box_outlined, 'Crear venta',
              () => Navigator.pushNamed(context, AppRoutes.ventasCrear)),
          _miniItem(Icons.inventory_2_outlined, 'Mis ventas',
              () => Navigator.pushNamed(context, AppRoutes.ventasMis)),
        ],
      );

  // ===========================================================
  // 🔹 SUBMENÚ: EMPRESAS
  // ===========================================================
// ===========================================================
// 🔹 SUBMENÚ: EMPRESAS
// ===========================================================
// ===========================================================
// 🔹 SUBMENÚ: EMPRESAS
// ===========================================================
  Widget _submenuEmpresas() => _expansionMenu(
        icon: Icons.apartment_outlined,
        title: 'Empresas',
        index: 3,
        items: [
          _miniItem(Icons.grid_view_outlined, 'Catálogo', () => _selectTab(3)),
          _miniItem(Icons.app_registration_outlined, 'Registro de empresa',
              () => Navigator.pushNamed(context, AppRoutes.empresasRegistro)),

          // ⭐ AGREGADO (ESTO ES LO NUEVO)
          _miniItem(
            Icons.account_circle_outlined,
            'Perfil empresa',
            () => Navigator.pushNamed(
              context,
              AppRoutes.perfilEmpresa,
              arguments: 1, // TEMPORAL — luego pondremos ID REAL
            ),
          ),
        ],
      );

  // ===========================================================
  // 🔹 SUBMENÚ: EMPLEOS
  // ===========================================================
  Widget _submenuEmpleos() => _expansionMenu(
        icon: Icons.work_outline,
        title: 'Empleos',
        index: 4,
        items: [
          _miniItem(Icons.grid_view_outlined, 'Catálogo', () => _selectTab(4)),
          _miniItem(Icons.favorite_border, 'Favoritos',
              () => Navigator.pushNamed(context, AppRoutes.empleosFavoritos)),
          _miniItem(
              Icons.how_to_reg_outlined,
              'Mis postulaciones',
              () => Navigator.pushNamed(
                  context, AppRoutes.empleosMisPostulaciones)),
          const Divider(height: 12),
          _miniItem(Icons.add_circle_outline, 'Crear empleo',
              () => Navigator.pushNamed(context, AppRoutes.empleosCrear)),
          _miniItem(
              Icons.dashboard_customize_outlined,
              'Panel empresa',
              () =>
                  Navigator.pushNamed(context, AppRoutes.empleosEmpresaPanel)),
        ],
      );

  // ===========================================================
  // 🔹 SUBMENÚ: SOPORTE (usuario + admin)
  // ===========================================================
  Widget _submenuSoporte() => _expansionMenu(
        icon: Icons.support_agent_outlined,
        title: 'Soporte',
        index: 99, // no corresponde a un tab principal
        items: [
          _miniItem(Icons.forum_outlined, 'Centro de ayuda',
              () => Navigator.pushNamed(context, AppRoutes.soporte)),
          _miniItem(Icons.help_outline, 'FAQ',
              () => Navigator.pushNamed(context, AppRoutes.soporteFaq)),
          _miniItem(Icons.report_gmailerrorred_outlined, 'Reportar problema',
              () => Navigator.pushNamed(context, AppRoutes.soporteReporte)),
          _miniItem(Icons.people_alt_outlined, 'Comunidad',
              () => Navigator.pushNamed(context, AppRoutes.soporteComunidad)),
          const Divider(height: 12),

          // 🔹 Acceso administrativo (visible solo si es Admin)
          _miniItem(
              Icons.admin_panel_settings_outlined,
              'Gestión de soporte (Admin)',
              () => Navigator.pushNamed(context, AppRoutes.adminPanel)),
        ],
      );

  // ===========================================================
  // 🔹 COMPONENTES UI (helpers)
  // ===========================================================
  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _rootItem(IconData i, String t, VoidCallback onTap) => ListTile(
        leading: Icon(i, color: Colors.grey[700]),
        title: Text(t),
        onTap: onTap,
      );

  Widget _miniItem(IconData i, String t, VoidCallback onTap) => ListTile(
        dense: true,
        leading: Icon(i),
        title: Text(t),
        onTap: () {
          Navigator.of(context).maybePop();
          onTap();
        },
      );

  Widget _expansionMenu({
    required IconData icon,
    required String title,
    required int index,
    required List<Widget> items,
  }) =>
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            icon,
            color: _selectedIndex == index
                ? AppTheme.primaryColor
                : Colors.grey[700],
          ),
          title: Text(title),
          childrenPadding: const EdgeInsets.only(left: 16, right: 8),
          children: items,
        ),
      );
}
