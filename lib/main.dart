// ===============================================================
// 🔹 MAIN - SmartRent+
// ===============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación solo vertical (opcional)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 🌎 Locale por defecto e inicialización de datos para intl (es_CL)
  Intl.defaultLocale = 'es_CL';
  await initializeDateFormatting('es_CL', null);

  runApp(const SmartRentApp());
}

class SmartRentApp extends StatelessWidget {
  const SmartRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartRent+',
      theme: AppTheme.lightTheme,

      // 🌎 Localización
      locale: const Locale('es', 'CL'),
      supportedLocales: const [Locale('es', 'CL'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,

      onUnknownRoute: (settings) => MaterialPageRoute(
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
      ),
    );
  }
}
