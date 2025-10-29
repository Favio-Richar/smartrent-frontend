import 'package:smartrent_plus/data/services/api_service.dart';

class CompanyService {
  final ApiService _api;
  CompanyService({String? token}) : _api = ApiService(token: token);

  // GET /companies/public/:id
  Future<Map<String, dynamic>> getPublicProfile(String id) async {
    final json = await _api.get('/companies/public/$id');
    return Map<String, dynamic>.from(json as Map);
  }
}
