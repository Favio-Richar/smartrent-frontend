// ===============================================================
// 🔹 SERVICIO CENTRAL DE EMPLEOS - SmartRent+
// ===============================================================
// Conecta el frontend Flutter con el backend NestJS.
// Maneja CRUD de empleos, postulaciones, favoritos y búsquedas.
// Compatible con roles: Usuario, Empresa.
// ===============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/core/utils/constants.dart';

class JobService {
  // ============================================================
  // 🔹 Obtener todos los empleos (para usuarios o admin)
  // ============================================================
  static Future<List<dynamic>> obtenerEmpleos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs');

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(res.body));
    } else {
      throw Exception('Error al obtener empleos');
    }
  }

  // ============================================================
  // 🔹 Obtener empleos destacados (para el Dashboard)
  // ============================================================
  static Future<List<dynamic>> obtenerEmpleosDestacados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('${ApiConstants.baseUrl}/jobs/destacados');

      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return List<dynamic>.from(jsonDecode(res.body));
      } else {
        // Si no existe endpoint /destacados, usa el general
        return await obtenerEmpleos();
      }
    } catch (e) {
      debugPrint('❌ Error al obtener empleos destacados: $e');
      return [];
    }
  }

  // ============================================================
  // 🔹 Obtener detalle de un empleo por ID
  // ============================================================
  static Future<Map<String, dynamic>> obtenerDetalle(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/$id');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    } else {
      throw Exception('Error al obtener detalle del empleo');
    }
  }

  // ============================================================
  // 🔹 Crear nuevo empleo (solo empresas)
  // ============================================================
  static Future<bool> crearEmpleo(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final companyId = prefs.getInt('userId'); // empresa logueada

    data['companyId'] = companyId;

    final url = Uri.parse('${ApiConstants.baseUrl}/jobs');
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return res.statusCode == 201;
  }

  // ============================================================
  // 🔹 Actualizar empleo
  // ============================================================
  static Future<bool> actualizarEmpleo(
    int id,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/$id');

    final res = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return res.statusCode == 200;
  }

  // ============================================================
  // 🔹 Eliminar empleo
  // ============================================================
  static Future<bool> eliminarEmpleo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/$id');

    final res = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return res.statusCode == 200;
  }

  // ============================================================
  // 🔹 Postular a un empleo
  // ============================================================
  static Future<bool> postularEmpleo(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/$jobId/apply');
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'userId': userId}),
    );

    return res.statusCode == 201;
  }

  // ============================================================
  // 🔹 Obtener postulaciones del usuario
  // ============================================================
  static Future<List<dynamic>> obtenerPostulacionesUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/jobs/postulaciones/user/$userId',
    );
    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(res.body));
    } else {
      throw Exception('Error al obtener postulaciones del usuario');
    }
  }

  // ============================================================
  // 🔹 Obtener postulantes (para empresa)
  // ============================================================
  static Future<List<dynamic>> obtenerPostulantesPorEmpleo(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/$jobId/postulantes');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(res.body));
    } else {
      throw Exception('Error al obtener postulantes del empleo');
    }
  }

  // ============================================================
  // 🔹 Obtener empleos creados por empresa
  // ============================================================
  static Future<List<dynamic>> obtenerEmpleosEmpresa(int companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/company/$companyId');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(res.body));
    } else {
      throw Exception('Error al obtener empleos de la empresa');
    }
  }

  // ============================================================
  // 🔹 FAVORITOS (Agregar / quitar / listar)
  // ============================================================
  static Future<bool> agregarFavorito(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    final url = Uri.parse('${ApiConstants.baseUrl}/favorites');

    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'jobId': jobId, 'userId': userId}),
    );

    return res.statusCode == 201;
  }

  static Future<bool> eliminarFavorito(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/favorites/user/$userId/job/$jobId',
    );

    final res = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return res.statusCode == 200;
  }

  static Future<List<dynamic>> obtenerFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    final url = Uri.parse('${ApiConstants.baseUrl}/favorites/user/$userId');
    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(res.body));
    } else {
      throw Exception('Error al obtener favoritos');
    }
  }

  // ============================================================
  // 🔹 Búsqueda avanzada
  // ============================================================
  static Future<List<dynamic>> buscarEmpleos(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs?search=$query');

    final res = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(res.body));
    } else {
      throw Exception('Error al buscar empleos');
    }
  }
}
