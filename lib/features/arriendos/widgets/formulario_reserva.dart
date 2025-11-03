// lib/features/arriendos/widgets/formulario_reserva_map.dart
// ===============================================================
// 🔹 Formulario de Reserva (versión empresarial)
// - pensado para arriendos de todo tipo: depto, oficina, vehículo,
//   bodega, eventos, etc.
// - recolecta info del solicitante para que la empresa contacte.
// - mantiene tu ReservaService y tu flujo actual.
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/reserva_service.dart';

class FormularioReservaMap extends StatefulWidget {
  final Map<String, dynamic> propiedad;
  const FormularioReservaMap({super.key, required this.propiedad});

  @override
  State<FormularioReservaMap> createState() => _FormularioReservaMapState();
}

class _FormularioReservaMapState extends State<FormularioReservaMap> {
  final _svc = ReservaService();

  // --- controladores ---
  final _formKey = GlobalKey<FormState>();
  DateTimeRange? _range;
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _personasCtrl = TextEditingController(text: '1');
  final _mensajeCtrl = TextEditingController();

  String _tipoUso = 'Residencial';
  String _contacto = 'WhatsApp';
  bool _sending = false;

  // ==========================
  // Seleccionar rango de fechas
  // ==========================
  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecciona las fechas de arriendo',
    );
    if (r != null) {
      setState(() => _range = r);
    }
  }

  // ==========================
  // Enviar
  // ==========================
  Future<void> _send() async {
    // 1) validaciones de UI
    if (_range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona las fechas de reserva')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2) conseguir el ID de la propiedad, con todas las variantes
    final prop = widget.propiedad;
    final propId =
        (prop['id'] ??
                prop['property_id'] ??
                prop['propiedad_id'] ??
                prop['propertyId'] ??
                prop['propiedad']?['id'] ??
                prop['property']?['id'])
            ?.toString();

    if (propId == null || propId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el ID de la propiedad a reservar'),
        ),
      );
      return;
    }

    // 3) armar un "mensaje legible" para que el dueño lo vea
    final mensajeLegible = StringBuffer()
      ..writeln('Solicitud de arriendo')
      ..writeln('--------------------')
      ..writeln('Propiedad: ${prop['titulo'] ?? prop['title'] ?? '#$propId'}')
      ..writeln(
        'Fechas: ${_range!.start.toIso8601String()} → ${_range!.end.toIso8601String()}',
      )
      ..writeln('Personas: ${_personasCtrl.text}')
      ..writeln('Tipo de uso: $_tipoUso')
      ..writeln('Contacto preferido: $_contacto')
      ..writeln('Solicitante: ${_nombreCtrl.text} (${_correoCtrl.text})')
      ..writeln('Teléfono: ${_telefonoCtrl.text}')
      ..writeln('Mensaje: ${_mensajeCtrl.text}');

    // 4) además mandamos un "meta" con toda la data (para crecer después)
    final meta = {
      "solicitante": {
        "nombre": _nombreCtrl.text.trim(),
        "correo": _correoCtrl.text.trim(),
        "telefono": _telefonoCtrl.text.trim(),
      },
      "tipo_uso": _tipoUso,
      "contacto_preferido": _contacto,
      "personas": int.tryParse(_personasCtrl.text) ?? 1,
      "fechas": {
        "inicio": _range!.start.toIso8601String(),
        "fin": _range!.end.toIso8601String(),
      },
      "observaciones": _mensajeCtrl.text.trim(),
      // si después agregas auto, cancha, herramientas, puedes meter más aquí
    };

    setState(() => _sending = true);

    try {
      final ok = await _svc.create({
        "property_id": propId,
        "fecha_inicio": _range!.start.toIso8601String(),
        "fecha_fin": _range!.end.toIso8601String(),
        "personas": int.tryParse(_personasCtrl.text) ?? 1,
        "mensaje": mensajeLegible.toString(),
        // 👇 esto tu backend actual lo va a ignorar si no tiene columna,
        // pero ya te queda en el body para cuando amplíes la tabla
        "meta": jsonEncode(meta),
      });

      if (!mounted) return;
      setState(() => _sending = false);

      if (ok) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Solicitud enviada ✅')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo crear la reserva')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tituloProp =
        (widget.propiedad['titulo'] ?? widget.propiedad['title'] ?? '')
            .toString();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== encabezado =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tituloProp.isEmpty
                            ? 'Reservar'
                            : 'Reservar: $tituloProp',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Completa los datos para que el anunciante pueda confirmar tu solicitud.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 14),

                  // ===== fechas + personas =====
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickRange,
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _range == null
                                ? 'Fechas'
                                : '${_range!.start.day}/${_range!.start.month} - ${_range!.end.day}/${_range!.end.month}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: _personasCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Pers.'),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Req.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ===== datos solicitante =====
                  const Text(
                    'Datos del solicitante',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre y apellido',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obligatorio';
                      if (!v.contains('@')) return 'Correo no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono / WhatsApp',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ===== tipo de uso =====
                  const Text(
                    'Tipo de uso',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children:
                        [
                          'Residencial',
                          'Temporada',
                          'Oficina',
                          'Comercial',
                          'Evento',
                          'Bodega',
                          'Otro',
                        ].map((t) {
                          final selected = _tipoUso == t;
                          return ChoiceChip(
                            label: Text(t),
                            selected: selected,
                            onSelected: (_) => setState(() => _tipoUso = t),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // ===== contacto preferido =====
                  const Text(
                    'Contacto preferido',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _contacto,
                    items: const [
                      DropdownMenuItem(
                        value: 'WhatsApp',
                        child: Text('WhatsApp'),
                      ),
                      DropdownMenuItem(
                        value: 'Teléfono',
                        child: Text('Teléfono'),
                      ),
                      DropdownMenuItem(value: 'Email', child: Text('Email')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _contacto = v);
                    },
                  ),
                  const SizedBox(height: 12),

                  // ===== observaciones =====
                  TextFormField(
                    controller: _mensajeCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText:
                          'Mensaje / Detalles (horarios, mascotas, empresa, RUT, etc.)',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== botón =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sending ? null : _send,
                      icon: Icon(
                        _sending ? Icons.hourglass_top : Icons.send_rounded,
                      ),
                      label: Text(
                        _sending ? 'Enviando...' : 'Enviar solicitud',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
