import 'package:smartrent_plus/data/services/api_service.dart';

class EstadisticaService {
  final ApiService _api;
  EstadisticaService({String? token}) : _api = ApiService(token: token);

  // GET /estadisticas/arriendos
  Future<List<dynamic>> resumenEmpresa() async {
    final json = await _api.get('/estadisticas/arriendos');
    return json as List;
  }

  // GET /estadisticas/arriendos/export/excel
  Future<void> exportExcel() async {
    await _api.get('/estadisticas/arriendos/export/excel');
  }

  // GET /estadisticas/arriendos/export/pdf
  Future<void> exportPdf() async {
    await _api.get('/estadisticas/arriendos/export/pdf');
  }
}
