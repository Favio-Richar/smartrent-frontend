import 'package:flutter/material.dart';

// --- Autenticación ---
import 'package:smartrent_plus/features/splash/splash_page.dart';
import 'package:smartrent_plus/features/auth/login_page.dart' as auth_login;
import 'package:smartrent_plus/features/auth/register_page.dart'
    as auth_register;
import 'package:smartrent_plus/features/auth/forgot_password.dart'
    as auth_forgot;

// --- Dashboard y menú ---
import 'package:smartrent_plus/features/menu/main_menu_page.dart';
import 'package:smartrent_plus/features/dashboard/dashboard_page.dart';

// --- Empresas ---
import 'package:smartrent_plus/features/empresas/empresas_page.dart';
import 'package:smartrent_plus/features/perfil/perfil_empresa_page.dart';

// --- Arriendos ---
import 'package:smartrent_plus/features/arriendos/arriendos_page.dart';
import 'package:smartrent_plus/features/arriendos/mis_arriendos_page.dart';
import 'package:smartrent_plus/features/arriendos/crear_arriendo_page.dart';
import 'package:smartrent_plus/features/arriendos/reservas_page.dart';
import 'package:smartrent_plus/features/arriendos/estadisticas_arriendo_page.dart';
import 'package:smartrent_plus/features/arriendos/detalle_arriendo_page.dart';
import 'package:smartrent_plus/features/arriendos/resenas_page.dart';

// --- Ventas / Empleos / Perfil ---
import 'package:smartrent_plus/features/ventas/ventas_page.dart';
import 'package:smartrent_plus/features/empleos/usuario_empleos_page.dart';
import 'package:smartrent_plus/features/empleos/favoritos_page.dart';
import 'package:smartrent_plus/features/perfil/perfil_page.dart';
import 'package:smartrent_plus/features/perfil/editar_perfil_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String mainMenu = '/main-menu';
  static const String dashboard = '/dashboard';

  static const String empresas = '/empresas';
  static const String perfilEmpresa = '/empresas/perfil';

  static const String arriendos = '/arriendos';
  static const String arriendosMis = '/arriendos/mis';
  static const String arriendosCrear = '/arriendos/crear';
  static const String arriendosReservasEmpresa = '/arriendos/reservas';
  static const String arriendosReservasUsuario = '/arriendos/mis-reservas';
  static const String arriendosEstadisticas = '/arriendos/estadisticas';
  static const String arriendosDetalle = '/arriendos/detalle';
  static const String arriendosResenas = '/arriendos/resenas';

  static const String ventas = '/ventas';
  static const String empleos = '/empleos';
  static const String favoritos = '/favoritos';

  static const String perfil = '/perfil';
  static const String editarPerfil = '/editar-perfil';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashPage(),
    login: (_) => const auth_login.LoginPage(),
    register: (_) => const auth_register.UserRegisterPage(), // 👈 clase exacta
    forgotPassword: (_) => const auth_forgot.ForgotPasswordPage(),

    mainMenu: (_) => const MainMenuPage(),
    dashboard: (_) => const DashboardPage(),

    empresas: (_) => const EmpresasPage(),

    arriendos: (_) => const ArriendosPage(),
    arriendosMis: (_) => const MisArriendosPage(),
    arriendosCrear: (_) => const CrearArriendoPage(),
    arriendosReservasEmpresa: (_) => const ReservasPage(empresa: true),
    arriendosReservasUsuario: (_) => const ReservasPage(empresa: false),
    arriendosEstadisticas: (_) => const EstadisticasArriendoPage(),

    ventas: (_) => const VentasPage(),
    empleos: (_) => const UsuarioEmpleosPage(),
    favoritos: (_) => const FavoritosPage(),

    perfil: (_) => const PerfilPage(),
    editarPerfil: (_) => const EditarPerfilPage(user: {}),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case arriendosDetalle:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DetalleArriendoPage(propertyId: id),
          settings: settings,
        );
      case arriendosResenas:
        final companyId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ResenasPage(companyId: companyId),
          settings: settings,
        );
      case perfilEmpresa:
        final empresaIdArg = settings.arguments;
        final id = empresaIdArg.toString();
        return MaterialPageRoute(
          builder: (_) => PerfilEmpresaPage(companyId: id),
          settings: settings,
        );
    }
    return null;
  }
}
