import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/reserva_service.dart';

class ReservasPage extends StatefulWidget {
  final bool empresa; // true = recibidas, false = mis reservas (usuario)
  const ReservasPage({super.key, required this.empresa});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final _svc = ReservaService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = widget.empresa
        ? await _svc.getReceived()
        : await _svc.getMine();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _updateEstado(String id, String estado) async {
    await _svc.updateStatus(id, estado);
    _load();
  }

  Future<void> _cancel(String id) async {
    await _svc.cancel(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.empresa ? 'Reservas recibidas' : 'Mis reservas'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = _items[i];
                  final p = r['propiedad'];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        p?['image_url'] ?? '',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(p?['title'] ?? 'Propiedad'),
                    subtitle: Text(
                      'Del ${r['fecha_inicio']} al ${r['fecha_fin']} • ${r['estado']}',
                    ),
                    trailing: widget.empresa
                        ? DropdownButton<String>(
                            value: r['estado'],
                            onChanged: (v) =>
                                _updateEstado(r['id'].toString(), v!),
                            items: const [
                              DropdownMenuItem(
                                value: 'Pendiente',
                                child: Text('Pendiente'),
                              ),
                              DropdownMenuItem(
                                value: 'Aprobada',
                                child: Text('Aprobada'),
                              ),
                              DropdownMenuItem(
                                value: 'Cancelada',
                                child: Text('Cancelada'),
                              ),
                            ],
                          )
                        : TextButton(
                            onPressed: r['estado'] == 'Pendiente'
                                ? () => _cancel(r['id'].toString())
                                : null,
                            child: const Text('Cancelar'),
                          ),
                  );
                },
              ),
            ),
    );
  }
}
