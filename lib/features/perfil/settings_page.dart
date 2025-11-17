import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text("Modo oscuro",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            value: darkMode,
            onChanged: (value) {
              setState(() => darkMode = value);
              // Aquí puedes implementar lógica real (Provider, ThemeMode, etc.)
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: Text("Notificaciones",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            value: notifications,
            onChanged: (value) {
              setState(() => notifications = value);
            },
            secondary: const Icon(Icons.notifications_active),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text("Privacidad",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              _showInfo(context, "Configuración de privacidad próximamente");
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text("Cuenta",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              _showInfo(context, "Opciones de cuenta próximamente");
            },
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}