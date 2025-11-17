import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartrent_plus/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComentariosService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // --------------------------------------------------------
  // 🔥 AGREGAR COMENTARIO
  // --------------------------------------------------------
  static Future<bool> agregarComentario(int publicacionId, String texto) async {
    try {
      // ⬅ USANDO TU APIConstants CORRECTAMENTE
      final url = Uri.parse(ApiConstants.url("comentarios"));
      final headers = await _headers();

      final body = jsonEncode({
        "publicacion_id": publicacionId,
        "texto": texto,
      });

      final res = await http.post(url, headers: headers, body: body);

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("❌ Error agregando comentario: $e");
      return false;
    }
  }
}
