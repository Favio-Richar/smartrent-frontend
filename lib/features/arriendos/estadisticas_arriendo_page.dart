// ===============================================================
// 📊 ESTADÍSTICAS ARRIENDOS – SmartRent+ Dashboard Avanzado
// ---------------------------------------------------------------
// ✅ KPI Cards animadas
// ✅ Filtros por período
// ✅ Gráficos de barras y circular
// ✅ Sugerencias automáticas
// ✅ Loader Lottie animado
// ✅ Exportar PDF / Excel desde backend
// ✅ Diseño moderno y adaptable
// ===============================================================

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:smartrent_plus/data/services/estadistica_service.dart';

class EstadisticasArriendoPage extends StatefulWidget {
  const EstadisticasArriendoPage({super.key});

  @override
  State<EstadisticasArriendoPage> createState() =>
      _EstadisticasArriendoPageState();
}

class _EstadisticasArriendoPageState extends State<EstadisticasArriendoPage> {
  final _svc = EstadisticaService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _periodo = 'mes'; // Día, semana, mes, año

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ===============================================================
  // 🔹 Cargar datos desde backend con filtro
  // ===============================================================
  Future<void> _load() async {
    try {
      setState(() => _loading = true);
      final d = await _svc.resumenEmpresa(periodo: _periodo);
      if (!mounted) return;
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error cargando estadísticas: $e');
      setState(() => _loading = false);
    }
  }

  // ===============================================================
  // 🔹 Cambiar período
  // ===============================================================
  void _cambiarPeriodo(String nuevo) {
    setState(() => _periodo = nuevo);
    _load();
  }

  // ===============================================================
  // 🔹 Exportar PDF / Excel
  // ===============================================================
  Future<void> _exportExcel() async {
    try {
      await _svc.exportExcel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Excel exportado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al exportar Excel: $e')),
      );
    }
  }

  Future<void> _exportPdf() async {
    try {
      await _svc.exportPdf();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ PDF exportado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al exportar PDF: $e')),
      );
    }
  }

  // ===============================================================
  // 🔹 Interfaz principal
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMM yyyy', 'es').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: 'Exportar Excel',
            onPressed: _exportExcel,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Lottie.asset(
                'assets/animations/stats_loading.json',
                width: 200,
                repeat: true,
              ),
            )
          : _data == null
              ? const Center(child: Text('No hay datos disponibles'))
              : _buildDashboard(fecha),
    );
  }

  // ===============================================================
  // 🔹 Dashboard completo
  // ===============================================================
  Widget _buildDashboard(String fecha) {
    final d = _data!;

    final kpi = [
      {
        'title': 'Publicadas',
        'value': d['published'] ?? 0,
        'icon': Icons.check_circle,
        'color': Colors.green
      },
      {
        'title': 'Borradores',
        'value': d['drafts'] ?? 0,
        'icon': Icons.edit_note,
        'color': Colors.blueGrey
      },
      {
        'title': 'Reservas',
        'value': d['reservations'] ?? 0,
        'icon': Icons.calendar_month,
        'color': Colors.purple
      },
      {
        'title': 'Canceladas',
        'value': d['cancelled'] ?? 0,
        'icon': Icons.cancel,
        'color': Colors.redAccent
      },
      {
        'title': 'Ganancias',
        'value': d['earnings'] ?? 0,
        'icon': Icons.attach_money,
        'color': Colors.teal
      },
      {
        'title': 'Visitas',
        'value': d['views'] ?? 0,
        'icon': Icons.visibility,
        'color': Colors.indigo
      },
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === FILTROS ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Período:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                DropdownButton<String>(
                  value: _periodo,
                  items: const [
                    DropdownMenuItem(value: 'dia', child: Text('Hoy')),
                    DropdownMenuItem(
                        value: 'semana', child: Text('Esta semana')),
                    DropdownMenuItem(value: 'mes', child: Text('Este mes')),
                    DropdownMenuItem(value: 'anio', child: Text('Este año')),
                  ],
                  onChanged: (v) => _cambiarPeriodo(v ?? 'mes'),
                ),
              ],
            ),
            Text('📅 Actualizado al $fecha',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),

            // === KPI CARDS ===
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                mainAxisExtent: 120,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: kpi.length,
              itemBuilder: (_, i) => _KpiCard(
                title: kpi[i]['title'] as String,
                value: (kpi[i]['value'] as num).toDouble(),
                icon: kpi[i]['icon'] as IconData,
                color: kpi[i]['color'] as Color,
              ),
            ),

            const SizedBox(height: 25),
            const Text('📈 Actividad general',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),

            // === GRÁFICO DE BARRAS ===
            SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: kpi,
                  xValueMapper: (d, _) => d['title'] as String,
                  yValueMapper: (d, _) => (d['value'] as num).toDouble(),
                  pointColorMapper: (d, _) => d['color'] as Color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),

            const SizedBox(height: 25),
            const Text('📊 Distribución de estados',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),

            // === GRÁFICO CIRCULAR ===
            SfCircularChart(
              legend: Legend(
                  isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries>[
                PieSeries<Map<String, dynamic>, String>(
                  dataSource: kpi.take(4).toList(),
                  xValueMapper: (d, _) => d['title'] as String,
                  yValueMapper: (d, _) => (d['value'] as num).toDouble(),
                  pointColorMapper: (d, _) => d['color'] as Color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),

            const SizedBox(height: 25),
            _buildSugerencias(d),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'SmartRent+ © ${DateTime.now().year} · Panel de métricas avanzado',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // 🔹 Sugerencias inteligentes
  // ===============================================================
  Widget _buildSugerencias(Map<String, dynamic> d) {
    List<String> sugerencias = [];

    if ((d['paused'] ?? 0) > 0) {
      sugerencias
          .add('🟠 Tienes propiedades pausadas, considera reactivarlas.');
    }
    if ((d['drafts'] ?? 0) > 2) {
      sugerencias.add('📄 Tienes varios borradores pendientes de publicar.');
    }
    if ((d['reservations'] ?? 0) > (d['published'] ?? 1) * 2) {
      sugerencias.add('📈 Tus reservas están creciendo rápidamente.');
    }
    if ((d['views'] ?? 0) == 0) {
      sugerencias.add(
          '👁️‍🗨️ No tienes visitas recientes, revisa tus publicaciones.');
    }
    if (sugerencias.isEmpty) {
      sugerencias.add('✅ Todo en orden. Tus métricas son estables.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('💡 Sugerencias automáticas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        ...sugerencias.map(
          (s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(s, style: const TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// 🎯 Widget KPI Card animado
// ===============================================================
class _KpiCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
