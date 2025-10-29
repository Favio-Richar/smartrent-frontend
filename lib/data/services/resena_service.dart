import 'package:smartrent_plus/data/services/api_service.dart';

class ResenaService {
  final ApiService _api;
  ResenaService({String? token}) : _api = ApiService(token: token);

  // GET /resenas/empresa/:id
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    final json = await _api.get('/resenas/empresa/$companyId');
    return (json as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // POST /resenas
  Future<void> create(Map<String, dynamic> payload) async {
    await _api.post('/resenas', payload);
  }

  // POST /resenas/:id/responder  { respuesta: '...' }
  Future<void> respond(String reviewId, String respuesta) async {
    await _api.post('/resenas/$reviewId/responder', {'respuesta': respuesta});
  }
}
