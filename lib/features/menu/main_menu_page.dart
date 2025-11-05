import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

// Tabs
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
    Navigator.of(context).maybePop(); // cierra el drawer si aplica
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0066FF)),
              child: Center(
                child: Text(
                  'SmartRent+ Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

            _section('General'),
            _rootItem(Icons.dashboard, 'Dashboard', () => _selectTab(0)),

            _section('Módulos'),
            _submenuArriendos(),
            _submenuVentas(),
            _submenuEmpresas(),
            _submenuEmpleos(),

            _section('Ayuda'),
            _submenuSoporte(),
            _rootItem(
              Icons.workspace_premium_outlined,
              'Suscripciones',
              () => Navigator.pushNamed(context, AppRoutes.suscripciones),
            ),

            _section('Cuenta'),
            _rootItem(Icons.person_outline, 'Perfil', () => _selectTab(5)),

            const Divider(),
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

      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
    );
  }

  // ---------------- Submenús ----------------

  Widget _submenuArriendos() => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      leading: Icon(
        Icons.house_outlined,
        color: _selectedIndex == 1 ? AppTheme.primaryColor : Colors.grey[700],
      ),
      title: const Text('Arriendos'),
      childrenPadding: const EdgeInsets.only(left: 16, right: 8),
      children: [
        _miniItem(Icons.grid_view_outlined, 'Catálogo', () => _selectTab(1)),
        _miniItem(
          Icons.add_circle_outline,
          'Crear arriendo',
          () => Navigator.pushNamed(context, AppRoutes.arriendosCrear),
        ),
        _miniItem(
          Icons.inventory_2_outlined,
          'Mis arriendos',
          () => Navigator.pushNamed(context, AppRoutes.arriendosMis),
        ),
        _miniItem(
          Icons.inbox_outlined,
          'Reservas recibidas',
          () =>
              Navigator.pushNamed(context, AppRoutes.arriendosReservasEmpresa),
        ),
        _miniItem(
          Icons.event_available_outlined,
          'Mis reservas',
          () =>
              Navigator.pushNamed(context, AppRoutes.arriendosReservasUsuario),
        ),
        _miniItem(
          Icons.insights_outlined,
          'Estadísticas',
          () => Navigator.pushNamed(context, AppRoutes.arriendosEstadisticas),
        ),
      ],
    ),
  );

  Widget _submenuVentas() => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      leading: Icon(
        Icons.store_mall_directory_outlined,
        color: _selectedIndex == 2 ? AppTheme.primaryColor : Colors.grey[700],
      ),
      title: const Text('Ventas'),
      childrenPadding: const EdgeInsets.only(left: 16, right: 8),
      children: [
        _miniItem(Icons.grid_view_outlined, 'Catálogo', () => _selectTab(2)),
        _miniItem(
          Icons.add_box_outlined,
          'Crear venta',
          () => Navigator.pushNamed(context, AppRoutes.ventasCrear),
        ),
        _miniItem(
          Icons.inventory_2_outlined,
          'Mis ventas',
          () => Navigator.pushNamed(context, AppRoutes.ventasMis),
        ),
      ],
    ),
  );

  Widget _submenuEmpresas() => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      leading: Icon(
        Icons.apartment_outlined,
        color: _selectedIndex == 3 ? AppTheme.primaryColor : Colors.grey[700],
      ),
      title: const Text('Empresas'),
      childrenPadding: const EdgeInsets.only(left: 16, right: 8),
      children: [
        _miniItem(Icons.grid_view_outlined, 'Catálogo', () => _selectTab(3)),
        _miniItem(
          Icons.app_registration_outlined,
          'Registro de empresa',
          () => Navigator.pushNamed(context, AppRoutes.empresasRegistro),
        ),
      ],
    ),
  );

  Widget _submenuEmpleos() => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      leading: Icon(
        Icons.work_outline,
        color: _selectedIndex == 4 ? AppTheme.primaryColor : Colors.grey[700],
      ),
      title: const Text('Empleos'),
      childrenPadding: const EdgeInsets.only(left: 16, right: 8),
      children: [
        // Usuario
        _miniItem(Icons.grid_view_outlined, 'Catálogo', () => _selectTab(4)),
        _miniItem(
          Icons.favorite_border,
          'Favoritos',
          () => Navigator.pushNamed(context, AppRoutes.empleosFavoritos),
        ),
        _miniItem(
          Icons.how_to_reg_outlined,
          'Mis postulaciones',
          () => Navigator.pushNamed(context, AppRoutes.empleosMisPostulaciones),
        ),

        const Divider(height: 12),

        // Empresa
        _miniItem(
          Icons.add_circle_outline,
          'Crear empleo',
          () => Navigator.pushNamed(context, AppRoutes.empleosCrear),
        ),
        _miniItem(
          Icons.dashboard_customize_outlined,
          'Panel empresa',
          () => Navigator.pushNamed(context, AppRoutes.empleosEmpresaPanel),
        ), // ✅
      ],
    ),
  );

  Widget _submenuSoporte() => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      leading: const Icon(Icons.support_agent_outlined),
      title: const Text('Soporte'),
      childrenPadding: const EdgeInsets.only(left: 16, right: 8),
      children: [
        _miniItem(
          Icons.forum_outlined,
          'Centro de ayuda',
          () => Navigator.pushNamed(context, AppRoutes.soporte),
        ),
        _miniItem(
          Icons.help_outline,
          'FAQ',
          () => Navigator.pushNamed(context, AppRoutes.soporteFaq),
        ),
        _miniItem(
          Icons.report_gmailerrorred_outlined,
          'Reportar problema',
          () => Navigator.pushNamed(context, AppRoutes.soporteReporte),
        ),
      ],
    ),
  );

  // ---------------- Helpers UI ----------------

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
      Navigator.of(context).maybePop(); // evita crash
      onTap();
    },
  );
}
