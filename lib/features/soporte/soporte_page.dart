import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ← para leer el provider en la reseña
import 'package:smartrent_plus/routes/app_routes.dart';
import 'package:smartrent_plus/data/providers/soporte_provider.dart'; // ← para enviar reseña

class SoportePage extends StatefulWidget {
  const SoportePage({super.key});

  @override
  State<SoportePage> createState() => _SoportePageState();
}

class _SoportePageState extends State<SoportePage> {
  final _searchCtrl = TextEditingController();

  final List<String> _examples = const [
    'No puedo iniciar sesión',
    'Problemas con el pago',
    '¿Cómo cambiar mi contraseña?',
    'Error al subir fotos',
    'No me llega el código',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _goToFaq([String? query]) {
    Navigator.pushNamed(
      context,
      AppRoutes.soporteFaq,
      arguments:
          (query != null && query.trim().isNotEmpty) ? query.trim() : null,
    );
  }

  void _goToCommunity() {
    Navigator.pushNamed(
        context, '/soporte/comunidad'); // si ya tienes esta ruta
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Centro de Soporte'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // Card: Ayuda comunitaria
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.forum_rounded,
                            color: Colors.green),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ayuda comunitaria',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                            SizedBox(height: 4),
                            Text(
                                'Ve soluciones de otros usuarios, comparte tips o haz preguntas a la comunidad.'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _goToCommunity,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Ver comunidad'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Buscador
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar en soporte… (ej. “No me llega el código”)',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onSubmitted: (v) => _goToFaq(v),
              ),
              const SizedBox(height: 10),

              // Chips de acceso rápido
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _examples
                    .map(
                      (e) => ActionChip(
                        label: Text(e),
                        avatar: const Icon(Icons.tips_and_updates_rounded,
                            size: 18),
                        onPressed: () => _goToFaq(e),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: theme.textTheme.bodySmall?.color, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Nuestro equipo suele responder dentro de 24–48 horas hábiles.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),

              // Reseña
              const SizedBox(height: 16),
              const _ResenaCard(), // ← ahora interactiva y conectada al provider
            ],
          ),

          // ---------- DOCK INFERIOR ----------
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _BottomDock(
              onHome: () => Navigator.pop(context),
              onReport: () =>
                  Navigator.pushNamed(context, AppRoutes.soporteReporte),
              // navega a la pantalla con 3 opciones
              onContact: () =>
                  Navigator.pushNamed(context, AppRoutes.soporteContacto),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= Dock inferior =======================
class _BottomDock extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onReport;
  final VoidCallback onContact;

  const _BottomDock({
    required this.onHome,
    required this.onReport,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).cardColor;
    final color = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DockItem(
              icon: Icons.home_rounded,
              label: 'Inicio',
              color: color,
              onTap: onHome),
          _DockItem(
              icon: Icons.report_problem_rounded,
              label: 'Reportar',
              color: color,
              onTap: onReport),
          _DockItem(
              icon: Icons.headset_mic_rounded,
              label: 'Soporte',
              color: color,
              onTap: onContact),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 6),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// -------- Card de reseña interactiva (con estrellas) --------
class _ResenaCard extends StatefulWidget {
  const _ResenaCard({super.key});

  @override
  State<_ResenaCard> createState() => _ResenaCardState();
}

class _ResenaCardState extends State<_ResenaCard> {
  int _rating = 0;
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona una calificación con estrellas.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await context.read<SoporteProvider>().enviarResena(
            rating: _rating,
            comentario: _controller.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gracias por tu reseña!')),
      );

      setState(() {
        _rating = 0;
        _controller.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar reseña: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Cómo fue tu experiencia?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text('Déjanos una reseña para mejorar el Centro de Soporte.',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),

            // ⭐⭐⭐⭐⭐
            Row(
              children: List.generate(5, (i) {
                final idx = i + 1;
                final filled = idx <= _rating;
                return IconButton(
                  iconSize: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  onPressed: () => setState(() => _rating = idx),
                  icon: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: filled ? Colors.amber : Colors.grey.shade400,
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escribe tu comentario…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _enviar,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: Text(_sending ? 'Enviando…' : 'Enviar reseña'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
