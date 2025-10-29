// ===============================================================
// 🔹 DASHBOARD CONTROLLER - SMARTRENT+
// ===============================================================
// Controlador central del dashboard de SmartRent+.
// Carga datos de propiedades, ventas, empleos y define el rol del usuario.
// ===============================================================

import 'package:flutter/foundation.dart';
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
  // 🔹 Inicializa los datos del dashboard
  // ============================================================
  Future<void> initDashboard() async {
    try {
      isLoading = true;
      notifyListeners();

      // 🔸 Obtiene información del usuario logueado
      usuarioActual = await AuthService.getCurrentUser();
      isCompany = (usuarioActual?['role'] ?? '').toLowerCase() == 'empresa';

      // 🔸 Carga datos destacados
      propiedades = await PropertyService.obtenerPropiedadesDestacadas();
      empleos = await JobService.obtenerEmpleosDestacados();
    } catch (e) {
      debugPrint('❌ Error en DashboardController: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
