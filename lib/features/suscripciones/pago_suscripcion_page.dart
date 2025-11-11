// lib/features/suscripciones/pago_suscripcion_page.dart
// ===============================================================
// 💳 PAGO SUSCRIPCIÓN – SmartRent+ (Con conexión al backend)
// ---------------------------------------------------------------
// ✅ Llama al backend NestJS (/api/subscriptions/pay)
// ✅ Recibe la URL y token de Transbank
// ✅ Abre el navegador con el link real de pago
// ✅ Corrige manejo del código 201
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Para abrir navegador

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

  // ===============================================================
  // 🔹 Inicia el pago real con el backend NestJS
  // ===============================================================
  Future<void> _iniciarPagoWebPay() async {
    setState(() => _procesando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró usuario logueado')),
        );
        return;
      }

      final apiUrl = 'http://10.0.2.2:3000/api/subscriptions/pay';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'plan': widget.plan,
        }),
      );

      // ✅ Aceptamos tanto 200 como 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // ✅ Obtenemos token y url de Transbank
        final String? url = data['url'];
        final String? token = data['token'];

        if (url != null && token != null) {
          final String webpayUrl = '$url?token_ws=$token';

          debugPrint('🌐 Redirigiendo a WebPay: $webpayUrl');

          // 🔹 Abre el navegador externo para el pago
          if (!await launchUrl(
            Uri.parse(webpayUrl),
            mode: LaunchMode.externalApplication,
          )) {
            throw Exception('No se pudo abrir el enlace de pago');
          }
        } else {
          throw Exception('Respuesta inválida del backend');
        }
      } else {
        debugPrint('❌ Error ${response.statusCode}: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar pago: ${response.statusCode}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (err) {
      debugPrint('⚠️ Error en pago: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al conectar con el servidor: $err'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _procesando = false);
    }
  }

  // ===============================================================
  // 🔹 Construcción UI
  // ===============================================================
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Text(
              widget.precio,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.2),
            const SizedBox(height: 20),
            Text(
              'Resumen del servicio',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeature('✔ Publicaciones semanales aumentadas'),
            _buildFeature('✔ Calidad de video mejorada'),
            _buildFeature('✔ Sin anuncios'),
            if (widget.plan != 'BÁSICO') _buildFeature('✔ Anuncios destacados'),
            if (widget.plan == 'ADVANCE')
              _buildFeature('✔ Estadísticas avanzadas y soporte 12h'),
            const Spacer(),
            ElevatedButton(
              onPressed: _procesando
                  ? null
                  : () async {
                      if (widget.plan == 'BÁSICO') {
                        _showDialogGratis(context);
                      } else {
                        await _iniciarPagoWebPay();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
            const SizedBox(height: 20),
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
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialogGratis(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Activar Plan Básico',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Tu plan gratuito se ha activado correctamente.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
