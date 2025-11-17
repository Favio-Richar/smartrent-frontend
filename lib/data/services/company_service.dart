import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/constants.dart';
import '../models/company_model.dart';

class CompanyService {
  final String baseUrl = ApiConstants.baseUrl;
  final String api = ApiConstants.apiPrefix;

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ============================================================
  // 🔹 Registrar empresa
  // ============================================================
  Future<bool> registerCompany(Company company) async {
    final url = Uri.parse("$baseUrl$api/companies");
    final res = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(company.toJson()),
    );

    return res.statusCode == 201 || res.statusCode == 200;
  }

  // ============================================================
  // 🔹 Obtener empresa por su ID (CORREGIDO)
  // ============================================================
  Future<Company?> getCompanyById(int id) async {
    final url = Uri.parse("$baseUrl$api/companies/$id");
    final res = await http.get(url, headers: await _authHeaders());

    if (res.statusCode == 200) {
      if (res.body.isEmpty) {
        print("⚠️ Backend devolvió body vacío en GET /companies/$id");
        return null;
      }

      try {
        return Company.fromJson(jsonDecode(res.body));
      } catch (e) {
        print("❌ Error parseando empresa: $e");
        print("📌 Body recibido: ${res.body}");
        return null;
      }
    }

    print("⚠️ Error al obtener empresa: ${res.statusCode}");
    return null;
  }

  // ⭐ Obtener empresa por ID de usuario
  Future<Company?> getCompanyByUserId(int userId) async {
    final url = Uri.parse("$baseUrl$api/companies/user/$userId");
    final res = await http.get(url, headers: await _authHeaders());

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return Company.fromJson(jsonDecode(res.body));
    }

    return null;
  }

  // ============================================================
  // 🔹 Obtener todas las empresas
  // ============================================================
  Future<List<Company>> getCompanies() async {
    final url = Uri.parse("$baseUrl$api/companies");
    final res = await http.get(url, headers: await _authHeaders());

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final list = jsonDecode(res.body) as List;
      return list.map((json) => Company.fromJson(json)).toList();
    }

    return [];
  }

  // ============================================================
  // ⭐ Actualizar empresa
  // ============================================================
  Future<bool> updateCompany(Company company) async {
    final url = Uri.parse("$baseUrl$api/companies/${company.id}");
    final res = await http.put(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(company.toJson()),
    );

    return res.statusCode == 200;
  }
}
