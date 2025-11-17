import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartrent_plus/data/services/company_service.dart';

class PerfilEmpresaPage extends StatefulWidget {
  final int companyId;
  const PerfilEmpresaPage({super.key, required this.companyId});

  @override
  State<PerfilEmpresaPage> createState() => _PerfilEmpresaPageState();
}

class _PerfilEmpresaPageState extends State<PerfilEmpresaPage> {
  final _svc = CompanyService();
  Map<String, dynamic>? _company;
  bool _loading = true;

  final _picker = ImagePicker();
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _svc.getCompanyById(widget.companyId);
    if (!mounted) return;

    setState(() {
      _company = data?.toJson();
      _loading = false;
    });
  }

  Future<void> _cambiarFoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  String safe(dynamic value, [String def = "-"]) {
    if (value == null) return def;
    final t = value.toString().trim();
    return t.isEmpty ? def : t;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final c = _company ?? {};

    final nombre = safe(c["nombreEmpresa"], "Empresa");
    final descripcion =
        safe(c["descripcion"], "Esta empresa aún no agregó una descripción.");
    final telefono = safe(c["telefono"]);
    final correo = safe(c["correo"]);
    final sitioWeb = safe(c["sitioWeb"]);
    final direccion = safe(c["direccion"]);
    final horario =
        "${safe(c["horaApertura"], "?")} - ${safe(c["horaCierre"], "?")}";

    final String logoUrl = (c["logo"] ?? "").toString();

    // ======================================================
    // ⚠️ FOTO REAL CORRECTA
    // ======================================================
    ImageProvider<Object>? foto;

    if (_newImage != null) {
      foto = FileImage(_newImage!);
    } else if (logoUrl.isNotEmpty) {
      foto = NetworkImage(logoUrl);
    } else {
      foto = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 290,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF004AAD), Color(0xFF5AB2FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 26),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/editar_empresa");
                              },
                              icon: const Icon(Icons.settings_outlined,
                                  color: Colors.white, size: 26),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ======================================================
                      // FOTO → FIX 100% FUNCIONAL
                      // ======================================================
                      GestureDetector(
                        onTap: _cambiarFoto,
                        child: CircleAvatar(
                          radius: 62,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: foto,
                            child: foto == null
                                ? Icon(Icons.apartment_rounded,
                                    size: 58, color: Colors.blue.shade700)
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        descripcion,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Estadísticas"),
                _statsCard(),
                _sectionTitle("Información general"),
                _premiumCard(
                  child: Column(
                    children: [
                      _infoItem(Icons.location_on, "Dirección", direccion),
                      _infoItem(Icons.phone, "Teléfono", telefono),
                      _infoItem(Icons.email, "Correo", correo),
                      _infoItem(Icons.link, "Sitio web", sitioWeb),
                    ],
                  ),
                ),
                _sectionTitle("Horario de atención"),
                _premiumCard(child: _infoRow(Icons.access_time, horario)),
                _sectionTitle("Acciones rápidas"),
                _quickActions(telefono, sitioWeb),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // COMPONENTES
  // ====================================================

  Widget _statsCard() {
    return _premiumCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.star, "4.9", "Rating"),
          _statItem(Icons.visibility, "1.2K", "Visitas"),
          _statItem(Icons.work, "12", "Publicaciones"),
        ],
      ),
    );
  }

  Widget _premiumCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 22, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue.shade700),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.blue.shade700),
        const SizedBox(width: 14),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _statItem(IconData icon, String number, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue.shade700),
        const SizedBox(height: 6),
        Text(number,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _quickActions(String telefono, String sitioWeb) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.call,
              text: "Llamar",
              color: Colors.green.shade600,
              onTap: () {
                if (telefono != "-") {
                  launchUrl(Uri.parse("tel:$telefono"));
                }
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _actionButton(
              icon: Icons.language,
              text: "Sitio Web",
              color: Colors.blue.shade700,
              onTap: () {
                if (sitioWeb != "-") {
                  launchUrl(Uri.parse(sitioWeb));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required String text,
      required Color color,
      required Function onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
