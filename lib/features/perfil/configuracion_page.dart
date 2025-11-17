import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool darkMode = false;
  bool perfilPrivado = false;
  bool mostrarRedes = true;

  String facebook = "";
  String instagram = "";
  String linkedin = "";
  String web = "";
  String whatsapp = "";

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      facebook = prefs.getString('facebook') ?? "";
      instagram = prefs.getString('instagram') ?? "";
      linkedin = prefs.getString('linkedin') ?? "";
      web = prefs.getString('web') ?? "";
      whatsapp = prefs.getString('whatsapp') ?? "";
    });
  }

  Future<void> _guardarDato(String clave, String valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(clave, valor);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Enlace de $clave guardado ✅")),
    );
  }

  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo abrir el enlace 😕"),
        ),
      );
    }
  }

  void _mostrarDialogoRed(String titulo, String clave, String valorActual) {
    final TextEditingController controller =
        TextEditingController(text: valorActual);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Agregar enlace de $titulo"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "https://tuenlace.com",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () {
              _guardarDato(clave, controller.text);
              Navigator.pop(context);
              _cargarDatos();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== SECCIÓN 1: Apariencia =====
          Text(
            "Apariencia",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: darkMode,
            onChanged: (val) {
              setState(() => darkMode = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    darkMode
                        ? "Modo oscuro activado 🌙"
                        : "Modo claro activado ☀️",
                  ),
                ),
              );
            },
            title: const Text("Modo oscuro"),
            secondary: const Icon(Icons.dark_mode),
          ),

          const Divider(height: 30),

          // ===== SECCIÓN 2: Privacidad =====
          Text(
            "Privacidad",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: perfilPrivado,
            onChanged: (val) {
              setState(() => perfilPrivado = val);
            },
            title: const Text("Perfil privado"),
            subtitle:
                const Text("Solo usuarios aprobados podrán ver tu perfil"),
            secondary: const Icon(Icons.lock_outline),
          ),
          SwitchListTile(
            value: mostrarRedes,
            onChanged: (val) {
              setState(() => mostrarRedes = val);
            },
            title: const Text("Mostrar mis redes sociales"),
            secondary: const Icon(Icons.share_rounded),
          ),

          const Divider(height: 30),

          // ===== SECCIÓN 3: Conexiones =====
          Text(
            "Conexiones",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          _buildConexionTile("Facebook", Icons.facebook, Colors.blue[800]!,
              facebook, "facebook"),
          _buildConexionTile("Instagram", Icons.camera_alt, Colors.pink,
              instagram, "instagram"),
          _buildConexionTile("LinkedIn", Icons.business_center,
              const Color(0xFF0A66C2), linkedin, "linkedin"),
          _buildConexionTile(
              "Sitio Web", Icons.public, Colors.green, web, "web"),
          _buildConexionTile("WhatsApp", Icons.chat, const Color(0xFF25D366),
              whatsapp, "whatsapp"),
        ],
      ),
    );
  }

  Widget _buildConexionTile(
      String titulo, IconData icono, Color color, String valor, String clave) {
    return ListTile(
      leading: Icon(icono, color: color),
      title: Text(titulo),
      subtitle:
          valor.isNotEmpty ? Text(valor) : const Text("Sin enlace agregado"),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: () {
        if (valor.isNotEmpty) {
          _abrirEnlace(valor);
        } else {
          _mostrarDialogoRed(titulo, clave, valor);
        }
      },
    );
  }
}
