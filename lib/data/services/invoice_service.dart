import 'package:smartrent_plus/data/services/api_service.dart';
import 'package:smartrent_plus/core/utils/constants.dart';

class InvoiceService {
  // ===================================================
  // 🔹 Obtener boletas por usuario
  // ===================================================
  static Future<List<dynamic>> getInvoicesByUser(int userId) async {
    final token = await ApiConstants.getToken();
    final api = ApiService(token: token);
    final resp = await api.get("invoice/user/$userId");
    return resp ?? [];
  }

  // ===================================================
  // 🔹 Obtener una boleta por ID
  // ===================================================
  static Future<Map<String, dynamic>> getInvoice(int id) async {
    final token = await ApiConstants.getToken();
    final api = ApiService(token: token);
    final resp = await api.get("invoice/$id");
    return resp ?? {};
  }

  // ===================================================
  // 🔹 Descargar PDF
  // ===================================================
  static Future<void> downloadInvoice(int id) async {
    final token = await ApiConstants.getToken();
    final api = ApiService(token: token);
    await api.getFile("invoice/download/$id");
  }

  // ===================================================
  // 🔹 Enviar Boleta por correo
  // ===================================================
  static Future<String> sendInvoiceEmail(int paymentId, String email) async {
    final token = await ApiConstants.getToken();
    final api = ApiService(token: token);
    final resp = await api.post("invoice/send-email", {
      "paymentId": paymentId,
      "email": email,
    });

    return resp["message"] ?? "Correo enviado";
  }
}
