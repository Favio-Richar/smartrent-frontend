import 'package:flutter/material.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Espera 2 segundos y luego navega al LoginPage
    Future.delayed(const Duration(seconds: 2), () {
      // ✅ Evita usar context si el widget ya fue desmontado
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0066FF), // Azul SmartRent+
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.home, color: Colors.white, size: 90),
            SizedBox(height: 20),
            Text(
              "SmartRent+",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Arriendos, Ventas y Empleos en un solo lugar",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
          ],
        ),
      ),
    );
  }
}
