// lib/data/services/arriendos_service.dart
// ===============================================================
// 🔹 ARRIENDOS SERVICE - SMARTRENT+ (versión corregida)
// ===============================================================
// - Usa ApiService (que ya compone la URL con ApiConstants.url).
// - NO usa ApiService.baseUrl ni ApiService.Api (no existen).
// - Endpoints relativos a /api del backend NestJS.
// - Métodos tipados y listos para usar con/ sin token JWT.
// ===============================================================

import 'package:smartrent_plus/data/services/api_service.dart';

class ArriendosService {
  final ApiService _api;
  ArriendosService({String? token}) : _api = ApiService(token: token);

  // ===========================================================
  // 🔹 PROPIEDADES  (/api/properties)
  // ===========================================================
  Future<List<dynamic>> obtenerPropiedades({int page = 1}) async {
    final data = await _api.get('properties', query: {'page': page});
    return (data as List?) ?? [];
  }

  Future<Map<String, dynamic>> crearPropiedad(Map<String, dynamic> body) async {
    final data = await _api.post('properties', body);
    return (data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> actualizarPropiedad(
    String id,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.put('properties/$id', body);
    return (data as Map).cast<String, dynamic>();
  }

  Future<void> eliminarPropiedad(String id) async {
    await _api.delete('properties/$id');
  }

  // ===========================================================
  // 🔹 RESERVAS  (/api/reservas)
  // ===========================================================
  Future<List<dynamic>> obtenerReservas({int page = 1}) async {
    final data = await _api.get('reservas', query: {'page': page});
    return (data as List?) ?? [];
  }

  Future<Map<String, dynamic>> crearReserva(Map<String, dynamic> body) async {
    final data = await _api.post('reservas', body);
    return (data as Map).cast<String, dynamic>();
  }

  // ===========================================================
  // 🔹 RESEÑAS  (/api/resenas)
  // ===========================================================
  Future<List<dynamic>> obtenerResenas({int page = 1}) async {
    // Nota: usar 'resenas' (sin ñ) salvo que tu backend exponga exactamente 'reseñas'
    final data = await _api.get('resenas', query: {'page': page});
    return (data as List?) ?? [];
  }

  Future<Map<String, dynamic>> enviarResena(Map<String, dynamic> body) async {
    final data = await _api.post('resenas', body);
    return (data as Map).cast<String, dynamic>();
  }

  // ===========================================================
  // 🔹 ESTADÍSTICAS  (/api/estadisticas/arriendos)
  // ===========================================================
  Future<Map<String, dynamic>> obtenerEstadisticasArriendos() async {
    final data = await _api.get('estadisticas/arriendos');
    return (data as Map).cast<String, dynamic>();
  }
}
