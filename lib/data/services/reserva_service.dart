// lib/data/services/reserva_service.dart
// ===============================================================
// RESERVA SERVICE - SmartRent+
// - alineado al backend Nest: /api/reservas...
// - NO lanza excepción si el backend responde 404: devuelve []
// - siempre intenta con plural y singular
// ===============================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/data/services/api_service.dart';

class ReservaService {
  // ej: http://10.0.2.2:3000/api
  String get _api => ApiService.Api;

  // -----------------------------------------------------------
  // headers con token
  // -----------------------------------------------------------
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ============================================================
  // 1) MIS RESERVAS (las que hizo el usuario)
  // ============================================================
  Future<List<Map<String, dynamic>>> getMine() async {
    final h = await _headers();
    final urls = <String>[
      '$_api/reservas/mias',
      '$_api/reservas',
      '$_api/reserva/mias',
      '$_api/reserva',
    ];

    for (final url in urls) {
      try {
        if (kDebugMode) debugPrint('📡 [getMine] GET $url');
        final res = await http.get(Uri.parse(url), headers: h);

        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          if (body is List) {
            return body
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList();
          }
          if (body is Map && body['data'] is List) {
            return (body['data'] as List)
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList();
          }
          return [];
        }

        // si el back todavía no tiene la ruta → devolvemos lista vacía
        if (res.statusCode == 401 ||
            res.statusCode == 403 ||
            res.statusCode == 404) {
          return [];
        }
      } on SocketException {
        throw Exception('Sin conexión con el servidor.');
      }
    }

    return [];
  }

  // ============================================================
  // 2) RESERVAS RECIBIDAS (las que llegan a mis propiedades)
  // ============================================================
  Future<List<Map<String, dynamic>>> getReceived() async {
    final h = await _headers();
    final urls = <String>[
      '$_api/reservas/recibidas',
      '$_api/reservas',
      '$_api/reserva/recibidas',
      '$_api/reserva',
    ];

    for (final url in urls) {
      try {
        if (kDebugMode) debugPrint('📡 [getReceived] GET $url');
        final res = await http.get(Uri.parse(url), headers: h);

        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          if (body is List) {
            return body
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList();
          }
          if (body is Map && body['data'] is List) {
            return (body['data'] as List)
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList();
          }
          return [];
        }

        // 👇 AQUÍ estaba tu excepción antes
        if (res.statusCode == 401 ||
            res.statusCode == 403 ||
            res.statusCode == 404) {
          return [];
        }
      } on SocketException {
        throw Exception('Sin conexión con el servidor.');
      }
    }

    return [];
  }

  // ============================================================
  // 3) CAMBIAR ESTADO
  // ============================================================
  Future<bool> updateStatus(String id, String estado) async {
    final h = await _headers();
    final body = jsonEncode({'estado': estado});

    final urls = <String>[
      '$_api/reservas/$id/estado',
      '$_api/reserva/$id/estado',
      '$_api/reservas/$id',
      '$_api/reserva/$id',
    ];

    for (final url in urls) {
      try {
        final res = await http.patch(Uri.parse(url), headers: h, body: body);
        if (res.statusCode == 200 || res.statusCode == 204) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  // ============================================================
  // 4) CANCELAR
  // ============================================================
  Future<bool> cancel(String id) async {
    final h = await _headers();
    final urls = <String>[
      '$_api/reservas/$id/cancelar',
      '$_api/reserva/$id/cancelar',
      '$_api/reservas/$id/cancel',
      '$_api/reserva/$id/cancel',
    ];

    for (final url in urls) {
      try {
        final res = await http.post(Uri.parse(url), headers: h);
        if (res.statusCode == 200 || res.statusCode == 204) {
          return true;
        }
      } catch (_) {}
    }

    // último intento: cambiar estado
    return await updateStatus(id, 'Cancelada');
  }

  // ============================================================
  // 5) CREAR (cuando mandas desde el bottomsheet)
  // ============================================================
  Future<bool> create(Map<String, dynamic> payload) async {
    final h = await _headers();

    // normalización: tu back espera propiedad_id / propertyId
    if (payload.containsKey('property_id') &&
        !payload.containsKey('propiedad_id')) {
      payload['propiedad_id'] = payload['property_id'];
    }

    final urls = <String>['$_api/reservas', '$_api/reserva'];

    for (final url in urls) {
      final res = await http.post(
        Uri.parse(url),
        headers: h,
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        debugPrint(
          '! [create] $url -> ${res.statusCode} -> ${res.body.toString()}',
        );
      }

      if (res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204) {
        return true;
      }
    }

    return false;
  }
}
