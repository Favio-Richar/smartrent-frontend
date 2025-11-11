// ===============================================================
// 🔹 API SERVICE – SmartRent+
// ---------------------------------------------------------------
// - Métodos completos: GET, POST, PUT, PATCH, DELETE, Multipart
// - Manejo automático de token
// - Errores detallados por método y endpoint
// ===============================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smartrent_plus/core/utils/constants.dart';

/// Servicio HTTP centralizado. Todas las llamadas deben pasar por aquí para
/// respetar `ApiConstants.baseUrl` y `apiPrefix`.
class ApiService {
  final String? token;
  const ApiService({this.token});

  // ===========================================================
  // 🔹 COMPATIBILIDAD Y HELPERS ESTÁTICOS
  // ===========================================================
  static String get Api => _join(ApiConstants.baseUrl, ApiConstants.apiPrefix);

  static Uri path(String route, [Map<String, dynamic>? query]) {
    return Uri.parse(_join(Api, route)).replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
    );
  }

  static Map<String, String> headers({
    String? token,
    Map<String, String>? extra,
  }) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (extra != null) h.addAll(extra);
    return h;
  }

  static String _join(String a, String b) {
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;
    final left = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final right = b.startsWith('/') ? b.substring(1) : b;
    return '$left/$right';
  }

  Map<String, String> _headers({Map<String, String>? extra}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (extra != null) h.addAll(extra);
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final absolute = ApiConstants.url(path);
    return Uri.parse(absolute).replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
    );
  }

  // ===========================================================
  // 🔹 MÉTODOS HTTP BÁSICOS
  // ===========================================================
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers());
    _throwIfError(res, method: 'GET', path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Map body) async {
    final res = await http.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res, method: 'POST', path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> put(String path, Map body) async {
    final res = await http.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res, method: 'PUT', path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  // ===========================================================
  // 🔹 PATCH (actualización parcial)
  // ===========================================================
  Future<dynamic> patch(String path, Map body) async {
    final res = await http.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res, method: 'PATCH', path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: _headers());
    _throwIfError(res, method: 'DELETE', path: path);
    return res.body.isEmpty ? {} : jsonDecode(res.body);
  }

  // ===========================================================
  // 🔹 MULTIPART – Subida de imágenes y archivos
  // ===========================================================
  Future<dynamic> uploadImageMultipart(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    final req = http.MultipartRequest('POST', _uri(path));

    // Authorization únicamente, boundary lo maneja automáticamente
    if (token != null) {
      req.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) req.fields.addAll(fields);
    req.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    _throwIfError(res, method: 'MULTIPART', path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  // ===========================================================
  // 🔹 Validación de errores comunes
  // ===========================================================
  void _throwIfError(
    http.Response r, {
    required String method,
    required String path,
  }) {
    if (r.statusCode >= 400) {
      throw Exception(
        '$method ${ApiConstants.url(path)} -> HTTP ${r.statusCode}: ${r.body}',
      );
    }
  }
}
