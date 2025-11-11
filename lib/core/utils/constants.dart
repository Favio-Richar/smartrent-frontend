// ===============================================================
// 🔹 API CONSTANTS - SmartRent+ (versión PRO con ambientes múltiples)
// ===============================================================

class ApiConstants {
  /// 🌐 Cambia este valor según tu entorno actual:
  static const bool isEmulator = true; // ✅ true → 10.0.2.2 / false → LAN / prod

  // 🔹 Base URLs automáticas
  static String get baseUrl {
    if (isEmulator) return 'http://10.0.2.2:3000'; // Android emulator
    return 'http://192.168.0.10:3000'; // ⚙️ IP local (ajusta a la tuya)
    // return 'https://api.smartrentplus.cl'; // 🌍 Producción
  }

  static const String apiPrefix = '/api';

  /// 🔗 Construye URLs limpias para peticiones (ej: /uploads/image)
  static String url(String path) {
    String clean = path.trim();
    if (clean.startsWith('/')) clean = clean.substring(1);
    final uri = Uri.parse('$baseUrl$apiPrefix/$clean');
    return uri.toString();
  }

  /// 🖼️ Devuelve URL absoluta de imágenes/videos
  static String media(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    var s = raw.replaceAll('\\', '/');
    if (s.startsWith('./')) s = s.substring(2);
    if (s.startsWith('/./')) s = s.substring(3);
    if (s.startsWith('public/')) s = s.substring(7);
    if (s.startsWith('/public/')) s = s.substring(8);
    if (s.startsWith('/api/')) s = s.substring(4);
    if (!s.startsWith('/')) s = '/$s';

    final fixed = '$baseUrl$s'
        .replaceAll(RegExp(r'(?<!:)//'), '/')
        .replaceFirst('http:/', 'http://');
    return fixed;
  }
}
