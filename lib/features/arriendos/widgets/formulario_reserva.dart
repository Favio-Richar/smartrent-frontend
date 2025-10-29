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
  DateTimeRange? _range;
  final _mensaje = TextEditingController();
  final _personas = TextEditingController(text: '1');
  bool _sending = false;

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecciona fechas de reserva',
    );
    if (r != null) setState(() => _range = r);
  }

  Future<void> _send() async {
    if (_range == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona fechas')));
      return;
    }
    setState(() => _sending = true);
    try {
      final id = (widget.propiedad['id'] ?? '').toString();
      await _svc.create({
        "property_id": id,
        "fecha_inicio": _range!.start.toIso8601String(),
        "fecha_fin": _range!.end.toIso8601String(),
        "mensaje": _mensaje.text.trim(),
        "personas": int.tryParse(_personas.text) ?? 1,
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              Text(
                'Reservar: ${(widget.propiedad['title'] ?? '').toString()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _range == null
                            ? 'Seleccionar fechas'
                            : '${_range!.start.day}/${_range!.start.month} - ${_range!.end.day}/${_range!.end.month}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _personas,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Personas'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mensaje,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mensaje'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : _send,
                  icon: Icon(_sending ? Icons.hourglass_top : Icons.send),
                  label: Text(_sending ? 'Enviando...' : 'Enviar solicitud'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
