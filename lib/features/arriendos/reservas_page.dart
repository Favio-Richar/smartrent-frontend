// lib/features/arriendos/reservas_page.dart
// ===============================================================
// 🔹 RESERVAS PAGE
// - Modo empresa: ve reservas RECIBIDAS sobre sus publicaciones
// - Modo usuario: ve las reservas que ÉL hizo
// - Pull-to-refresh
// - Manejo de error / estado vacío
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/reserva_service.dart';

class ReservasPage extends StatefulWidget {
  /// true  -> panel de empresa (reservas recibidas)
  /// false -> panel de usuario (mis reservas)
  final bool empresa;
  const ReservasPage({super.key, required this.empresa});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final _svc = ReservaService();

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // -------------------------------------------------------------
  // Carga según el modo
  // -------------------------------------------------------------
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = widget.empresa
          ? await _svc.getReceived()
          : await _svc.getMine();

      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateEstado(String id, String estado) async {
    final ok = await _svc.updateStatus(id, estado);
    if (ok) {
      _load();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el estado')),
      );
    }
  }

  Future<void> _cancel(String id) async {
    final ok = await _svc.cancel(id);
    if (ok) {
      _load();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cancelar la reserva')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.empresa ? 'Reservas recibidas' : 'Mis reservas';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _error != null
                  ? _ErrorView(message: _error!, onRetry: _load)
                  : _items.isEmpty
                  ? _EmptyView(empresa: widget.empresa)
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = _items[i];

                        // la propiedad puede venir como 'propiedad', 'property' o 'arriendo'
                        final p =
                            r['propiedad'] ??
                            r['property'] ??
                            r['arriendo'] ??
                            {};

                        final image =
                            (p['image_url'] ??
                                    p['imageUrl'] ??
                                    p['imagen'] ??
                                    '')
                                .toString();
                        final titulo =
                            (p['title'] ?? p['titulo'] ?? 'Propiedad')
                                .toString();

                        final fechaIni =
                            (r['fecha_inicio'] ??
                                    r['start'] ??
                                    r['desde'] ??
                                    '')
                                .toString();
                        final fechaFin =
                            (r['fecha_fin'] ?? r['end'] ?? r['hasta'] ?? '')
                                .toString();
                        final estado = (r['estado'] ?? 'Pendiente').toString();

                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: image.isEmpty
                                ? Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  )
                                : Image.network(
                                    image,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image_outlined,
                                      ),
                                    ),
                                  ),
                          ),
                          title: Text(titulo),
                          subtitle: Text(
                            'Del $fechaIni al $fechaFin • $estado',
                          ),
                          trailing: widget.empresa
                              // ======== MODO EMPRESA: cambia estado ========
                              ? DropdownButton<String>(
                                  value: estado,
                                  onChanged: (v) {
                                    if (v != null) {
                                      _updateEstado(r['id'].toString(), v);
                                    }
                                  },
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
                              // ======== MODO USUARIO: puede cancelar ========
                              : TextButton(
                                  onPressed: estado == 'Pendiente'
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

// ===============================================================
// Vistas auxiliares
// ===============================================================
class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 60),
        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(message, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool empresa;
  const _EmptyView({required this.empresa});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.event_busy, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Center(
          child: Text(
            empresa
                ? 'Aún no tienes reservas recibidas.'
                : 'Aún no has hecho reservas.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
