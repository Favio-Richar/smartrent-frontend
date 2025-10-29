import 'package:flutter/material.dart';

class FiltroArriendosWidget extends StatefulWidget {
  final void Function(Map<String, dynamic>) onApply;
  const FiltroArriendosWidget({super.key, required this.onApply});

  @override
  State<FiltroArriendosWidget> createState() => _FiltroArriendosWidgetState();
}

class _FiltroArriendosWidgetState extends State<FiltroArriendosWidget> {
  final _tipo = ValueNotifier<String?>(null);
  final _categoria = TextEditingController();
  final _ubicacion = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();

  void _apply() {
    final f = <String, dynamic>{
      if (_tipo.value != null && _tipo.value!.isNotEmpty) "tipo": _tipo.value,
      if (_categoria.text.isNotEmpty) "categoria": _categoria.text.trim(),
      if (_ubicacion.text.isNotEmpty) "ubicacion": _ubicacion.text.trim(),
      if (_min.text.isNotEmpty) "min": double.tryParse(_min.text.trim()),
      if (_max.text.isNotEmpty) "max": double.tryParse(_max.text.trim()),
    };
    widget.onApply(f);
  }

  void _clear() {
    _tipo.value = null;
    _categoria.clear();
    _ubicacion.clear();
    _min.clear();
    _max.clear();
    widget.onApply({});
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filtros'),
      childrenPadding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _tipo,
                builder: (_, v, __) => DropdownButtonFormField<String>(
                  value: v,
                  hint: const Text('Tipo'),
                  items: const [
                    DropdownMenuItem(
                      value: 'propiedad',
                      child: Text('Propiedad'),
                    ),
                    DropdownMenuItem(
                      value: 'vehiculo',
                      child: Text('Vehículo'),
                    ),
                    DropdownMenuItem(value: 'terreno', child: Text('Terreno')),
                    DropdownMenuItem(value: 'oficina', child: Text('Oficina')),
                  ],
                  onChanged: (x) => _tipo.value = x,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _ubicacion,
          decoration: const InputDecoration(
            labelText: 'Ubicación (ciudad/comuna/región)',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _min,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio mín.'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _max,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio máx.'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clear,
                child: const Text('Limpiar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _apply,
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
