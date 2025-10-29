import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/core/utils/constants.dart';

class AuthService {
  // ---------- helpers ----------
  static Uri _join(String base, String path) {
    if (base.endsWith('/') && path.startsWith('/')) {
      return Uri.parse(base + path.substring(1));
    }
    if (!base.endsWith('/') && !path.startsWith('/')) {
      return Uri.parse('$base/$path');
    }
    return Uri.parse(base + path);
  }

  static Future<Map<String, dynamic>> _postJson(
    Uri url,
    Map body, {
    Map<String, String>? headers,
  }) async {
    final h = {'Content-Type': 'application/json', ...?headers};
    final res = await http.post(url, headers: h, body: jsonEncode(body));
    final obj = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (kDebugMode) {
      debugPrint('📤 POST $url');
      debugPrint('📩 (${res.statusCode}) $obj');
    }
    return {
      'status': res.statusCode,
      'ok': res.statusCode >= 200 && res.statusCode < 300,
      'body': obj,
    };
  }

  // ============================================================
  // LOGIN
  // ============================================================
  static Future<bool> login(String email, String password) async {
    final base = ApiConstants.baseUrl;
    final api = ApiConstants.apiPrefix;

    final urls = <Uri>[
      _join(base, '$api/auth/login'),
      _join(base, '/auth/login'),
    ];

    Map<String, dynamic>? last;
    for (final u in urls) {
      final body = {
        'email': email,
        'password': password,
        'correo': email,
        'contrasena': password,
      };
      last = await _postJson(u, body);
      if (last['status'] != 404) break;
    }

    final status = last!['status'] as int;
    final data = last['body'];

    if (last['ok'] == true) {
      final token = (data?['access_token'] ?? data?['token'] ?? '') as String;
      final user =
          (data?['user'] ?? data?['data']?['user'] ?? {})
              as Map<String, dynamic>;
      if (token.isEmpty || user.isEmpty) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      if (user['id'] is int) await prefs.setInt('userId', user['id'] as int);
      await prefs.setString(
        'userRole',
        (user['tipoCuenta'] ?? user['role'] ?? 'Usuario').toString(),
      );
      return true;
    }

    if (status == 404) {
      debugPrint(
        '❌ 404: Revisa que el front use ${ApiConstants.apiPrefix}/auth/login',
      );
    } else if (status == 401 || status == 400) {
      debugPrint('❌ Credenciales inválidas.');
    } else {
      debugPrint('❌ Error $status: $data');
    }
    return false;
  }

  // ============================================================
  // REGISTRO
  // ============================================================
  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    final base = ApiConstants.baseUrl;
    final api = ApiConstants.apiPrefix;

    final urls = <Uri>[
      _join(base, '$api/auth/register'),
      _join(base, '/auth/register'),
    ];

    Map<String, dynamic>? last;
    for (final u in urls) {
      final body = {
        'nombre': name,
        'email': email,
        'password': password,
        'correo': email,
        'contrasena': password,
        'tipoCuenta': 'Usuario',
      };
      last = await _postJson(u, body);
      if (last['status'] != 404) break;
    }

    return last!['ok'] == true;
  }

  // ============================================================
  // RECUPERAR CONTRASEÑA (solicitar token)
  // Devuelve (ok, tokenOrMsg). En dev el backend retorna dev_token.
  // ============================================================
  static Future<(bool ok, String tokenOrMsg)> forgotPassword(
    String email,
  ) async {
    final base = ApiConstants.baseUrl;
    final api = ApiConstants.apiPrefix;

    final urls = <Uri>[
      _join(base, '$api/auth/forgot'),
      _join(base, '/auth/forgot'),
    ];

    Map<String, dynamic>? last;
    for (final u in urls) {
      last = await _postJson(u, {'email': email, 'correo': email});
      if (last['status'] != 404) break;
    }

    final ok = last!['ok'] == true;
    final body = (last['body'] ?? {}) as Map<String, dynamic>;

    if (ok) {
      // En modo dev el backend retorna dev_token
      final token =
          (body['dev_token'] ?? body['reset_token'] ?? body['token'] ?? '')
              .toString();
      return (true, token.isNotEmpty ? token : 'Enviado');
    }

    final msg = (body['message'] ?? 'Error al solicitar recuperación')
        .toString();
    return (false, msg);
  }

  // ============================================================
  // RESETEAR CONTRASEÑA (usar token/código)
  // ============================================================
  static Future<(bool ok, String msg)> resetPassword({
    required String email,
    required String newPassword,
    required String token,
  }) async {
    final base = ApiConstants.baseUrl;
    final api = ApiConstants.apiPrefix;

    final urls = <Uri>[
      _join(base, '$api/auth/reset'),
      _join(base, '/auth/reset'),
    ];

    Map<String, dynamic>? last;
    for (final u in urls) {
      // Enviamos ambas claves por compatibilidad:
      // - code (lo que el backend espera)
      // - token (por si el backend también lo lee)
      // - newPassword y, por compatibilidad, password/contrasena
      last = await _postJson(u, {
        'email': email,
        'correo': email,
        'code': token,
        'token': token,
        'newPassword': newPassword,
        'password': newPassword,
        'contrasena': newPassword,
      });
      if (last['status'] != 404) break;
    }

    final ok = last!['ok'] == true;
    if (ok) return (true, 'Contraseña actualizada');
    final msg = (last['body']?['message']?.toString() ?? 'Error al actualizar');
    return (false, msg);
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (kDebugMode) debugPrint('👋 Sesión cerrada (prefs limpiadas).');
  }

  // ============================================================
  // USER LOCAL
  // ============================================================
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    final role = prefs.getString('userRole');
    final token = prefs.getString('token');
    if (id == null || token == null) return null;
    return {'id': id, 'role': role, 'token': token};
  }
}
