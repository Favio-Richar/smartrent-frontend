// ===============================================================
// 📡 SERVICIO DE ESTADÍSTICAS – SmartRent+
// ---------------------------------------------------------------
// ✅ Obtiene resumen filtrado desde backend
// ✅ Descarga PDF / Excel binarios
// ✅ Guarda archivos en carpeta pública /Download/SmartRent+
// ✅ Compatible con Android / iOS
// ===============================================================

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:convert';
import 'package:smartrent_plus/core/utils/constants.dart';

class EstadisticaService {
  final String baseUrl = ApiConstants.baseUrl;

  // ===========================================================
  // 🔹 Obtener resumen general (GET /estadisticas/arriendos)
  //    con soporte de período: dia / semana / mes / anio
  // ===========================================================
  Future<Map<String, dynamic>> resumenEmpresa({String periodo = 'mes'}) async {
    final url =
        Uri.parse('$baseUrl/api/estadisticas/arriendos?periodo=$periodo');
    final response =
        await http.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al obtener estadísticas (${response.statusCode})');
    }
  }

  // ===========================================================
  // 🔹 Helper: crea carpeta pública para descargas visibles
  // ===========================================================
  Future<Directory> _prepareDownloadDir() async {
    Directory? dir;

    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Permiso de almacenamiento denegado');
      }
      dir = Directory('/storage/emulated/0/Download/SmartRent');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    return dir;
  }

  // ===========================================================
  // 🔹 Exportar a Excel (descargar, guardar y abrir)
  // ===========================================================
  Future<void> exportExcel() async {
    final url = Uri.parse('$baseUrl/api/estadisticas/arriendos/export/excel');
    final response = await http.get(url, headers: {
      'Accept':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    });

    if (response.statusCode == 200) {
      final dir = await _prepareDownloadDir();
      final filePath = '${dir.path}/estadisticas_arriendos.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await OpenFilex.open(filePath);
    } else {
      throw Exception('Error al exportar Excel (${response.statusCode})');
    }
  }

  // ===========================================================
  // 🔹 Exportar a PDF (descargar, guardar y abrir)
  // ===========================================================
  Future<void> exportPdf() async {
    final url = Uri.parse('$baseUrl/api/estadisticas/arriendos/export/pdf');
    final response =
        await http.get(url, headers: {'Accept': 'application/pdf'});

    if (response.statusCode == 200) {
      final dir = await _prepareDownloadDir();
      final filePath = '${dir.path}/estadisticas_arriendos.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await OpenFilex.open(filePath);
    } else {
      throw Exception('Error al exportar PDF (${response.statusCode})');
    }
  }
}
