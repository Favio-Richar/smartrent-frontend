import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartrent_plus/features/suscripciones/pago_suscripcion_page.dart';

class SuscripcionesPage extends StatefulWidget {
  const SuscripcionesPage({super.key});

  @override
  State<SuscripcionesPage> createState() => _SuscripcionesPageState();
}

class _SuscripcionesPageState extends State<SuscripcionesPage> {
  // Simulación del plan actual del usuario (por ahora está en "BÁSICO")
  final String _planActual = 'BÁSICO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartRent+ Suscripciones'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Planes de Suscripción',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Elige el plan ideal para ti',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 25),

            // 🟩 Básico
            PlanCard(
              title: 'BÁSICO',
              price: 'Gratis',
              color: const Color(0xFF009688),
              benefits: const [
                '2 publicaciones por semana',
                'Videos hasta 720p',
                'Ver "Mis postulaciones" 3 veces',
                'Incluye anuncios',
              ],
              unavailable: const [
                'Anuncios destacados',
                'Soporte prioritario',
              ],
              buttonText: 'Usar Gratis',
              isCurrentPlan: _planActual == 'BÁSICO',
              onPressed: () {
                if (_planActual != 'BÁSICO') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PagoSuscripcionPage(
                        plan: 'BÁSICO',
                        precio: 'Gratis',
                        color: const Color(0xFF009688),
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // 🟦 Premium
            PlanCard(
              title: 'PREMIUM',
              price: '\$9.990 / mes',
              color: const Color(0xFF1565C0),
              benefits: const [
                '10 publicaciones por semana',
                'Videos hasta 1080p',
                'Anuncios destacados (x2)',
                'Ver "Mis postulaciones" ilimitado',
                'Sin anuncios',
              ],
              unavailable: const [
                'Funciones avanzadas',
              ],
              buttonText: 'Mejorar a Premium',
              isCurrentPlan: _planActual == 'PREMIUM',
              onPressed: () {
                if (_planActual != 'PREMIUM') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PagoSuscripcionPage(
                        plan: 'PREMIUM',
                        precio: '\$9.990 / mes',
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // 🟧 Advance
            PlanCard(
              title: 'ADVANCE',
              price: '\$14.990 / mes',
              color: const Color(0xFFE65100),
              benefits: const [
                'Publicaciones ilimitadas',
                'Videos hasta 4K',
                'Anuncios destacados ilimitados',
                'Estadísticas avanzadas',
                'Soporte prioritario 12h',
                'Sin anuncios',
              ],
              unavailable: const [],
              buttonText: 'Obtener Advance',
              isCurrentPlan: _planActual == 'ADVANCE',
              onPressed: () {
                if (_planActual != 'ADVANCE') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PagoSuscripcionPage(
                        plan: 'ADVANCE',
                        precio: '\$14.990 / mes',
                        color: Color(0xFFE65100),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 🔹 COMPONENTE DE CADA PLAN
// ==========================================================
class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final Color color;
  final List<String> benefits;
  final List<String> unavailable;
  final String buttonText;
  final bool isCurrentPlan;
  final VoidCallback onPressed;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.color,
    required this.benefits,
    required this.unavailable,
    required this.buttonText,
    required this.isCurrentPlan,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // BENEFICIOS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...benefits.map(
                  (b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(b, style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
                ...unavailable.map(
                  (b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            b,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // BOTÓN / ETIQUETA
                isCurrentPlan
                    ? Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Plan actual',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
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
