// ===============================================================
// 🔹 SUBSCRIPTION SERVICE – SmartRent+
// Conecta Flutter con el backend NestJS (pagos y planes)
// ===============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionService {
  static const String baseUrl =
      "http://10.0.2.2:3000/api/subscriptions"; // Ajusta si usas IP local

  // 🔸 Crear transacción Webpay
  static Future<Map<String, dynamic>?> createPayment(
      int userId, String plan) async {
    try {
      final url = Uri.parse('$baseUrl/pay');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'plan': plan}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Error al crear pago: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Excepción en createPayment: $e');
      return null;
    }
  }

  // 🔸 Obtener suscripción activa
  static Future<Map<String, dynamic>?> getActiveSubscription(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/mine/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('⚠️ Error al obtener suscripción activa: $e');
      return null;
    }
  }
}
