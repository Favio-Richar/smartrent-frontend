// ===============================================================
// 🔹 MAIN - SmartRent+
// ===============================================================
// Punto de entrada principal de la aplicación.
// Configura el tema, rutas globales y pantalla inicial (Splash).
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/routes/app_routes.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Fija la orientación solo en vertical (opcional)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const SmartRentApp());
}

class SmartRentApp extends StatelessWidget {
  const SmartRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 🚫 Oculta el banner DEBUG
      title: 'SmartRent+',
      theme: AppTheme.lightTheme, // 🎨 Usa tu tema global definido
      initialRoute: AppRoutes.splash, // 🏁 Pantalla inicial (Splash)
      routes: AppRoutes.routes, // 🌍 Mapa global de rutas
      // ============================================================
      // 🔹 Soporte para rutas dinámicas o no definidas
      // ============================================================
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("Ruta no encontrada")),
            body: Center(
              child: Text(
                "La ruta '${settings.name}' no existe en la app.",
                style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
