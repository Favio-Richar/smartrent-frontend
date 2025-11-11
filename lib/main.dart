// ===============================================================
// 🔹 MAIN - SmartRent+ (Versión final sin errores)
// ===============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// 🌈 Tema y rutas
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

// 🧩 Providers y servicios
import 'package:smartrent_plus/data/providers/soporte_provider.dart';
import 'package:smartrent_plus/data/services/api_service.dart';
import 'package:smartrent_plus/data/services/soporte_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting('es_CL', null);

  runApp(const SmartRentApp());
}

class SmartRentApp extends StatelessWidget {
  const SmartRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SoporteProvider(SoporteService(ApiService())),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SmartRent+',
        theme: AppTheme.lightTheme,
        locale: const Locale('es', 'CL'),
        supportedLocales: const [
          Locale('es', 'CL'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.red.shade50,
              appBar: AppBar(
                backgroundColor: Colors.red,
                title: const Text("Ruta no encontrada"),
                centerTitle: true,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 60),
                      const SizedBox(height: 20),
                      Text(
                        "❌ La ruta '${settings.name}' no existe en la aplicación SmartRent+.",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.home_outlined),
                        label: const Text("Volver al inicio"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.mainMenu,
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            settings: settings,
          );
        },
      ),
    );
  }
}
