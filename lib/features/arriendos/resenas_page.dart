import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/resena_service.dart';

class ResenasPage extends StatefulWidget {
  final String companyId;
  const ResenasPage({super.key, required this.companyId});

  @override
  State<ResenasPage> createState() => _ResenasPageState();
}

class _ResenasPageState extends State<ResenasPage> {
  final _svc = ResenaService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  final _comentario = TextEditingController();
  double _rating = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _svc.getByCompany(widget.companyId);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _addReview() async {
    if (_comentario.text.trim().isEmpty) return;
    await _svc.create({
      "company_id": widget.companyId,
      "puntuacion": _rating,
      "comentario": _comentario.text.trim(),
    });
    _comentario.clear();
    _rating = 5;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas')),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final r = _items[i];
                      final stars = ((r['puntuacion'] ?? 0) as num).round();
                      return ListTile(
                        title: Text(
                          r['usuario']?['nombre']?.toString() ?? 'Usuario',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 18,
                                  color: i < stars ? Colors.amber : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(r['comentario']?.toString() ?? ''),
                            if (r['respuesta'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(.06),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Respuesta empresa: ${r['respuesta']}',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Tu puntuación:'),
                    const SizedBox(width: 8),
                    DropdownButton<double>(
                      value: _rating,
                      onChanged: (v) => setState(() => _rating = v!),
                      items: const [5, 4, 3, 2, 1]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.toDouble(),
                              child: Text('$e ★'),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                TextField(
                  controller: _comentario,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu reseña...',
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addReview,
                    child: const Text('Publicar reseña'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
