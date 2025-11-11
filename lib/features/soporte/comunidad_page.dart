import 'package:flutter/material.dart';
import 'nueva_publicacion_page.dart';

class ComunidadPage extends StatefulWidget {
  const ComunidadPage({super.key});

  @override
  State<ComunidadPage> createState() => _ComunidadPageState();
}

class _ComunidadPageState extends State<ComunidadPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  final List<Map<String, String>> _posts = [
    {
      'title': 'Problemas con el pago en tarjeta débito',
      'author': 'Marta G.',
      'body': 'Me rechazaba el pago, lo solucioné actualizando la app y reintentando.'
    },
    {
      'title': 'No me llega el código SMS',
      'author': 'Luis P.',
      'body': 'Revisé que mi número estaba mal; lo corregí en Perfil y funcionó.'
    },
    {
      'title': 'Error al subir fotos del arriendo',
      'author': 'Camila S.',
      'body': 'Reduciendo el tamaño a menos de 2MB se subieron sin problema.'
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _crearPublicacion() async {
    // Abre el formulario y espera el resultado
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (_) => const NuevaPublicacionPage()),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _posts.insert(0, result); // añade al inicio
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación creada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _posts.where((p) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return p['title']!.toLowerCase().contains(q) ||
          p['body']!.toLowerCase().contains(q) ||
          p['author']!.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda comunitaria')),
      floatingActionButton: _FabCrear(onTap: _crearPublicacion),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar en la comunidad…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (v) => setState(() => _query = v.trim()),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('No hay resultados.'),
              ),
            ),
          for (final p in filtered) ...[
            _PostCard(
              title: p['title']!,
              body: p['body']!,
              author: p['author']!,
              onTap: () {
                // Aquí podrías abrir detalle del post.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Abrir hilo: ${p['title']} (demo).')),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String title;
  final String body;
  final String author;
  final VoidCallback onTap;

  const _PostCard({
    required this.title,
    required this.body,
    required this.author,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('Por $author', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _FabCrear extends StatelessWidget {
  final VoidCallback onTap;
  const _FabCrear({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: FloatingActionButton.extended(
        onPressed: onTap,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Crear publicación'),
      ),
    );
  }
}