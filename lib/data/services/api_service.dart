// ===============================================================
// 🔹 API SERVICE – SmartRent+ (FINAL CORREGIDO)
// ===============================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smartrent_plus/core/utils/constants.dart';

class ApiService {
  final String? token;
  const ApiService({this.token});

  // ===========================================================
  // 🔹 Helpers
  // ===========================================================
  static String get Api => "${ApiConstants.baseUrl}${ApiConstants.apiPrefix}";

  static String _join(String a, String b) {
    if (a.endsWith('/')) a = a.substring(0, a.length - 1);
    if (b.startsWith('/')) b = b.substring(1);
    return "$a/$b";
  }

  Map<String, String> _headers({Map<String, String>? extra}) {
    final h = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (extra != null) h.addAll(extra);
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final absolute = ApiConstants.url(path);
    return Uri.parse(absolute).replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  // ===========================================================
  // 🔹 Métodos HTTP básicos
  // ===========================================================
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers());
    _throwIfError(res, method: "GET", path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Map body) async {
    final res = await http.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res, method: "POST", path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> put(String path, Map body) async {
    final res = await http.put(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res, method: "PUT", path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> patch(String path, Map body) async {
    final res = await http.patch(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res, method: "PATCH", path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(
      _uri(path),
      headers: _headers(),
    );
    _throwIfError(res, method: "DELETE", path: path);
    return res.body.isEmpty ? {} : jsonDecode(res.body);
  }

  // ===========================================================
  // 🔹 MULTIPART – Subida de imágenes
  // ===========================================================
  Future<dynamic> uploadImageMultipart(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    final req = http.MultipartRequest("POST", _uri(path));

    if (token != null) {
      req.headers['Authorization'] = "Bearer $token";
    }

    if (fields != null) req.fields.addAll(fields);
    req.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    _throwIfError(res, method: "MULTIPART", path: path);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  // ===========================================================
  // 🔹 GET FILE (PDF) – FINAL
  // ===========================================================
  Future<http.Response> getFile(String path) async {
    final res = await http.get(
      _uri(path),
      headers: _headers(extra: {"Accept": "application/pdf"}),
    );

    _throwIfError(res, method: "GET FILE", path: path);
    return res;
  }

  // ===========================================================
  // 🔹 Errores
  // ===========================================================
  void _throwIfError(
    http.Response r, {
    required String method,
    required String path,
  }) {
    if (r.statusCode >= 400) {
      throw Exception(
        "$method ${ApiConstants.url(path)} "
        "→ HTTP ${r.statusCode}: ${r.body}",
      );
    }
  }
}
