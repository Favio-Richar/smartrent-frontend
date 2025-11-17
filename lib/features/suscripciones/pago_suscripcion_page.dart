// ======================================================================
// 💳 PAGO DE SUSCRIPCIÓN – SmartRent+ (FLUJO FINAL 2025)
// ======================================================================
// ✓ Llama a SubscriptionProvider
// ✓ Recibe token_ws o null
// ✓ Devuelve resultado a SuscripcionesPage
// ======================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smartrent_plus/data/providers/subscription_provider.dart';

class PagoSuscripcionPage extends StatefulWidget {
  final String plan;
  final String precio;
  final Color color;

  const PagoSuscripcionPage({
    super.key,
    required this.plan,
    required this.precio,
    required this.color,
  });

  @override
  State<PagoSuscripcionPage> createState() => _PagoSuscripcionPageState();
}

class _PagoSuscripcionPageState extends State<PagoSuscripcionPage> {
  bool _procesando = false;

  Future<void> _activarGratis() async {
    Navigator.pop(context, "success");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar ${widget.plan}'),
        backgroundColor: widget.color,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(Icons.workspace_premium_rounded,
                size: 90, color: widget.color),
            const SizedBox(height: 16),
            Text(
              'Plan ${widget.plan}',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.precio, style: GoogleFonts.poppins(fontSize: 18)),
            const SizedBox(height: 25),
            const Divider(thickness: 1.2),
            const SizedBox(height: 25),
            _buildFeature('✔ Publicaciones semanales aumentadas'),
            _buildFeature('✔ Calidad de video mejorada'),
            _buildFeature('✔ Sin anuncios'),
            if (widget.plan != 'BÁSICO') _buildFeature('✔ Anuncios destacados'),
            const Spacer(),
            ElevatedButton(
              onPressed: _procesando
                  ? null
                  : () async {
                      if (widget.plan == 'BÁSICO') {
                        _activarGratis();
                        return;
                      }

                      setState(() => _procesando = true);

                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt("userId");

                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No se encontró usuario logueado"),
                          ),
                        );
                        setState(() => _procesando = false);
                        return;
                      }

                      // 🔥 LLAMAMOS AL PROVIDER
                      final result = await Provider.of<SubscriptionProvider>(
                        context,
                        listen: false,
                      ).iniciarPago(
                        context,
                        widget.plan,
                        userId,
                        widget.color,
                        widget.precio,
                      );

                      setState(() => _procesando = false);

                      // 🔥 DEVOLVEMOS RESULTADO A SUSCRIPCIONES PAGE
                      Navigator.pop(context, result);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: _procesando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.plan == 'BÁSICO'
                          ? 'Activar gratis'
                          : 'Pagar ahora',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
