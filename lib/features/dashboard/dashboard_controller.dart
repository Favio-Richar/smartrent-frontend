// ===============================================================
// 🔹 DASHBOARD CONTROLLER – SmartRent+ (VERSIÓN FINAL CORREGIDA)
// ---------------------------------------------------------------
// - Lee datos reales del backend (id, role, token…)
// - Lee datos locales del perfil (foto, nombre, descripción…)
// - Combina todo correctamente sin nulls
// - Dashboard ya mostrará el nombre real y la foto elegida
// ===============================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/data/services/property_service.dart';
import 'package:smartrent_plus/data/services/job_service.dart';
import 'package:smartrent_plus/data/services/auth_service.dart';

class DashboardController extends ChangeNotifier {
  bool isLoading = true;
  bool isCompany = false;

  List<dynamic> propiedades = [];
  List<dynamic> empleos = [];

  Map<String, dynamic>? usuarioActual;

  DashboardController() {
    initDashboard();
  }

  // ============================================================
  // 🔵 CARGAR TODA LA INFORMACIÓN DEL DASHBOARD
  // ============================================================
  Future<void> initDashboard() async {
    try {
      isLoading = true;
      notifyListeners();

      // ============================================================
      // ⚡ 1) Datos del backend (auth)
      // ============================================================
      final backendUser = await AuthService.getCurrentUser();
      final backendNombre = backendUser?["nombre"];
      final backendEmail = backendUser?["correo"];
      final backendRole = backendUser?["role"];

      // ============================================================
      // ⚡ 2) Datos locales (perfil personalizado)
      // ============================================================
      final prefs = await SharedPreferences.getInstance();

      final localName = prefs.getString("nombreUsuario");
      final localDesc = prefs.getString("descripcion");
      final localPhoto = prefs.getString("profileImage");

      // ============================================================
      // ⚡ 3) COMBINAR DATOS (BACKEND + LOCALES)
      // ============================================================
      usuarioActual = {
        "id": backendUser?["id"] ?? 0,
        "correo": backendEmail ?? "",
        "role": backendRole ?? "Usuario",

        // Nombre → prioridad al perfil personalizado
        "nombre": (localName != null && localName.isNotEmpty)
            ? localName
            : (backendNombre ?? "Usuario"),

        // Descripción → solo viene del perfil
        "descripcion": localDesc ?? "",

        // Imagen → si existe local, úsala. Si no, null
        "imagen": localPhoto,
      };

      // Rol
      isCompany =
          (usuarioActual?["role"] ?? '').toString().toLowerCase() == "empresa";

      // ============================================================
      // ⚡ 4) Datos del dashboard (propiedades, empleos)
      // ============================================================
      propiedades = await PropertyService.obtenerPropiedadesDestacadas();
      empleos = await JobService.obtenerEmpleosDestacados();
    } catch (e) {
      debugPrint("❌ Error en DashboardController: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
