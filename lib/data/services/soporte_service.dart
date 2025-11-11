// ===============================================================
// 🔹 SOPORTE SERVICE – Administración completa de soporte
// ---------------------------------------------------------------
// - CRUD de tickets de soporte (crear, listar, actualizar, eliminar)
// - FAQs, Feedback y Comunidad
// - Compatibilidad con imageBase64 o imageUrl
// - Control robusto de errores HTTP y respuestas flexibles
// - Integración total con panel admin (reseñas y comunidad)
// ===============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smartrent_plus/data/models/support_ticket_model.dart';
import 'package:smartrent_plus/data/services/api_service.dart';

class SoporteService {
  final ApiService _api;
  SoporteService(this._api);

  // ============================================================
  // 🔹 Crear ticket de soporte (Usuario)
  // ============================================================
  Future<SupportTicket> createTicket(SupportTicket ticket) async {
    try {
      final res = await _api.post('/support/tickets', ticket.toJson());
      final decoded = _decodeResponse(res);
      final data = decoded['ticket'] ?? decoded;
      return SupportTicket.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('No se pudo crear el ticket: $e');
    }
  }

  // ============================================================
  // 🔹 Obtener todos los tickets (Admin)
  // ============================================================
  Future<List<Map<String, dynamic>>> fetchAllTickets() async {
    try {
      final res = await _api.get('/support/tickets');
      final decoded = _decodeResponse(res);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        throw Exception('Respuesta inesperada al obtener tickets');
      }
    } catch (e) {
      throw Exception('Error al obtener tickets: $e');
    }
  }

  // ============================================================
  // 🔹 Actualizar ticket (estado / respuesta / seguimiento)
  // ============================================================
  Future<void> updateTicket(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/support/tickets/$id', data);
      _verifyResponse(res, 'Error actualizando ticket');
    } catch (e) {
      throw Exception('No se pudo actualizar el ticket: $e');
    }
  }

  // ============================================================
  // 🔹 Eliminar ticket (Admin)
  // ============================================================
  Future<void> deleteTicket(int id) async {
    try {
      final res = await _api.delete('/support/tickets/$id');
      _verifyResponse(res, 'Error eliminando ticket');
    } catch (e) {
      throw Exception('No se pudo eliminar el ticket: $e');
    }
  }

  // ============================================================
  // 🔹 FAQs (Preguntas frecuentes)
  // ============================================================
  Future<List<Map<String, String>>> fetchFaqs() async {
    try {
      final res = await _api.get('/support/faqs');
      final decoded = _decodeResponse(res);

      if (decoded is List) {
        return decoded
            .map<Map<String, String>>((e) => {
                  'q': e['question']?.toString() ?? '',
                  'a': e['answer']?.toString() ?? '',
                })
            .toList();
      }

      // fallback por defecto
      return [
        {
          'q': 'No puedo iniciar sesión',
          'a': 'Verifica tu correo y contraseña.'
        },
        {
          'q': 'Problemas con el pago',
          'a': 'Revisa tu método o contacta soporte.'
        },
        {
          'q': 'Error al subir fotos',
          'a': 'Las imágenes deben ser JPG o PNG menores a 2MB.'
        },
      ];
    } catch (e) {
      throw Exception('Error obteniendo FAQs: $e');
    }
  }

  // ============================================================
  // 🔹 Enviar feedback (reseña de usuario)
  // ============================================================
  Future<void> sendFeedback({
    required int rating,
    required String comment,
  }) async {
    try {
      final res = await _api.post('/support/feedback', {
        'rating': rating,
        'comment': comment,
      });
      _verifyResponse(res, 'Error enviando reseña');
    } catch (e) {
      throw Exception('No se pudo enviar el feedback: $e');
    }
  }

  // ============================================================
  // 🔹 Obtener estadísticas de feedback (promedio, total)
  // ============================================================
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final res = await _api.get('/support/feedback/stats');
      final decoded = _decodeResponse(res);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw Exception('Respuesta inválida en estadísticas');
      }
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // ============================================================
  // 🔹 Obtener todas las reseñas (Admin)
  // ============================================================
  Future<List<Map<String, dynamic>>> getAllFeedback() async {
    try {
      final res = await _api.get('/support/feedback');
      final decoded = _decodeResponse(res);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        throw Exception('Respuesta inesperada al listar reseñas');
      }
    } catch (e) {
      throw Exception('Error al obtener reseñas: $e');
    }
  }

  // ============================================================
  // 🔹 Responder reseña (Admin)
  // ============================================================
  Future<void> updateFeedback({
    required int id,
    required String respuesta,
  }) async {
    try {
      final res = await _api.put('/support/feedback/$id', {
        'respuesta': respuesta,
      });
      _verifyResponse(res, 'Error al responder reseña');
    } catch (e) {
      throw Exception('No se pudo actualizar la reseña: $e');
    }
  }

  // ============================================================
  // 🔹 Comunidad: listar publicaciones
  // ============================================================
  Future<List<Map<String, dynamic>>> fetchCommunityPosts() async {
    try {
      final res = await _api.get('/support/community');
      final decoded = _decodeResponse(res);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      throw Exception('Error cargando comunidad');
    } catch (e) {
      throw Exception('Error obteniendo comunidad: $e');
    }
  }

  // ============================================================
  // 🔹 Comunidad: crear publicación
  // ============================================================
  Future<void> createCommunityPost({
    required String author,
    required String title,
    required String body,
  }) async {
    try {
      final res = await _api.post('/support/community', {
        'author': author,
        'title': title,
        'body': body,
      });
      _verifyResponse(res, 'Error creando publicación');
    } catch (e) {
      throw Exception('No se pudo crear la publicación: $e');
    }
  }

  // ============================================================
  // 🔹 Helpers comunes para procesar respuestas HTTP
  // ============================================================
  dynamic _decodeResponse(dynamic res) {
    try {
      if (res is Map<String, dynamic>) return res;
      if (res is List) return res;
      if (res is http.Response) return jsonDecode(res.body);
      if (res is String) return jsonDecode(res);
    } catch (e) {
      throw Exception('Error al procesar respuesta: $e');
    }
    throw Exception('Respuesta inesperada del servidor');
  }

  void _verifyResponse(dynamic res, String message) {
    if (res is http.Response) {
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('$message: ${res.statusCode}');
      }
    } else if (res is Map && res['success'] == false) {
      throw Exception('$message: ${res['message'] ?? 'Error desconocido'}');
    }
  }
}
