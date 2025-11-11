import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smartrent_plus/data/models/support_ticket_model.dart';
import 'package:smartrent_plus/data/services/soporte_service.dart';

class SoporteProvider extends ChangeNotifier {
  final SoporteService _service;

  SoporteProvider(this._service);

  // ======================================================
  // 🔹 ESTADOS GENERALES
  // ======================================================
  bool _sending = false;
  bool _loadingFaqs = false;
  bool _loadingFeedbacks = false;
  String? _error;
  SupportTicket? _lastTicket;

  bool get sending => _sending;
  bool get loadingFaqs => _loadingFaqs;
  bool get loadingFeedbacks => _loadingFeedbacks;
  String? get error => _error;
  SupportTicket? get lastTicket => _lastTicket;

  // ======================================================
  // 🔹 FAQs (locales + backend)
  // ======================================================
  List<Map<String, String>> _faqs = [
    {
      'q': 'No puedo iniciar sesión',
      'a':
          'Verifica que tu correo y contraseña sean correctos. Si olvidaste tu clave, usa la opción “Olvidé mi contraseña”.'
    },
    {
      'q': 'No me llega el código',
      'a':
          'Revisa que tu número o correo estén bien escritos. Espera unos minutos o revisa tu carpeta de spam.'
    },
    {
      'q': 'Problemas con el pago',
      'a':
          'Verifica que tu tarjeta esté habilitada para compras online o intenta con otro método de pago.'
    },
    {
      'q': 'Error al subir fotos',
      'a':
          'Las imágenes deben pesar menos de 2 MB y estar en formato JPG o PNG.'
    },
    {
      'q': '¿Cómo reporto un problema?',
      'a':
          'Ve a Soporte > Reportar un problema, describe el error y adjunta una captura si es posible.'
    },
    {
      'q': '¿Cómo contacto al soporte?',
      'a':
          'En la sección Soporte > Centro de Contacto puedes comunicarte por teléfono, WhatsApp o correo electrónico.'
    },
  ];
  List<Map<String, String>> get faqs => _faqs;

  Future<void> loadFaqs() async {
    _loadingFaqs = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _service.fetchFaqs();
      if (fetched.isNotEmpty) {
        _faqs = fetched;
      }
    } catch (e) {
      _error = 'No se pudieron cargar las FAQs del servidor.';
      if (kDebugMode) print('⚠️ Error cargando FAQs: $e');
    } finally {
      _loadingFaqs = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 🔹 TICKETS
  // ======================================================
  Future<String?> _fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<bool> sendTicket({
    required String subject,
    required String description,
    String? category,
    XFile? image,
  }) async {
    _sending = true;
    _error = null;
    notifyListeners();

    try {
      String? base64;
      if (image != null) {
        base64 = await _fileToBase64(File(image.path));
      }

      final ticket = SupportTicket(
        subject: subject,
        description: description,
        category: category,
        imageBase64: base64,
      );

      final created = await _service.createTicket(ticket);
      _lastTicket = created;
      _sending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _sending = false;
      _error = 'Error enviando ticket: $e';
      notifyListeners();
      return false;
    }
  }

  // ======================================================
  // 🔹 RESEÑAS (Feedback)
  // ======================================================

  List<Map<String, dynamic>> _feedbacks = [];
  Map<String, dynamic>? _stats;

  List<Map<String, dynamic>> get feedbacks => _feedbacks;
  Map<String, dynamic>? get stats => _stats;

  /// 📤 Enviar una reseña como usuario
  Future<void> enviarResena({
    required int rating,
    required String comentario,
  }) async {
    try {
      await _service.sendFeedback(rating: rating, comment: comentario);
      await fetchFeedbacks();
    } catch (e) {
      _error = 'Error al enviar reseña: $e';
      notifyListeners();
    }
  }

  /// 📥 Obtener todas las reseñas (modo admin)
  Future<void> fetchFeedbacks() async {
    _loadingFeedbacks = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.getAllFeedback();
      _feedbacks = data;
    } catch (e) {
      _error = 'Error al cargar reseñas: $e';
    } finally {
      _loadingFeedbacks = false;
      notifyListeners();
    }
  }

  /// 📈 Obtener estadísticas (promedio y cantidad)
  Future<void> fetchFeedbackStats() async {
    try {
      final data = await _service.getFeedbackStats();
      _stats = data;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Error obteniendo stats: $e');
    }
  }

  /// 📨 Responder reseña del usuario (ADMIN)
  Future<void> responderResena(int id, String respuesta) async {
    try {
      await _service.updateFeedback(id: id, respuesta: respuesta);
      await fetchFeedbacks(); // refresca lista después de responder
    } catch (e) {
      _error = 'Error enviando respuesta: $e';
      notifyListeners();
    }
  }
}
