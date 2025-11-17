import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartrent_plus/features/suscripciones/pago_suscripcion_page.dart';
import 'package:smartrent_plus/features/suscripciones/pago_exitoso_page.dart';
import 'package:smartrent_plus/features/suscripciones/pago_fallido_page.dart';

class SuscripcionesPage extends StatefulWidget {
  const SuscripcionesPage({super.key});

  @override
  State<SuscripcionesPage> createState() => _SuscripcionesPageState();
}

class _SuscripcionesPageState extends State<SuscripcionesPage> {
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

            // ------------------ BÁSICO ------------------
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
              onPressed: () async {
                if (_planActual != 'BÁSICO') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PagoSuscripcionPage(
                        plan: 'BÁSICO',
                        precio: 'Gratis',
                        color: const Color(0xFF009688),
                      ),
                    ),
                  );

                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => result == null
                          ? const PagoFallidoPage()
                          : const PagoExitosoPage(),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // ------------------ PREMIUM ------------------
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
              onPressed: () async {
                if (_planActual != 'PREMIUM') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PagoSuscripcionPage(
                        plan: 'PREMIUM',
                        precio: '\$9.990 / mes',
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  );

                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => result == null
                          ? const PagoFallidoPage()
                          : const PagoExitosoPage(),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // ------------------ ADVANCE ------------------
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
              onPressed: () async {
                if (_planActual != 'ADVANCE') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PagoSuscripcionPage(
                        plan: 'ADVANCE',
                        precio: '\$14.990 / mes',
                        color: Color(0xFFE65100),
                      ),
                    ),
                  );

                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => result == null
                          ? const PagoFallidoPage()
                          : const PagoExitosoPage(),
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
// 🔹 COMPONENTE CARD
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...benefits.map((b) => Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(b)),
                      ],
                    )),
                ...unavailable.map((b) => Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(b,
                              style: const TextStyle(color: Colors.grey)),
                        ),
                      ],
                    )),
                const SizedBox(height: 16),
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
                            fontWeight: FontWeight.w600,
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
