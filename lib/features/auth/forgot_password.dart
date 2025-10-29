import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Correo para solicitar el token
  final _emailCtrl = TextEditingController();

  // Campos para resetear la clave
  final _tokenCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  bool _sending = false; // estado para "Enviar código"
  bool _resetting = false; // estado para "Restablecer"

  String? _devToken; // token retornado por el backend en modo dev (opcional)

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa tu correo')));
      return;
    }

    setState(() => _sending = true);
    final (ok, tokenOrMsg) = await AuthService.forgotPassword(email);
    if (!mounted) return;

    setState(() {
      _sending = false;
      _devToken = ok ? tokenOrMsg : null;
      if (_devToken != null && _devToken!.isNotEmpty) {
        _tokenCtrl.text = _devToken!; // autollenar para pruebas
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Código enviado / generado. Revisa tu correo.' : tokenOrMsg,
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _reset() async {
    final email = _emailCtrl.text.trim();
    final token = _tokenCtrl.text.trim();
    final newPass = _newPassCtrl.text;

    if (email.isEmpty || token.isEmpty || newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa correo, token y nueva contraseña (>= 6).'),
        ),
      );
      return;
    }

    setState(() => _resetting = true);
    final (ok, msg) = await AuthService.resetPassword(
      email: email,
      newPassword: newPass,
      token: token,
    );
    if (!mounted) return;

    setState(() => _resetting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) {
      _newPassCtrl.clear();
      _tokenCtrl.clear();
      setState(() => _devToken = null);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        backgroundColor: const Color(0xFF0066FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1) Correo para enviar código
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar código'),
              ),
            ),

            // 2) (Dev) Mostrar token retornado
            if (_devToken != null && _devToken!.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText('Token (dev): $_devToken'),
            ],

            const Divider(height: 32),

            // 3) Campos para restablecer
            TextField(
              controller: _tokenCtrl,
              decoration: const InputDecoration(
                labelText: 'Token de recuperación',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetting ? null : _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _resetting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Restablecer contraseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
