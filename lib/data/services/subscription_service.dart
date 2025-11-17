// ======================================================================
// 💳 SUBSCRIPTION SERVICE – FINAL 2025 COMPLETO Y SIN ERRORES
// ======================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionService {
  static const String baseUrl = "http://10.0.2.2:3000/api/subscriptions";

  // =============================================================
  // 🔥 Crear pago WebPay (POST /create)
  // =============================================================
  static Future<Map<String, dynamic>?> createPayment(
      int userId, String plan) async {
    try {
      print("📤 Enviando POST a: $baseUrl/create");
      print("📦 Body: userId=$userId, plan=$plan");

      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'plan': plan,
        }),
      );

      print("📥 STATUS: ${response.statusCode}");
      print("📥 RESPUESTA RAW: ${response.body}");

      // Asegurar que no venga vacío
      if (response.body.isEmpty) {
        print("❌ ERROR: Backend devolvió body vacío");
        return null;
      }

      // Asegurar que sea JSON válido
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print("❌ ERROR: JSON inválido en createPayment: $e");
        return null;
      }

      // Convertir correctamente
      final Map<String, dynamic> result =
          decoded is Map ? Map<String, dynamic>.from(decoded) : {};

      print("📦 RESULT MAP: $result");

      if (!result.containsKey("url") || !result.containsKey("token")) {
        print("❌ ERROR: Falta url/token en backend");
        return null;
      }

      print("✅ URL WEBPAY = ${result["url"]}");
      print("🔑 TOKEN      = ${result["token"]}");

      return result;
    } catch (e) {
      print("❌ EXCEPCIÓN createPayment: $e");
      return null;
    }
  }

  // =============================================================
  // 🔹 Obtener suscripción activa
  // =============================================================
  static Future<Map<String, dynamic>?> getActiveSubscription(int userId) async {
    try {
      print("📤 GET → $baseUrl/mine/$userId");

      final response = await http.get(Uri.parse('$baseUrl/mine/$userId'));

      print("📥 STATUS: ${response.statusCode}");
      print("📥 RESPUESTA RAW: ${response.body}");

      if (response.body.isEmpty) {
        print("⚠ No hay suscripción activa");
        return null;
      }

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print("❌ ERROR JSON getActiveSubscription: $e");
        return null;
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      print("❌ EXCEPCIÓN getActiveSubscription: $e");
      return null;
    }
  }
}
