// ===============================================================
// 🧭 RUTAS PRINCIPALES - SmartRent+ (versión FINAL SIN ERRORES)
// ===============================================================

import 'package:flutter/material.dart';

// Splash / Auth
import 'package:smartrent_plus/features/splash/splash_page.dart';
import 'package:smartrent_plus/features/auth/login_page.dart' as auth_login;
import 'package:smartrent_plus/features/auth/register_page.dart'
    as auth_register;
import 'package:smartrent_plus/features/auth/forgot_password.dart'
    as auth_forgot;

// Menú / Dashboard
import 'package:smartrent_plus/features/menu/main_menu_page.dart';
import 'package:smartrent_plus/features/dashboard/dashboard_page.dart';

// Arriendos
import 'package:smartrent_plus/features/arriendos/arriendos_page.dart';
import 'package:smartrent_plus/features/arriendos/mis_arriendos_page.dart';
import 'package:smartrent_plus/features/arriendos/crear_arriendo_page.dart';
import 'package:smartrent_plus/features/arriendos/reservas_page.dart';
import 'package:smartrent_plus/features/arriendos/estadisticas_arriendo_page.dart';

// Ventas
import 'package:smartrent_plus/features/ventas/ventas_page.dart';
import 'package:smartrent_plus/features/ventas/crear_venta_page.dart';
import 'package:smartrent_plus/features/ventas/mis_ventas_page.dart';

// Empresas
import 'package:smartrent_plus/features/empresas/empresas_page.dart';
import 'package:smartrent_plus/features/empresas/registro_empresa_page.dart';

// ⭐ AGREGADO (IMPORTANTE)
import 'package:smartrent_plus/features/empresas/perfil_empresa_page.dart';

// Empleos
import 'package:smartrent_plus/features/empleos/usuario_empleos_page.dart';
import 'package:smartrent_plus/features/empleos/crear_empleo_page.dart';
import 'package:smartrent_plus/features/empleos/favoritos_page.dart';
import 'package:smartrent_plus/features/empleos/mis_postulaciones_page.dart';
import 'package:smartrent_plus/features/empleos/empresa_panel_page.dart';

// Soporte
import 'package:smartrent_plus/features/soporte/soporte_page.dart';
import 'package:smartrent_plus/features/soporte/faq_page.dart';
import 'package:smartrent_plus/features/soporte/reporte_problema_page.dart';
import 'package:smartrent_plus/features/soporte/contacto_page.dart';
import 'package:smartrent_plus/features/soporte/comunidad_page.dart';

// Admin
import 'package:smartrent_plus/features/admin/admin_panel_page.dart';

// Suscripciones
import 'package:smartrent_plus/features/suscripciones/suscripciones_page.dart';
import 'package:smartrent_plus/features/suscripciones/pago_suscripcion_page.dart';
import 'package:smartrent_plus/features/suscripciones/pago_exitoso_page.dart';
import 'package:smartrent_plus/features/suscripciones/pago_fallido_page.dart';

import 'package:smartrent_plus/features/suscripciones/pago_webpay_page.dart';

// Perfil
import 'package:smartrent_plus/features/perfil/perfil_page.dart';

// ⭐ Import correcto (ARREGLADO)
import 'package:smartrent_plus/features/comentarios/comentario_page.dart';

// ⭐ Placeholder de detalle (CREADO para evitar error)
class DetalleComentarioPage extends StatelessWidget {
  const DetalleComentarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle Comentario")),
      body: const Center(
        child: Text(
          "Pantalla DetalleComentarioPage (placeholder temporal)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String mainMenu = '/main-menu';
  static const String dashboard = '/dashboard';

  // Arriendos
  static const String arriendos = '/arriendos';
  static const String arriendosCrear = '/arriendos/crear';
  static const String arriendosMis = '/arriendos/mis';
  static const String arriendosReservasEmpresa = '/arriendos/reservas';
  static const String arriendosReservasUsuario = '/arriendos/mis-reservas';
  static const String arriendosEstadisticas = '/arriendos/estadisticas';

  // Ventas
  static const String ventas = '/ventas';
  static const String ventasCrear = '/ventas/crear';
  static const String ventasMis = '/ventas/mis';

  // Empresas
  static const String empresas = '/empresas';
  static const String empresasRegistro = '/empresas/registro';

  // Agregado
  static const String perfilEmpresa = '/empresa/perfil';

  // Empleos
  static const String empleos = '/empleos';
  static const String empleosCrear = '/empleos/crear';
  static const String empleosFavoritos = '/empleos/favoritos';
  static const String empleosMisPostulaciones = '/empleos/mis-postulaciones';
  static const String empleosEmpresaPanel = '/empleos/empresa/panel';

  // Soporte
  static const String soporte = '/soporte';
  static const String soporteFaq = '/soporte/faq';
  static const String soporteReporte = '/soporte/reporte';
  static const String soporteContacto = '/soporte/contacto';
  static const String soporteComunidad = '/soporte/comunidad';

  // Admin
  static const String adminPanel = '/admin/panel';

  // Suscripciones
  static const String suscripciones = '/suscripciones';
  static const String pagoSuscripcion = '/suscripciones/pago-suscripcion';

  static const String pagoWebPay = '/suscripciones/pago-webpay';
  static const String pagoExitoso = '/suscripciones/pago-exitoso';
  static const String pagoFallido = '/suscripciones/pago-fallido';

  // Perfil
  static const String perfil = '/perfil';

  // Comentarios
  static const String comentar = '/comentar';
  static const String comentarioDetalle = '/comentarios/detalle';

  // ============================================================
  // MAPA DE RUTAS
  // ============================================================
  static final Map<String, WidgetBuilder> routes = {
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

    perfilEmpresa: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return PerfilEmpresaPage(companyId: id);
    },

    // Empleos
    empleos: (_) => const UsuarioEmpleosPage(),
    empleosCrear: (_) => const CrearEmpleoPage(),
    empleosFavoritos: (_) => const FavoritosPage(),
    empleosMisPostulaciones: (_) => const MisPostulacionesPage(),
    empleosEmpresaPanel: (_) => const EmpresaPanelPage(),

    // Soporte
    soporte: (_) => const SoportePage(),
    soporteFaq: (_) => const FaqPage(),
    soporteReporte: (_) => const ReporteProblemaPage(),
    soporteContacto: (_) => const ContactoSoportePage(),
    soporteComunidad: (_) => const ComunidadPage(),

    // Admin
    adminPanel: (_) => const AdminPanelPage(),

    // Suscripciones
    suscripciones: (_) => const SuscripcionesPage(),
    pagoSuscripcion: (_) => const PagoSuscripcionPage(
          plan: "PREMIUM",
          precio: "\$9.990",
          color: Colors.indigo,
        ),

    pagoWebPay: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PagoWebPayPage(
        url: args["url"],
        token: args["token"],
      );
    },

    pagoExitoso: (_) => const PagoExitosoPage(),
    pagoFallido: (_) => const PagoFallidoPage(),

    // Perfil
    perfil: (_) => const PerfilPage(),

    // Comentarios
    comentar: (_) => const DetalleComentarioPage(),
    comentarioDetalle: (_) => const DetalleComentarioPage(),
  };
}
