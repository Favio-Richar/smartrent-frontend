import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/subscription_service.dart';
import 'package:smartrent_plus/features/suscripciones/pago_webpay_page.dart';

class SubscriptionProvider extends ChangeNotifier {
  Future<String?> iniciarPago(
    BuildContext context,
    String plan,
    int userId,
    Color color,
    String precio,
  ) async {
    print("📤 Enviando petición al backend para crear pago...");
    final resp = await SubscriptionService.createPayment(userId, plan);

    if (resp == null) {
      print("❌ ERROR: createPayment devolvió null");
      return null;
    }

    if (!resp.containsKey("url") || !resp.containsKey("token")) {
      print("❌ ERROR: Backend no envió url/token válidos");
      return null;
    }

    final String url = resp["url"];
    final String token = resp["token"];

    print("✅ URL WebPay: $url");
    print("🔑 Token: $token");

    // Ir a pantalla de pago WebPay
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PagoWebPayPage(url: url, token: token),
      ),
    );

    return "ok";
    print("📦 createPayment RESPUESTA: $resp");
  }
}
