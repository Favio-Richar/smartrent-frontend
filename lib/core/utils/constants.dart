// ===============================================================
// 🔹 API CONSTANTS - SmartRent+ (versión FINAL con getToken)
// ===============================================================

import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  /// 🌐 Cambia según entorno:
  static const bool isEmulator = true;

  // 🔹 URL Base automática
  static String get baseUrl {
    if (isEmulator) return 'http://10.0.2.2:3000';
    return 'http://192.168.0.10:3000';
    // return 'https://api.smartrentplus.cl'; // producción
  }

  static const String apiPrefix = '/api';

  /// 🔗 URL limpia
  static String url(String path) {
    String clean = path.trim();
    if (clean.startsWith('/')) clean = clean.substring(1);
    return '$baseUrl$apiPrefix/$clean';
  }

  /// 🖼️ URL media
  static String media(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http')) return raw;

    var s = raw.replaceAll('\\', '/');
    if (s.startsWith('./')) s = s.substring(2);
    if (!s.startsWith('/')) s = '/$s';

    return '$baseUrl$s';
  }

  // ===============================================================
  // 🔥 MÉTODO OBLIGATORIO QUE FALTABA
  // ===============================================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
}
