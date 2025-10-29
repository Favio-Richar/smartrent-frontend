// lib/features/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/auth_service.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _rol =
      'Usuario'; // valor que el backend entiende: "Usuario" | "Empresa"
  bool _loading = false;

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ok = await AuthService.register(
      _nombre.text.trim(),
      _email.text.trim(),
      _password.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Cuenta creada exitosamente' : 'No se pudo registrar',
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de usuario'),
        backgroundColor: const Color(0xFF0066FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person_add, color: Color(0xFF0066FF), size: 80),
              const SizedBox(height: 20),

              // Nombre
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Ingrese su nombre completo'
                    : null,
              ),
              const SizedBox(height: 16),

              // Correo
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Ingrese su correo' : null,
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 20),

              // Tipo de cuenta (si después lo necesitas)
              const Text(
                'Tipo de cuenta:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _rol,
                items: const [
                  DropdownMenuItem(
                    value: 'Usuario',
                    child: Text('Usuario / Buscador'),
                  ),
                  DropdownMenuItem(
                    value: 'Empresa',
                    child: Text('Anunciante / Empresa'),
                  ),
                ],
                onChanged: (v) => setState(() => _rol = v ?? 'Usuario'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),

              const SizedBox(height: 24),

              // Botón registrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _loading ? null : _registrarUsuario,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrar cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
