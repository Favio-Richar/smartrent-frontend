// ===============================================================
// 🔹 UPLOADS SERVICE - SmartRent+ (versión final funcional)
// ---------------------------------------------------------------
// • Subida de imágenes y videos al backend NestJS.
// • Totalmente compatible con tus rutas actuales:
//    ➤ POST /api/uploads/image
//    ➤ POST /api/uploads/video
// ===============================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/core/utils/constants.dart';

class UploadsService {
  // ===============================================================
  // 🔐 HEADERS CON TOKEN JWT
  // ===============================================================
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = <String, String>{};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ===============================================================
  // 📸 SUBIR IMAGEN (usa /uploads/image)
  // ===============================================================
  static Future<String> uploadImage(File file,
      {String fieldName = 'file'}) async {
    final headers = await _authHeaders();

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.apiPrefix}/uploads/image',
    );

    final req = http.MultipartRequest('POST', url);
    req.headers.addAll(headers);
    req.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode >= 400) {
      throw Exception('Error al subir imagen (${res.statusCode}): ${res.body}');
    }

    final body = jsonDecode(res.body);
    final urlOut = (body['url'] ?? body['secure_url'] ?? body['path'] ?? '')
        .toString()
        .trim();

    if (urlOut.isEmpty) throw Exception('Upload image: respuesta sin URL');

    // Devuelve URL completa lista para usar
    return ApiConstants.media(urlOut);
  }

  // ===============================================================
  // 🎬 SUBIR VIDEO (usa /uploads/video)
  // ===============================================================
  static Future<String> uploadVideo(File file,
      {String fieldName = 'file'}) async {
    final headers = await _authHeaders();

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.apiPrefix}/uploads/video',
    );

    final req = http.MultipartRequest('POST', url);
    req.headers.addAll(headers);
    req.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode >= 400) {
      throw Exception('Error al subir video (${res.statusCode}): ${res.body}');
    }

    final body = jsonDecode(res.body);
    final urlOut = (body['url'] ?? body['secure_url'] ?? body['path'] ?? '')
        .toString()
        .trim();

    if (urlOut.isEmpty) throw Exception('Upload video: respuesta sin URL');

    return ApiConstants.media(urlOut);
  }
}
