// ===============================================================
// 🔹 PROPERTY SERVICE - SmartRent+ (robusto contra rutas 404)
//    - Usa ApiConstants.apiPrefix
//    - Prueba rutas candidatas (properties/property, list/all)
//    - Parser flexible ([] | {items} | {data} | {results} | {rows})
//    - No envía Authorization si no hay token
//    - Mapea payload front → backend (title→titulo, etc.)
// ===============================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/core/utils/constants.dart';

class PropertyService {
  // ---------------- Helpers ----------------
  static Future<Map<String, String>> _authHeaders({
    Map<String, String>? extra,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    if (extra != null) h.addAll(extra);
    return h;
  }

  static Uri _uri(String fullPath, [Map<String, dynamic>? query]) {
    return Uri.parse(fullPath).replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
    );
  }

  static String _join(String a, String b) {
    if (a.endsWith('/') && b.startsWith('/')) return a + b.substring(1);
    if (!a.endsWith('/') && !b.startsWith('/')) return '$a/$b';
    return a + b;
  }

  static Map<String, dynamic> _cleanQuery(Map<String, dynamic> q) {
    final out = <String, dynamic>{};
    q.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.trim().isEmpty) return;
      out[k] = v;
    });
    return out;
  }

  static List<dynamic> _parseList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final v =
          body['items'] ??
          body['data'] ??
          body['results'] ??
          body['rows'] ??
          body['list'];
      if (v is List) return v;
    }
    return const [];
  }

  static Future<http.Response> _tryManyGet(
    List<String> paths,
    Map<String, dynamic> q,
  ) async {
    final headers = await _authHeaders();
    http.Response? last;
    for (final p in paths) {
      final url = _uri(p, _cleanQuery(q));
      final res = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20));
      debugPrint('GET ${url.toString()} => ${res.statusCode}');
      last = res;
      if (res.statusCode == 200) return res;
    }
    return last!;
  }

  static Future<http.Response> _tryManyGetById(List<String> paths) async {
    final headers = await _authHeaders();
    http.Response? last;
    for (final p in paths) {
      final url = _uri(p);
      final res = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20));
      debugPrint('GET ${url.toString()} => ${res.statusCode}');
      last = res;
      if (res.statusCode == 200) return res;
    }
    return last!;
  }

  // ---------- mapeo front → backend para create/update ----------
  Map<String, dynamic> _mapToBackendFields(Map<String, dynamic> data) {
    // Campos front esperados en tu app:
    // title, description, price, category, location, comuna, type,
    // image_url, video_url, latitude, longitude, featured,
    // area, bedrooms, bathrooms, year
    final m = <String, dynamic>{};

    // texto / numéricos
    if (data.containsKey('title')) m['titulo'] = data['title'];
    if (data.containsKey('description')) m['descripcion'] = data['description'];
    if (data.containsKey('price')) m['precio'] = data['price'];
    if (data.containsKey('category')) m['categoria'] = data['category'];
    if (data.containsKey('location')) m['ubicacion'] = data['location'];
    if (data.containsKey('comuna')) m['comuna'] = data['comuna'];
    if (data.containsKey('type')) m['tipo'] = data['type'];

    // media / geo
    if (data.containsKey('image_url')) m['imagen'] = data['image_url'];
    if (data.containsKey('imageUrl')) m['imagen'] = data['imageUrl'];
    if (data.containsKey('video_url')) m['videoUrl'] = data['video_url'];
    if (data.containsKey('latitude')) m['latitude'] = data['latitude'];
    if (data.containsKey('longitude')) m['longitude'] = data['longitude'];

    // flags / detalles
    if (data.containsKey('featured')) m['destacado'] = data['featured'];
    if (data.containsKey('area')) m['area'] = data['area'];
    if (data.containsKey('bedrooms')) m['dormitorios'] = data['bedrooms'];
    if (data.containsKey('bathrooms')) m['banos'] = data['bathrooms'];
    if (data.containsKey('year')) m['anio'] = data['year'];

    // si ya viene con nombres backend, respétalos
    const passthrough = [
      'titulo',
      'descripcion',
      'precio',
      'categoria',
      'ubicacion',
      'comuna',
      'tipo',
      'imagen',
      'videoUrl',
      'latitude',
      'longitude',
      'destacado',
      'area',
      'dormitorios',
      'banos',
      'anio',
      'companyId',
      'userId',
    ];
    for (final k in passthrough) {
      if (data.containsKey(k)) m[k] = data[k];
    }

    // limpia nulls
    return _cleanQuery(m);
  }

  // --------------- API (instancia) ---------------
  Future<List<dynamic>> getAll({
    Map<String, dynamic>? filters,
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final candidates = <String>[
        _join(baseApi, '/properties'),
        _join(baseApi, '/properties/list'),
        _join(baseApi, '/properties/all'),
        _join(baseApi, '/property'),
        _join(baseApi, '/property/list'),
        _join(baseApi, '/property/all'),
      ];

      final q = <String, dynamic>{
        // tu backend actual usa page/limit; dejamos compat opcional
        'page': page,
        'limit': limit,
        // compat si algún entorno usa skip/take/offset
        'skip': (page - 1) * limit,
        'take': limit,
        'offset': (page - 1) * limit,
        if (filters != null) ...filters,
      };

      final res = await _tryManyGet(candidates, q);
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
      final body = jsonDecode(res.body);
      return _parseList(body);
    } catch (e) {
      debugPrint('❌ getAll error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getById(String id) async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final candidates = <String>[
        _join(baseApi, '/properties/$id'),
        _join(baseApi, '/property/$id'),
        _join(baseApi, '/properties/detail/$id'),
      ];

      final res = await _tryManyGetById(candidates);
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
      return Map<String, dynamic>.from(jsonDecode(res.body));
    } catch (e) {
      debugPrint('❌ getById error: $e');
      rethrow;
    }
  }

  // ---------- Utils (picker de comuna / tipos) ----------
  Future<List<String>> getComunas() async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final res = await http
          .get(_uri(_join(baseApi, '/properties/utils/comunas')))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
      final data = jsonDecode(res.body);
      final list = (data is List) ? data : [];
      return list
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('❌ getComunas error: $e');
      return [];
    }
  }

  Future<List<String>> getTipos() async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final res = await http
          .get(_uri(_join(baseApi, '/properties/utils/tipos')))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
      final data = jsonDecode(res.body);
      final list = (data is List) ? data : [];
      return list
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('❌ getTipos error: $e');
      return [];
    }
  }

  // ---------- POST: Crear ----------
  Future<bool> create(Map<String, dynamic> data) async {
    try {
      // mapeo front → backend
      final payload = _mapToBackendFields(data);

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId != null && !payload.containsKey('userId')) {
        payload['userId'] = userId;
      }

      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final paths = [
        _join(baseApi, '/properties'),
        _join(baseApi, '/property'),
      ];

      for (final p in paths) {
        final res = await http
            .post(
              _uri(p),
              headers: await _authHeaders(),
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 25));
        debugPrint('POST $p => ${res.statusCode}');
        if (res.statusCode == 201 || res.statusCode == 200) return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ create error: $e');
      return false;
    }
  }

  // ---------- PUT: Editar ----------
  Future<bool> update(String id, Map<String, dynamic> data) async {
    try {
      final payload = _mapToBackendFields(data);

      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final paths = [
        _join(baseApi, '/properties/$id'),
        _join(baseApi, '/property/$id'),
      ];
      for (final p in paths) {
        final res = await http
            .put(
              _uri(p),
              headers: await _authHeaders(),
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 25));
        debugPrint('PUT $p => ${res.statusCode}');
        if (res.statusCode == 200) return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ update error: $e');
      return false;
    }
  }

  // ---------- DELETE: Eliminar ----------
  Future<bool> delete(String id) async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final paths = [
        _join(baseApi, '/properties/$id'),
        _join(baseApi, '/property/$id'),
      ];
      for (final p in paths) {
        final res = await http
            .delete(_uri(p), headers: await _authHeaders())
            .timeout(const Duration(seconds: 20));
        debugPrint('DELETE $p => ${res.statusCode}');
        if (res.statusCode == 200 || res.statusCode == 204) return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ delete error: $e');
      return false;
    }
  }

  // ---------- Mis propiedades (si tu backend lo soporta) ----------
  Future<List<dynamic>> getMyProperties() async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final candidates = <String>[
        _join(baseApi, '/properties/me'),
        _join(baseApi, '/property/me'),
      ];
      final res = await _tryManyGet(candidates, const {});
      if (res.statusCode != 200) {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
      final body = jsonDecode(res.body);
      return _parseList(body);
    } catch (e) {
      debugPrint('❌ getMyProperties error: $e');
      return [];
    }
  }

  // ---------- Favoritos (si existe en backend) ----------
  Future<bool> toggleFavorite(String id) async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final paths = [
        _join(baseApi, '/properties/$id/favorite'),
        _join(baseApi, '/property/$id/favorite'),
      ];
      for (final p in paths) {
        final res = await http
            .post(_uri(p), headers: await _authHeaders(), body: jsonEncode({}))
            .timeout(const Duration(seconds: 20));
        debugPrint('POST $p => ${res.statusCode}');
        if (res.statusCode == 200 || res.statusCode == 201) return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ toggleFavorite error: $e');
      return false;
    }
  }

  // ---------- Upload imagen (cuando tengas endpoint real) ----------
  Future<String> uploadImage(File file, {String fieldName = 'file'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final url = _uri(_join(baseApi, '/uploads/image'));
      final req = http.MultipartRequest('POST', url);
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      req.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode >= 400) {
        throw Exception('Upload error ${res.statusCode}: ${res.body}');
      }
      final body = jsonDecode(res.body);
      return (body['url'] ?? body['secure_url']) as String;
    } catch (e) {
      debugPrint('❌ uploadImage error: $e');
      rethrow;
    }
  }

  // --------------- API estática (compat) ---------------
  static Future<List<dynamic>> obtenerPropiedades() async {
    final svc = PropertyService();
    return svc.getAll();
  }

  static Future<List<dynamic>> obtenerPropiedadesDestacadas() async {
    final svc = PropertyService();
    // tu backend espera "destacado: true"
    return svc.getAll(filters: {'destacado': true});
  }

  static Future<Map<String, dynamic>?> obtenerDetallePropiedad(int id) async {
    final svc = PropertyService();
    try {
      return await svc.getById(id.toString());
    } catch (_) {
      return null;
    }
  }

  static Future<bool> crearPropiedad(Map<String, dynamic> data) async {
    final svc = PropertyService();
    return svc.create(data);
  }

  static Future<bool> actualizarPropiedad(
    int id,
    Map<String, dynamic> data,
  ) async {
    final svc = PropertyService();
    return svc.update(id.toString(), data);
  }

  static Future<bool> eliminarPropiedad(int id) async {
    final svc = PropertyService();
    return svc.delete(id.toString());
  }

  static Future<List<dynamic>> buscarPropiedades(String query) async {
    final svc = PropertyService();
    // "ubicacion" como búsqueda libre; ajusta si usas otro campo
    return svc.getAll(filters: {'ubicacion': query});
  }

  static Future<bool> reservarPropiedad(int propertyId) async {
    // Placeholder: implementa según tu backend real (reservas)
    final svc = PropertyService();
    return svc.toggleFavorite(propertyId.toString());
  }

  static Future<List<dynamic>> obtenerReservasUsuario() async {
    // Placeholder: implementa según tu backend real
    return const [];
  }

  static Future<List<dynamic>> obtenerMisPropiedades() async {
    final svc = PropertyService();
    return svc.getMyProperties();
  }

  static Future<bool> alternarFavorito(String id) async {
    final svc = PropertyService();
    return svc.toggleFavorite(id);
  }
}
