import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/estadistica_service.dart';

class EstadisticasArriendoPage extends StatefulWidget {
  const EstadisticasArriendoPage({super.key});

  @override
  State<EstadisticasArriendoPage> createState() =>
      _EstadisticasArriendoPageState();
}

class _EstadisticasArriendoPageState extends State<EstadisticasArriendoPage> {
  final _svc = EstadisticaService();
  List<dynamic> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await _svc
        .resumenEmpresa(); // [{titulo, visitas, reservas, contactos}]
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  Future<void> _exportExcel() async {
    await _svc.exportExcel();
  }

  Future<void> _exportPdf() async {
    await _svc.exportPdf();
  }

  int _max(String key) {
    int m = 1;
    for (final e in _data) {
      final v = (e[key] ?? 0) as int;
      if (v > m) m = v;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            onPressed: _exportExcel,
            icon: const Icon(Icons.table_view),
          ),
          IconButton(
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final e = _data[i] as Map<String, dynamic>;
                final t = (e['titulo'] ?? '').toString();
                final visitas = (e['visitas'] ?? 0) as int;
                final reservas = (e['reservas'] ?? 0) as int;
                final contactos = (e['contactos'] ?? 0) as int;

                final maxV = _max('visitas');
                final maxR = _max('reservas');
                final maxC = _max('contactos');

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        _Bar(label: 'Visitas', value: visitas, max: maxV),
                        _Bar(label: 'Reservas', value: reservas, max: maxR),
                        _Bar(label: 'Contactos', value: contactos, max: maxC),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  const _Bar({required this.label, required this.value, required this.max});
  @override
  Widget build(BuildContext context) {
    final p = (max == 0) ? 0.0 : (value / max);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(child: LinearProgressIndicator(value: p)),
          const SizedBox(width: 8),
          Text('$value'),
        ],
      ),
    );
  }
}
