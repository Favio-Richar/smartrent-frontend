import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // 👇 Ajusta esta URL base a tu backend
  static const String baseUrl = 'http://localhost:3000';

  final String? token;
  const ApiService({this.token});

  Map<String, String> _headers({Map<String, String>? extra}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (extra != null) h.addAll(extra);
    return h;
  }

  Uri _u(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_u(path, query), headers: _headers());
    _throwIfError(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Map body) async {
    final res = await http.post(
      _u(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> put(String path, Map body) async {
    final res = await http.put(
      _u(path),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_u(path), headers: _headers());
    _throwIfError(res);
    return res.body.isEmpty ? {} : jsonDecode(res.body);
  }

  /// Subida de imagen (Cloudinary o endpoint propio que reciba multipart).
  Future<dynamic> uploadImageMultipart(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    final req = http.MultipartRequest('POST', _u(path));
    req.headers.addAll(
      _headers(extra: {'Content-Type': 'multipart/form-data'}),
    );
    if (fields != null) req.fields.addAll(fields);
    req.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    _throwIfError(res);
    return jsonDecode(res.body);
  }

  void _throwIfError(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }
}
