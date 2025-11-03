// lib/data/services/estadistica_service.dart
import 'package:smartrent_plus/data/services/api_service.dart';

class EstadisticaService {
  final ApiService _api;
  EstadisticaService({String? token}) : _api = ApiService(token: token);

  /// GET /api/estadisticas/arriendos
  Future<List<dynamic>> resumenEmpresa() async {
    final json = await _api.get(
      'estadisticas/arriendos',
    ); // ruta relativa (sin http:// y sin localhost)
    return (json ?? []) as List;
  }

  /// GET /api/estadisticas/arriendos/export/excel
  Future<void> exportExcel() async {
    await _api.get('estadisticas/arriendos/export/excel');
  }

  /// GET /api/estadisticas/arriendos/export/pdf
  Future<void> exportPdf() async {
    await _api.get('estadisticas/arriendos/export/pdf');
  }
}
