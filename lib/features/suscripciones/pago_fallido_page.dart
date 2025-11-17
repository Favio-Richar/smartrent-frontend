// ===============================================================
// ❌ PAGO FALLIDO – SmartRent+ (VERSIÓN FINAL)
// ---------------------------------------------------------------
// ✓ Diseño igual al exitoso, pero en rojo
// ✓ Tarjeta elegante con sombra
// ✓ Ícono de error en círculo
// ✓ Mensaje claro y profesional
// ===============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

class PagoFallidoPage extends StatelessWidget {
  const PagoFallidoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: Text(
          'Pago Fallido',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono de error grande
                Container(
                  width: 95,
                  height: 95,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 58,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 22),

                // Título
                Text(
                  'El pago no pudo\ncompletarse',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                // Texto explicativo
                Text(
                  'Por favor, inténtalo nuevamente más tarde\n'
                  'o usa otro método de pago.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 32),

                // Botón volver al inicio
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.mainMenu,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: Text(
                      'Volver al inicio',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
