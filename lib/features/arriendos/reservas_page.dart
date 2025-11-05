// lib/features/arriendos/reservas_page.dart
// ===============================================================
// RESERVAS PAGE (Empresa / Usuario) – versión sin alerts/lints
// ===============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartrent_plus/data/services/reserva_service.dart';

class ReservasPage extends StatefulWidget {
  final bool
  empresa; // true: recibidas (empresa) | false: mis reservas (usuario)
  const ReservasPage({super.key, required this.empresa});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final _svc = ReservaService();
  final _fmt = DateFormat('dd MMM yyyy', 'es_CL');

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;
  String _estadoFiltro = 'Todos';

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------- helpers ----------
  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  String _fmtRango(dynamic inicio, dynamic fin) {
    final di = _parseDate(inicio);
    final df = _parseDate(fin);
    if (di == null || df == null) return '–';
    return '${_fmt.format(di)} → ${_fmt.format(df)}';
  }

  void _aplicarFiltro() {
    if (_estadoFiltro == 'Todos') {
      _filtered = List.of(_items);
    } else {
      _filtered = _items
          .where(
            (r) => (r['estado'] ?? 'Pendiente').toString() == _estadoFiltro,
          )
          .toList();
    }
    setState(() {});
  }

  // ---------- data ----------
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = widget.empresa
          ? await _svc.getReceived()
          : await _svc.getMine();
      _items = data;
      _aplicarFiltro();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _updateEstado(String id, String estado) async {
    final ok = await _svc.updateStatus(id, estado);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Estado actualizado a "$estado"')));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el estado')),
      );
    }
  }

  Future<void> _cancel(String id) async {
    final ok = await _svc.cancel(id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reserva cancelada')));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cancelar la reserva')),
      );
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final title = widget.empresa ? 'Reservas recibidas' : 'Mis reservas';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${_filtered.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _error != null
                  ? _ErrorView(message: _error!, onRetry: _load)
                  : (_items.isEmpty
                        ? _EmptyView(empresa: widget.empresa)
                        : Column(
                            children: [
                              _FiltroEstados(
                                valor: _estadoFiltro,
                                onChanged: (v) {
                                  _estadoFiltro = v;
                                  _aplicarFiltro();
                                },
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  itemCount: _filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (ctx, i) {
                                    final r = _filtered[i];

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
                                        (p['title'] ??
                                                p['titulo'] ??
                                                'Propiedad')
                                            .toString();

                                    final rango = _fmtRango(
                                      r['fecha_inicio'] ??
                                          r['start'] ??
                                          r['desde'],
                                      r['fecha_fin'] ?? r['end'] ?? r['hasta'],
                                    );

                                    final estado = (r['estado'] ?? 'Pendiente')
                                        .toString();

                                    final personas =
                                        (r['people'] ??
                                                r['personas'] ??
                                                (r['meta']
                                                        is Map<String, dynamic>
                                                    ? (r['meta']['personas'] ??
                                                          1)
                                                    : 1))
                                            .toString();

                                    return _ReservaCard(
                                      image: image,
                                      titulo: titulo,
                                      rango: rango,
                                      estado: estado,
                                      personas: personas,
                                      onTapVer: () => _verDetalle(context, r),
                                      trailing: widget.empresa
                                          ? _MenuEmpresa(
                                              estadoActual: estado,
                                              onAprobar: () {
                                                _updateEstado(
                                                  r['id'].toString(),
                                                  'Aprobada',
                                                );
                                              },
                                              onCancelar: () {
                                                _updateEstado(
                                                  r['id'].toString(),
                                                  'Cancelada',
                                                );
                                              },
                                            )
                                          : _MenuUsuario(
                                              puedeCancelar:
                                                  estado == 'Pendiente',
                                              onCancelar: () {
                                                _cancel(r['id'].toString());
                                              },
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )),
            ),
    );
  }

  void _verDetalle(BuildContext context, Map<String, dynamic> r) {
    final meta = r['meta'] is Map<String, dynamic>
        ? (r['meta'] as Map<String, dynamic>)
        : {};

    final solicitante = meta['solicitante'] is Map<String, dynamic>
        ? (meta['solicitante'] as Map<String, dynamic>)
        : {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: max(MediaQuery.of(context).viewInsets.bottom, 16),
            top: 8,
          ),
          child: _DetalleReservaSheet(
            titulo:
                (r['propiedad']?['titulo'] ??
                        r['property']?['titulo'] ??
                        r['arriendo']?['titulo'] ??
                        'Propiedad')
                    .toString(),
            rango: _fmtRango(
              r['fecha_inicio'] ?? r['start'] ?? r['desde'],
              r['fecha_fin'] ?? r['end'] ?? r['hasta'],
            ),
            estado: (r['estado'] ?? 'Pendiente').toString(),
            personas: (r['people'] ?? r['personas'] ?? 1).toString(),
            contacto: (meta['contacto_preferido'] ?? '-').toString(),
            nombre: (solicitante['nombre'] ?? '-').toString(),
            correo: (solicitante['correo'] ?? '-').toString(),
            telefono: (solicitante['telefono'] ?? '-').toString(),
            mensaje: (r['mensaje'] ?? meta['observaciones'] ?? '-').toString(),
          ),
        );
      },
    );
  }
}

