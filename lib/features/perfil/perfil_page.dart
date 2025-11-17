import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import 'configuracion_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String nombreUsuario = "SmartRent Usuario";
  String descripcion = "";
  final TextEditingController descripcionController = TextEditingController();

  String facebook = "";
  String instagram = "";
  String linkedin = "";
  String web = "";
  String whatsapp = "";

  // FOTO PERFIL
  String? imageUrl;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('nombreUsuario') ?? "SmartRent Usuario";
      descripcion = prefs.getString('descripcion') ?? "";
      descripcionController.text = descripcion;
      facebook = prefs.getString('facebook') ?? "";
      instagram = prefs.getString('instagram') ?? "";
      linkedin = prefs.getString('linkedin') ?? "";
      web = prefs.getString('web') ?? "";
      whatsapp = prefs.getString('whatsapp') ?? "";
      imageUrl = prefs.getString("profileImage");
    });
  }

  Future<void> _guardarDescripcion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('descripcion', descripcionController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Descripción guardada correctamente ✅")),
    );
  }

  Future<void> _abrirEnlace(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay enlace configurado 😕")),
      );
      return;
    }

    final Uri uri = Uri.parse(url.startsWith("http") ? url : "https://$url");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir el enlace 😕")),
      );
    }
  }

  // ============================
  // 📸 Cargar foto desde cámara / galeria
  // ============================

  Future<void> _seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SizedBox(
          height: 160,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text("Elegir desde galería"),
                onTap: () async {
                  Navigator.pop(context);
                  await _procesarFoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text("Tomar foto"),
                onTap: () async {
                  Navigator.pop(context);
                  await _procesarFoto(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _procesarFoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    try {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
      });

      final dio = Dio();

      final response = await dio.post(
        "http://10.0.2.2:3000/api/uploads/image",
        data: formData,
      );

      final uploadedUrl = response.data["url"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("profileImage", uploadedUrl);

      setState(() => imageUrl = uploadedUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto de perfil actualizada 😎")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al subir la foto: $e")),
      );
    }
  }

  // ============================
  // UI COMPLETO
  // ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      body: Stack(
        children: [
          Container(
            height: 190,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
            child: Column(
              children: [
                // =================== TARJETA PERFIL ===================
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.settings,
                              color: Colors.blueAccent),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConfiguracionPage(),
                              ),
                            );
                            _cargarDatos();
                          },
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // FOTO DE PERFIL REAL
                              GestureDetector(
                                onTap: _seleccionarFoto,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 48,
                                      backgroundImage: imageUrl != null
                                          ? NetworkImage(imageUrl!)
                                          : const AssetImage(
                                                  "assets/images/profile_placeholder.png")
                                              as ImageProvider,
                                      backgroundColor: Colors.grey[200],
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blueAccent,
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: const Icon(Icons.add,
                                            color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 18),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombreUsuario,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final nuevoNombre =
                                            await _editarNombre(context);
                                        if (nuevoNombre != null &&
                                            nuevoNombre.isNotEmpty) {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          await prefs.setString(
                                              'nombreUsuario', nuevoNombre);
                                          setState(() =>
                                              nombreUsuario = nuevoNombre);
                                        }
                                      },
                                      child: Row(
                                        children: const [
                                          Icon(Icons.edit,
                                              size: 14, color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(
                                            "Editar nombre",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: descripcionController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText:
                                  "¿Qué tienes para ofrecer o buscas en SmartRent+?",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4A90E2),
                                    Color(0xFF007AFF)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _guardarDescripcion,
                                icon: const Icon(Icons.cloud_upload_outlined,
                                    color: Colors.white),
                                label: const Text(
                                  "Guardar descripción",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              "⚠️ Preséntate y sé cortés, no queremos borrarte la cuenta 😅",
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Redes sociales",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  children: [
                    _buildRedIcon("assets/images/facebook_icon.png", facebook),
                    _buildRedIcon(
                        "assets/images/instagram_icon.png", instagram),
                    _buildRedIcon("assets/images/linkedin_icon.png", linkedin),
                    _buildRedIcon("assets/images/web_icon.png", web),
                    _buildRedIcon("assets/images/whatsapp_icon.png", whatsapp),
                  ],
                ),

                const SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sugerencias de empresas",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),

                _buildEmpresaCard("Tech Innovators", "Tecnología y desarrollo"),
                _buildEmpresaCard("EcoHome", "Sostenibilidad y hogar"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedIcon(String asset, String url) {
    return GestureDetector(
      onTap: () => _abrirEnlace(url),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(asset),
        ),
      ),
    );
  }

  Widget _buildEmpresaCard(String nombre, String categoria) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.apartment, color: Colors.blueAccent),
        title: Text(nombre,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(categoria),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }

  Future<String?> _editarNombre(BuildContext context) async {
    final TextEditingController controller =
        TextEditingController(text: nombreUsuario);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar nombre de usuario"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Ingresa tu nuevo nombre",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Guardar"),
            onPressed: () => Navigator.pop(context, controller.text),
          ),
        ],
      ),
    );
  }
}
