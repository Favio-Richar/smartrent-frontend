// lib/data/services/property_service.dart
// ===============================================================
// ✅ PROPERTY SERVICE - SmartRent+ (versión completa 2025)
// ===============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/core/utils/constants.dart';
import 'package:smartrent_plus/data/services/uploads_service.dart';

class PropertyService {
  // ===============================================================
  // 🔐 HEADERS / HELPERS
  // ===============================================================
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('${ApiConstants.baseUrl}${ApiConstants.apiPrefix}$path')
        .replace(
            queryParameters: query?.map((k, v) => MapEntry(k, v.toString())));
  }

  static List<dynamic> _parseList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final v =
          body['items'] ?? body['data'] ?? body['results'] ?? body['rows'];
      if (v is List) return v;
    }
    return [];
  }

  // ===============================================================
  // 🧩 CREAR / ACTUALIZAR PROPIEDAD
  // ===============================================================
  Future<bool> create(Map<String, dynamic> data,
      {List<File> images = const [], File? video}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId != null && !data.containsKey('userId'))
        data['userId'] = userId;

      if (images.isNotEmpty) {
        final uploaded = <String>[];
        for (final f in images) {
          try {
            final u = await UploadsService.uploadImage(f);
            uploaded.add(u);
          } catch (e) {
            debugPrint('Error subiendo imagen: $e');
          }
        }
        if (uploaded.isNotEmpty) {
          data['image_url'] = uploaded.first;
          data['images'] = uploaded;
        }
      }

      if (video != null) {
        try {
          final vUrl = await UploadsService.uploadVideo(video);
          data['videoUrl'] = vUrl;
        } catch (e) {
          debugPrint('Error subiendo video: $e');
        }
      }

      data.removeWhere(
          (k, v) => v == null || (v is String && v.trim().isEmpty));

      final res = await http.post(
        _uri('/properties'),
        headers: await _authHeaders(),
        body: jsonEncode(data),
      );

      debugPrint('📤 POST /properties => ${res.statusCode}');
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('❌ create error: $e');
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data,
      {List<File> images = const [], File? video}) async {
    try {
      if (images.isNotEmpty) {
        final uploaded = <String>[];
        for (final f in images) {
          final u = await UploadsService.uploadImage(f);
          uploaded.add(u);
        }
        if (uploaded.isNotEmpty) {
          data['image_url'] = uploaded.first;
          data['images'] = uploaded;
        }
      }

      if (video != null) {
        final vUrl = await UploadsService.uploadVideo(video);
        data['videoUrl'] = vUrl;
      }

      data.removeWhere(
          (k, v) => v == null || (v is String && v.trim().isEmpty));

      final res = await http.put(
        _uri('/properties/$id'),
        headers: await _authHeaders(),
        body: jsonEncode(data),
      );

      debugPrint('📤 PUT /properties/$id => ${res.statusCode}');
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('update error: $e');
      return false;
    }
  }

  // ===============================================================
  // 🔍 OBTENER DETALLE (getById)
  // ===============================================================
  Future<Map<String, dynamic>> getById(String id) async {
    try {
      final res = await http.get(_uri('/properties/$id'),
          headers: await _authHeaders());
      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(res.body));
      }
      debugPrint('⚠️ getById => ${res.statusCode}');
      return {};
    } catch (e) {
      debugPrint('getById error: $e');
      return {};
    }
  }

  // ===============================================================
  // 📋 LISTAR TODAS
  // ===============================================================
  Future<List<dynamic>> getAll({
    Map<String, dynamic>? filters,
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final q = {
        'page': page,
        'limit': limit,
        if (filters != null) ...filters,
      };
      final res =
          await http.get(_uri('/properties', q), headers: await _authHeaders());
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return _parseList(body)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('getAll error: $e');
      return [];
    }
  }

  // ===============================================================
  // 🏠 MIS PROPIEDADES (getMyProperties)
  // ===============================================================
  Future<List<Map<String, dynamic>>> getMyProperties() async {
    try {
      final res =
          await http.get(_uri('/properties/me'), headers: await _authHeaders());
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = _parseList(body)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
        return list;
      }
      debugPrint('⚠️ getMyProperties => ${res.statusCode}');
      return [];
    } catch (e) {
      debugPrint('getMyProperties error: $e');
      return [];
    }
  }

  // ===============================================================
  // 🌟 PROPIEDADES DESTACADAS (Dashboard)
  // ===============================================================
  static Future<List<dynamic>> obtenerPropiedadesDestacadas() async {
    try {
      final res = await http.get(
        _uri('/properties', {'limit': 6, 'sort': 'updated_desc'}),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return _parseList(body);
      }
      return [];
    } catch (e) {
      debugPrint('obtenerPropiedadesDestacadas error: $e');
      return [];
    }
  }

  // ===============================================================
  // 🗑️ ELIMINAR
  // ===============================================================
  Future<bool> delete(String id) async {
    try {
      final res = await http.delete(_uri('/properties/$id'),
          headers: await _authHeaders());
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('delete error: $e');
      return false;
    }
  }

  // ===============================================================
  // 🧩 CAMBIO DE ESTADO / CLONAR
  // ===============================================================
  Future<bool> changeStatus(String id, String state) async {
    try {
      final res = await http.patch(
        _uri('/properties/$id/state'),
        headers: await _authHeaders(),
        body: jsonEncode({'state': state}),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('changeStatus error: $e');
      return false;
    }
  }

  Future<bool> clone(String id) async {
    try {
      final res = await http.post(_uri('/properties/$id/clone'),
          headers: await _authHeaders());
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('clone error: $e');
      return false;
    }
  }

  // ===============================================================
  // ❤️ FAVORITOS Y UTILIDADES
  // ===============================================================
  Future<bool> toggleFavorite(String id) async {
    try {
      final res = await http.post(
        _uri('/properties/$id/favorite'),
        headers: await _authHeaders(),
        body: jsonEncode({}),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('toggleFavorite error: $e');
      return false;
    }
  }

  Future<List<String>> getTipos() async {
    try {
      final res = await http.get(_uri('/properties/utils/tipos'),
          headers: await _authHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<String>.from(data.map((e) => e.toString()));
      }
      return [];
    } catch (e) {
      debugPrint('getTipos error: $e');
      return [];
    }
  }

  Future<List<String>> getComunas() async {
    try {
      final res = await http.get(_uri('/properties/utils/comunas'),
          headers: await _authHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<String>.from(data.map((e) => e.toString()));
      }
      return [];
    } catch (e) {
      debugPrint('getComunas error: $e');
      return [];
    }
  }
}
