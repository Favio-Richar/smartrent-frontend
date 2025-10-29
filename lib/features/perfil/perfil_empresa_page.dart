import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/company_service.dart';
import 'package:smartrent_plus/features/arriendos/widgets/card_propiedad.dart';

class PerfilEmpresaPage extends StatefulWidget {
  final String companyId;
  const PerfilEmpresaPage({super.key, required this.companyId});

  @override
  State<PerfilEmpresaPage> createState() => _PerfilEmpresaPageState();
}

class _PerfilEmpresaPageState extends State<PerfilEmpresaPage> {
  final _svc = CompanyService();
  Map<String, dynamic>? _company;
  List<Map<String, dynamic>> _props = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await _svc.getPublicProfile(widget.companyId);
    if (!mounted) return;
    final list = (info?['propiedades'] as List? ?? [])
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    setState(() {
      _company = Map<String, dynamic>.from(info ?? {});
      _props = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final c = _company ?? {};

    final logo = (c['logo'] ?? '').toString();
    final nombre = (c['nombre'] ?? '').toString();
    final rating = (c['rating'] is num) ? (c['rating'] as num).round() : null;
    final descripcion = (c['descripcion'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: Text(nombre.isEmpty ? 'Empresa' : nombre)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 40,
              backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
              child: logo.isEmpty ? const Icon(Icons.business, size: 32) : null,
            ),
            const SizedBox(height: 8),
            Text(
              nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (rating != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 18,
                    color: i < rating ? Colors.amber : Colors.grey,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(descripcion, textAlign: TextAlign.center),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Publicaciones',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('Total: ${_props.length}'),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .72,
              ),
              itemCount: _props.length,
              itemBuilder: (_, i) => CardPropiedadMap(data: _props[i]),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
