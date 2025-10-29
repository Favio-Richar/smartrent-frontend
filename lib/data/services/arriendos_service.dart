// ===============================================================
// 🔹 ARRIENDOS SERVICE - SMARTRENT+
// ===============================================================
// Servicio central para manejar propiedades, reservas, reseñas y
// estadísticas del módulo de Arriendos. Conexión con backend NestJS.
// ===============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartrent_plus/data/services/api_service.dart';

class ArriendosService {
  static final String baseUrl = "${ApiService.baseUrl}/arriendos";

  // ===========================================================
  // 🔹 PROPIEDADES
  // ===========================================================
  static Future<List<dynamic>> obtenerPropiedades() async {
    final res = await http.get(Uri.parse("$baseUrl/listar"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error al obtener propiedades");
    }
  }

  static Future<bool> crearPropiedad(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/crear"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return res.statusCode == 201;
  }

  static Future<bool> actualizarPropiedad(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> eliminarPropiedad(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    return res.statusCode == 200;
  }

  // ===========================================================
  // 🔹 RESERVAS
  // ===========================================================
  static Future<List<dynamic>> obtenerReservas() async {
    final res = await http.get(Uri.parse("$baseUrl/reservas"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error al obtener reservas");
    }
  }

  static Future<bool> crearReserva(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/reservas"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return res.statusCode == 201;
  }

  // ===========================================================
  // 🔹 RESEÑAS
  // ===========================================================
  static Future<List<dynamic>> obtenerResenas() async {
    final res = await http.get(Uri.parse("$baseUrl/reseñas"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error al obtener reseñas");
    }
  }

  static Future<bool> enviarResena(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/reseñas"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return res.statusCode == 201;
  }

  // ===========================================================
  // 🔹 ESTADÍSTICAS
  // ===========================================================
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final res = await http.get(Uri.parse("$baseUrl/estadisticas"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error al cargar estadísticas");
    }
  }
}
