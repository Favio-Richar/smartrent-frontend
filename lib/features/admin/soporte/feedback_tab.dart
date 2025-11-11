// ===============================================================
// 🔹 FEEDBACK TAB – Panel Administrativo de Soporte
// ---------------------------------------------------------------
// - Muestra promedio y lista de reseñas
// - Permite responder como administrador
// - Usa SoporteProvider (con SoporteService)
// ===============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smartrent_plus/data/providers/soporte_provider.dart';

class FeedbackTab extends StatefulWidget {
  const FeedbackTab({super.key});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final soporte = context.read<SoporteProvider>();
    await soporte.fetchFeedbackStats();
    await soporte.fetchFeedbacks();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final soporte = context.watch<SoporteProvider>();
    final feedbacks = soporte.feedbacks;
    final stats = soporte.stats;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 🔹 Encabezado de estadísticas
                  Text(
                    'Gestión de Soporte',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          'Promedio de satisfacción',
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                        Text(
                          '${stats?['averageRating'] ?? 0}',
                          style: GoogleFonts.poppins(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${stats?['totalFeedbacks'] ?? 0} reseñas registradas',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                  Text(
                    '🗨️ Últimos comentarios',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (feedbacks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No hay reseñas disponibles',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ...feedbacks.map((fb) => _buildFeedbackCard(context, fb)),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // 🔹 CARD DE RESEÑA INDIVIDUAL
  // ==========================================================
  Widget _buildFeedbackCard(BuildContext context, Map<String, dynamic> fb) {
    final soporte = context.read<SoporteProvider>();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  fb['user']?['nombre'] ?? 'Usuario anónimo',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < (fb['rating'] ?? 0) ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              fb['comment'] ?? '(Sin comentario)',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              fb['createdAt'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 18),

            // 💬 Respuesta del administrador (si existe)
            if (fb['respuesta'] != null &&
                fb['respuesta'].toString().isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.support_agent,
                        size: 18, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        fb['respuesta'],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.reply_outlined, size: 18),
                  label: const Text('Responder'),
                  onPressed: () => _showResponderDialog(context, fb, soporte),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 🔹 DIALOGO PARA RESPONDER UNA RESEÑA
  // ==========================================================
  Future<void> _showResponderDialog(BuildContext context,
      Map<String, dynamic> fb, SoporteProvider soporte) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Responder reseña de ${fb['user']?['nombre'] ?? 'Usuario'}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe una respuesta del administrador...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              final respuesta = controller.text.trim();
              if (respuesta.isNotEmpty) {
                await soporte.responderResena(fb['id'], respuesta);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
