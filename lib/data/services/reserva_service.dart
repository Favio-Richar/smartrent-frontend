import 'package:smartrent_plus/data/services/api_service.dart';

class ReservaService {
  final ApiService _api;
  ReservaService({String? token}) : _api = ApiService(token: token);

  // POST /reservas
  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final json = await _api.post('/reservas', payload);
    return Map<String, dynamic>.from(json as Map);
  }

  // GET /reservas/mias  (usuario)
  Future<List<Map<String, dynamic>>> getMine() async {
    final json = await _api.get('/reservas/mias');
    return (json as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // GET /reservas/recibidas (empresa)
  Future<List<Map<String, dynamic>>> getReceived() async {
    final json = await _api.get('/reservas/recibidas');
    return (json as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // PUT /reservas/:id/estado  { estado: 'Pendiente'|'Aprobada'|'Cancelada' }
  Future<void> updateStatus(String id, String estado) async {
    await _api.put('/reservas/$id/estado', {'estado': estado});
  }

  // PUT /reservas/:id/cancelar  (usuario)
  Future<void> cancel(String id) async {
    await _api.put('/reservas/$id/cancelar', {});
  }
}
