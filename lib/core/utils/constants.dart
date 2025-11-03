// lib/core/utils/constants.dart
class ApiConstants {
  // 👇 Emulador Android usa 10.0.2.2 para llegar al host (tu PC)
  static const String baseUrl = 'http://10.0.2.2:3000';
  // Si ejecutas Flutter Web/Escritorio, puedes temporalmente usar:
  // static const String baseUrl = 'http://localhost:3000';

  // Tu backend Nest usa prefijo global 'api'
  static const String apiPrefix = '/api';

  // Helper para componer URL limpias
  static String url(String path) {
    // Evita // en la URL final
    final clean = path.startsWith('/') ? path.substring(1) : path;
    final prefix = apiPrefix.endsWith('/')
        ? apiPrefix.substring(0, apiPrefix.length - 1)
        : apiPrefix;
    return '$baseUrl$prefix/$clean';
  }
}
