// ===============================================================
// 🔹 LOGIN PAGE - SmartRent+ (versión final optimizada)
// ===============================================================
// Gestiona login y guarda el tipo de usuario (Admin, Empresa o Usuario).
// Compatible con Dart 3.9 y sin warnings de contexto.
// ===============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartrent_plus/routes/app_routes.dart';
import 'package:smartrent_plus/data/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // ============================================================
  // 🔹 Método para iniciar sesión
  // ============================================================
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor ingresa tu correo y contraseña."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await AuthService.login(email, password);

      if (!mounted) return;

      if (success) {
        final userId = prefs.getInt('userId');
        final tipoCuenta = prefs.getString('userRole');
        final token = prefs.getString('token');

        debugPrint('✅ Sesión iniciada correctamente');
        debugPrint('👤 ID: $userId | Rol: $tipoCuenta | Token: $token');

        await prefs.setBool('isLoggedIn', true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bienvenido(a) $tipoCuenta"),
            backgroundColor: Colors.green,
          ),
        );

        // 🔸 Redirigir al menú principal
        Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Credenciales inválidas o usuario no registrado."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al iniciar sesión: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // 🔹 UI del formulario
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0066FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.home_work_rounded,
              color: Color(0xFF0066FF),
              size: 90,
            ),
            const SizedBox(height: 20),
            Text(
              "SmartRent+",
              style: GoogleFonts.poppins(
                color: const Color(0xFF0066FF),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // 📨 Campo de correo
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // 🔒 Campo de contraseña
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Botón de inicio de sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Entrar', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Olvidé mi contraseña
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.forgotPassword);
              },
              child: const Text("¿Olvidaste tu contraseña?"),
            ),
            const SizedBox(height: 10),

            // 🔹 Enlace a registro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿No tienes cuenta?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: const Text(
                    "Regístrate aquí",
                    style: TextStyle(color: Color(0xFF0066FF)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
