// lib/routes/app_routes.dart
import 'package:flutter/material.dart';

// ---------- Splash / Auth ----------
import 'package:smartrent_plus/features/splash/splash_page.dart';
import 'package:smartrent_plus/features/auth/login_page.dart' as auth_login;
import 'package:smartrent_plus/features/auth/register_page.dart'
    as auth_register;
import 'package:smartrent_plus/features/auth/forgot_password.dart'
    as auth_forgot;

// ---------- Menú / Dashboard ----------
import 'package:smartrent_plus/features/menu/main_menu_page.dart';
import 'package:smartrent_plus/features/dashboard/dashboard_page.dart';

// ---------- Arriendos ----------
import 'package:smartrent_plus/features/arriendos/arriendos_page.dart';
import 'package:smartrent_plus/features/arriendos/mis_arriendos_page.dart';
import 'package:smartrent_plus/features/arriendos/crear_arriendo_page.dart';
import 'package:smartrent_plus/features/arriendos/reservas_page.dart';
import 'package:smartrent_plus/features/arriendos/estadisticas_arriendo_page.dart';

// ---------- Ventas ----------
import 'package:smartrent_plus/features/ventas/ventas_page.dart';
import 'package:smartrent_plus/features/ventas/crear_venta_page.dart';
import 'package:smartrent_plus/features/ventas/mis_ventas_page.dart';

// ---------- Empresas ----------
import 'package:smartrent_plus/features/empresas/empresas_page.dart';
import 'package:smartrent_plus/features/empresas/registro_empresa_page.dart';

// ---------- Empleos ----------
import 'package:smartrent_plus/features/empleos/usuario_empleos_page.dart';
import 'package:smartrent_plus/features/empleos/crear_empleo_page.dart';
import 'package:smartrent_plus/features/empleos/favoritos_page.dart';
import 'package:smartrent_plus/features/empleos/mis_postulaciones_page.dart';
import 'package:smartrent_plus/features/empleos/empresa_panel_page.dart'; // ✅ NUEVO

// ---------- Soporte / Suscripciones / Perfil ----------
import 'package:smartrent_plus/features/soporte/soporte_page.dart';
import 'package:smartrent_plus/features/soporte/faq_page.dart';
import 'package:smartrent_plus/features/soporte/reporte_problema_page.dart';
import 'package:smartrent_plus/features/suscripciones/suscripciones_page.dart';
import 'package:smartrent_plus/features/perfil/perfil_page.dart';

class AppRoutes {
  // ---- AUTH / CORE ----
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String mainMenu = '/main-menu';
  static const String dashboard = '/dashboard';

  // ---- ARRIENDOS ----
  static const String arriendos = '/arriendos';
  static const String arriendosCrear = '/arriendos/crear';
  static const String arriendosMis = '/arriendos/mis';
  static const String arriendosReservasEmpresa = '/arriendos/reservas';
  static const String arriendosReservasUsuario = '/arriendos/mis-reservas';
  static const String arriendosEstadisticas = '/arriendos/estadisticas';

  // ---- VENTAS ----
  static const String ventas = '/ventas';
  static const String ventasCrear = '/ventas/crear';
  static const String ventasMis = '/ventas/mis';

  // ---- EMPRESAS ----
  static const String empresas = '/empresas';
  static const String empresasRegistro = '/empresas/registro';

  // ---- EMPLEOS ----
  static const String empleos = '/empleos';
  static const String empleosCrear = '/empleos/crear';
  static const String empleosFavoritos = '/empleos/favoritos';
  static const String empleosMisPostulaciones = '/empleos/mis-postulaciones';
  static const String empleosEmpresaPanel = '/empleos/empresa/panel'; // ✅ NUEVO

  // ---- SOPORTE / SUSCRIPCIONES / PERFIL ----
  static const String soporte = '/soporte';
  static const String soporteFaq = '/soporte/faq';
  static const String soporteReporte = '/soporte/reporte';
  static const String suscripciones = '/suscripciones';
  static const String perfil = '/perfil';

  // ---------- Pantallas SIN argumentos ----------
  static final Map<String, WidgetBuilder> routes = {
    // Core
    splash: (_) => const SplashPage(),
    login: (_) => const auth_login.LoginPage(),
    register: (_) => const auth_register.UserRegisterPage(),
    forgotPassword: (_) => const auth_forgot.ForgotPasswordPage(),
    mainMenu: (_) => const MainMenuPage(),
    dashboard: (_) => const DashboardPage(),

    // Arriendos
    arriendos: (_) => const ArriendosPage(),
    arriendosCrear: (_) => const CrearArriendoPage(),
    arriendosMis: (_) => const MisArriendosPage(),
    arriendosReservasEmpresa: (_) => const ReservasPage(empresa: true),
    arriendosReservasUsuario: (_) => const ReservasPage(empresa: false),
    arriendosEstadisticas: (_) => const EstadisticasArriendoPage(),

    // Ventas
    ventas: (_) => const VentasPage(),
    ventasCrear: (_) => const CrearVentaPage(),
    ventasMis: (_) => const MisVentasPage(),

    // Empresas
    empresas: (_) => const EmpresasPage(),
    empresasRegistro: (_) => const RegistroEmpresaPage(),

    // Empleos (solo pantallas SIN argumentos)
    empleos: (_) => const UsuarioEmpleosPage(),
    empleosCrear: (_) => const CrearEmpleoPage(),
    empleosFavoritos: (_) => const FavoritosPage(),
    empleosMisPostulaciones: (_) => const MisPostulacionesPage(),
    empleosEmpresaPanel: (_) => const EmpresaPanelPage(), // ✅ NUEVO
    // Soporte / Suscripciones / Perfil
    soporte: (_) => const SoportePage(),
    soporteFaq: (_) => const FaqPage(),
    soporteReporte: (_) => const ReporteProblemaPage(),
    suscripciones: (_) => const SuscripcionesPage(),
    perfil: (_) => const PerfilPage(),
  };
}

// (Sin onGenerateRoute; las pantallas que requieren jobId se abren con MaterialPageRoute)
