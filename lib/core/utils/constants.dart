// lib/core/utils/constants.dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String apiPrefix = '/api'; // <-- tu Nest usa este prefijo
  static String url(String path) => '$baseUrl$apiPrefix/$path';
}
