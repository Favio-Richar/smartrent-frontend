// lib/data/services/property_service.dart
// ===============================================================
// 🔹 PROPERTY SERVICE - SmartRent+ (robusto y sin alertas)
// - Autenticación por header (Bearer)
// - Rutas tolerantes a 404/400 y múltiple naming en el backend
// - create/update JSON con fallback multipart
// - Mis propiedades: intenta /me y luego filtra por userId/companyId
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
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    if (extra != null) h.addAll(extra);
    return h;
  }

  static Future<Map<String, String>> _onlyAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final h = <String, String>{};
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
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
    final m = <String, dynamic>{};

    if (data.containsKey('title')) m['titulo'] = data['title'];
    if (data.containsKey('description')) m['descripcion'] = data['description'];
    if (data.containsKey('price')) m['precio'] = data['price'];
    if (data.containsKey('category')) m['categoria'] = data['category'];
    if (data.containsKey('location')) m['ubicacion'] = data['location'];
    if (data.containsKey('comuna')) m['comuna'] = data['comuna'];
    if (data.containsKey('type')) m['tipo'] = data['type'];

    if (data.containsKey('image_url')) m['imagen'] = data['image_url'];
    if (data.containsKey('imageUrl')) m['imagen'] = data['imageUrl'];
    if (data.containsKey('video_url')) m['videoUrl'] = data['video_url'];
    if (data.containsKey('latitude')) m['latitude'] = data['latitude'];
    if (data.containsKey('longitude')) m['longitude'] = data['longitude'];

    if (data.containsKey('featured')) m['destacado'] = data['featured'];
    if (data.containsKey('area')) m['area'] = data['area'];
    if (data.containsKey('bedrooms')) m['dormitorios'] = data['bedrooms'];
    if (data.containsKey('bathrooms')) m['banos'] = data['bathrooms'];
    if (data.containsKey('year')) m['anio'] = data['year'];

    // contacto (ahora con llaves para cumplir el lint)
    if (data.containsKey('company_name')) {
      m['companyName'] = data['company_name'];
    }
    if (data.containsKey('contact_name')) {
      m['contactName'] = data['contact_name'];
    }
    if (data.containsKey('contact_phone')) {
      m['contactPhone'] = data['contact_phone'];
    }
    if (data.containsKey('contact_email')) {
      m['contactEmail'] = data['contact_email'];
    }
    if (data.containsKey('website')) m['website'] = data['website'];
    if (data.containsKey('whatsapp')) m['whatsapp'] = data['whatsapp'];

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
      'companyName',
      'contactName',
      'contactPhone',
      'contactEmail',
      'whatsapp',
      'website',
      'companyId',
      'userId',
      'metadata',
    ];
    for (final k in passthrough) {
      if (data.containsKey(k)) m[k] = data[k];
    }
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
        'page': page,
        'limit': limit,
        'skip': (page - 1) * limit,
        'take': limit,
        'offset': (page - 1) * limit,
        if (filters != null) ...filters,
      };

      final res = await _tryManyGet(candidates, q);
      if (res.statusCode != 200) return const [];
      final body = jsonDecode(res.body);
      return _parseList(body);
    } catch (_) {
      return const [];
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
      if (res.statusCode != 200) return <String, dynamic>{};
      return Map<String, dynamic>.from(jsonDecode(res.body));
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  // ---------- Utils ----------
  Future<List<String>> getComunas() async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final res = await http
          .get(_uri(_join(baseApi, '/properties/utils/comunas')))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body);
      final list = (data is List) ? data : [];
      return list
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
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
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body);
      final list = (data is List) ? data : [];
      return list
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ---------- POST: Crear (JSON primero; fallback multipart) ----------
  Future<bool> create(Map<String, dynamic> data) async {
    try {
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
        debugPrint('POST $p (JSON) => ${res.statusCode}');
        if (res.statusCode == 201 || res.statusCode == 200) return true;

        // fallback multipart si el backend lo requiere
        if (res.statusCode == 415 || res.statusCode == 400) {
          final ok = await _sendMultipart(
            'POST',
            [p],
            payload,
            const [],
            singleField: 'image',
            multiField: 'images[]',
          );
          if (ok) return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---------- PUT: Editar (JSON primero; fallback multipart) ----------
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
        debugPrint('PUT $p (JSON) => ${res.statusCode}');
        if (res.statusCode == 200) return true;

        if (res.statusCode == 415 || res.statusCode == 400) {
          final ok = await _sendMultipart(
            'PUT',
            [p],
            payload,
            const [],
            singleField: 'image',
            multiField: 'images[]',
          );
          if (ok) return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---------- DELETE ----------
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
    } catch (_) {
      return false;
    }
  }

  // ---------- Mis propiedades (ROBUSTO) ----------
  Future<List<dynamic>> getMyProperties() async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      // 1) Intenta rutas /me
      final meCandidates = <String>[
        _join(baseApi, '/properties/me'),
        _join(baseApi, '/property/me'),
        _join(baseApi, '/users/me/properties'),
        _join(baseApi, '/companies/me/properties'),
        _join(baseApi, '/empresas/me/properties'),
      ];
      final resMe = await _tryManyGet(meCandidates, const {});
      if (resMe.statusCode == 200) {
        final body = jsonDecode(resMe.body);
        return _parseList(body);
      }

      // 2) Si /me no existe, filtra en /properties por userId/companyId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? prefs.getInt('idUsuario');
      final companyId =
          prefs.getInt('companyId') ??
          prefs.getInt('empresaId') ??
          prefs.getInt('idEmpresa');

      if (userId == null && companyId == null) return const [];

      final listCandidates = <String>[
        _join(baseApi, '/properties'),
        _join(baseApi, '/property'),
        _join(baseApi, '/properties/list'),
      ];

      // nombres de query comunes
      final filterQueries = <Map<String, dynamic>>[
        if (userId != null) {'userId': userId},
        if (userId != null) {'ownerId': userId},
        if (userId != null) {'createdBy': userId},
        if (companyId != null) {'companyId': companyId},
        if (companyId != null) {'empresaId': companyId},
      ];

      for (final q in filterQueries) {
        final res = await _tryManyGet(listCandidates, q);
        if (res.statusCode == 200) {
          final items = _parseList(jsonDecode(res.body));
          if (items.isNotEmpty) return items;
        }
      }

      // 3) Último intento: filtro anidado (ej. ?filter[ownerId]=1)
      final nestedFilter = <String, dynamic>{
        if (userId != null) 'filter[ownerId]': userId,
        if (companyId != null) 'filter[companyId]': companyId,
      };
      if (nestedFilter.isNotEmpty) {
        final res = await _tryManyGet(listCandidates, nestedFilter);
        if (res.statusCode == 200) {
          return _parseList(jsonDecode(res.body));
        }
      }

      return const [];
    } catch (_) {
      return const [];
    }
  }

  // ---------- Favoritos (toggle) ----------
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
    } catch (_) {
      return false;
    }
  }

  // ---------- Upload imagen (endpoint separado; opcional) ----------
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
      if (res.statusCode >= 400) throw Exception('Upload error');
      final body = jsonDecode(res.body);
      return (body['url'] ?? body['secure_url']) as String;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- CREATE/UPDATE con MULTIPART (con imágenes) ----------
  Future<bool> createMultipart(
    Map<String, dynamic> data,
    List<File> images, {
    String singleField = 'image',
    String multiField = 'images[]',
  }) async {
    final okJson = await create(data);
    if (okJson || images.isEmpty) return okJson;

    final payload = _mapToBackendFields(data);
    final base = ApiConstants.baseUrl;
    final prefix = ApiConstants.apiPrefix;
    final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

    final paths = [_join(baseApi, '/properties'), _join(baseApi, '/property')];
    return _sendMultipart(
      'POST',
      paths,
      payload,
      images,
      singleField: singleField,
      multiField: multiField,
    );
  }

  Future<bool> updateMultipart(
    String id,
    Map<String, dynamic> data,
    List<File> images, {
    String singleField = 'image',
    String multiField = 'images[]',
  }) async {
    final okJson = await update(id, data);
    if (okJson || images.isEmpty) return okJson;

    final payload = _mapToBackendFields(data);
    final base = ApiConstants.baseUrl;
    final prefix = ApiConstants.apiPrefix;
    final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

    final paths = [
      _join(baseApi, '/properties/$id'),
      _join(baseApi, '/property/$id'),
    ];
    return _sendMultipart(
      'PUT',
      paths,
      payload,
      images,
      singleField: singleField,
      multiField: multiField,
    );
  }

  Future<bool> _sendMultipart(
    String method,
    List<String> candidatePaths,
    Map<String, dynamic> fields,
    List<File> images, {
    required String singleField,
    required String multiField,
  }) async {
    try {
      final auth = await _onlyAuthHeader();
      for (final p in candidatePaths) {
        final req = http.MultipartRequest(method, _uri(p));
        req.headers.addAll(auth);

        fields.forEach((k, v) {
          if (v == null) return;
          if (v is Map || v is List) {
            req.fields[k] = jsonEncode(v);
          } else {
            req.fields[k] = '$v';
          }
        });

        if (images.isNotEmpty) {
          if (images.length == 1) {
            req.files.add(
              await http.MultipartFile.fromPath(singleField, images.first.path),
            );
          } else {
            for (final f in images) {
              req.files.add(
                await http.MultipartFile.fromPath(multiField, f.path),
              );
            }
          }
        }

        final streamed = await req.send();
        final res = await http.Response.fromStream(streamed);
        debugPrint('$method $p (multipart) => ${res.statusCode}');
        if (res.statusCode == 201 || res.statusCode == 200) return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---------- Reservas (usuario) ----------
  Future<List<dynamic>> getMyReservations() async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final candidates = <String>[
        _join(baseApi, '/reservations/me'),
        _join(baseApi, '/reservas/mias'),
        _join(baseApi, '/reservas/me'),
        _join(baseApi, '/bookings/me'),
        _join(baseApi, '/booking/me'),
      ];

      final res = await _tryManyGet(candidates, const {});
      if (res.statusCode != 200) return const [];
      return _parseList(jsonDecode(res.body));
    } catch (_) {
      return const [];
    }
  }

  Future<List<dynamic>> getMyReservationsSafe() async {
    try {
      return await getMyReservations();
    } catch (_) {
      return <dynamic>[];
    }
  }

  // ---------- Favoritos (usuario) ----------
  Future<List<dynamic>> getMyFavorites() async {
    try {
      final base = ApiConstants.baseUrl;
      final prefix = ApiConstants.apiPrefix;
      final baseApi = prefix.isNotEmpty ? _join(base, prefix) : base;

      final candidates = <String>[
        _join(baseApi, '/favorites/me'),
        _join(baseApi, '/favoritos/mios'),
        _join(baseApi, '/favoritos/me'),
        _join(baseApi, '/properties/favorites/me'),
      ];

      final res = await _tryManyGet(candidates, const {});
      if (res.statusCode != 200) return const [];
      return _parseList(jsonDecode(res.body));
    } catch (_) {
      return const [];
    }
  }

  Future<List<dynamic>> getMyFavoritesSafe() async {
    try {
      return await getMyFavorites();
    } catch (_) {
      return <dynamic>[];
    }
  }

  // --------------- API estática (compat) ---------------
  static Future<List<dynamic>> obtenerPropiedades() async {
    final svc = PropertyService();
    return svc.getAll();
  }

  static Future<List<dynamic>> obtenerPropiedadesDestacadas() async {
    final svc = PropertyService();
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
    return svc.getAll(filters: {'ubicacion': query});
  }

  static Future<bool> reservarPropiedad(int propertyId) async {
    final svc = PropertyService();
    return svc.toggleFavorite(propertyId.toString());
  }

  static Future<List<dynamic>> obtenerReservasUsuario() async {
    final svc = PropertyService();
    return svc.getMyReservationsSafe();
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