// ===============================================================
// Widgets auxiliares (presentación)
// ===============================================================

class _FiltroEstados extends StatelessWidget {
  final String valor;
  final ValueChanged<String> onChanged;
  const _FiltroEstados({required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const opciones = ['Todos', 'Pendiente', 'Aprobada', 'Cancelada'];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final v = opciones[i];
          final selected = v == valor;
          return ChoiceChip(
            label: Text(v),
            selected: selected,
            onSelected: (_) {
              onChanged(v);
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: opciones.length,
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  final String image;
  final String titulo;
  final String rango;
  final String estado;
  final String personas;
  final VoidCallback onTapVer;
  final Widget trailing;

  const _ReservaCard({
    required this.image,
    required this.titulo,
    required this.rango,
    required this.estado,
    required this.personas,
    required this.onTapVer,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTapVer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(image: image),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _EstadoMini(estado: estado),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.event, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rango,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          '$personas persona(s)',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: onTapVer,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Ver'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String image;
  const _Thumb({required this.image});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image.isEmpty
          ? Container(
              width: 70,
              height: 70,
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported_outlined),
            )
          : Image.network(
              image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
    );
  }
}

class _EstadoMini extends StatelessWidget {
  final String estado;
  const _EstadoMini({required this.estado});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color c;
    switch (estado.toLowerCase()) {
      case 'aprobada':
        c = cs.primary;
        break;
      case 'cancelada':
        c = cs.error;
        break;
      default:
        c = cs.secondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _MenuEmpresa extends StatelessWidget {
  final String estadoActual;
  final VoidCallback onAprobar;
  final VoidCallback onCancelar;
  const _MenuEmpresa({
    required this.estadoActual,
    required this.onAprobar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Acciones',
      onSelected: (v) {
        switch (v) {
          case 'Aprobar':
            onAprobar();
            break;
          case 'Cancelar':
            onCancelar();
            break;
          default:
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'Aprobar', child: Text('Aprobar')),
        PopupMenuItem(value: 'Cancelar', child: Text('Cancelar')),
      ],
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.more_vert),
      ),
    );
  }
}

class _MenuUsuario extends StatelessWidget {
  final bool puedeCancelar;
  final VoidCallback onCancelar;
  const _MenuUsuario({required this.puedeCancelar, required this.onCancelar});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: puedeCancelar ? onCancelar : null,
      child: const Text('Cancelar'),
    );
  }
}

class _DetalleReservaSheet extends StatelessWidget {
  final String titulo;
  final String rango;
  final String estado;
  final String personas;
  final String contacto;
  final String nombre;
  final String correo;
  final String telefono;
  final String mensaje;

  const _DetalleReservaSheet({
    required this.titulo,
    required this.rango,
    required this.estado,
    required this.personas,
    required this.contacto,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.event, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(rango)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.verified, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text('Estado: $estado'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.people_outline, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text('Personas: $personas'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 6),
          Text(
            'Solicitante',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.person_outline, label: nombre),
          _InfoRow(icon: Icons.mail_outline, label: correo),
          _InfoRow(icon: Icons.phone_outlined, label: telefono),
          _InfoRow(
            icon: Icons.chat_bubble_outline,
            label: 'Contacto: $contacto',
          ),
          const SizedBox(height: 12),
          Text(
            'Mensaje',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(mensaje),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

// ===============================================================
// Estados vacíos / error
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
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 12),
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
      children: const [
        SizedBox(height: 80),
        Icon(Icons.event_busy, size: 48, color: Colors.grey),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No hay reservas para mostrar.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
