// ===============================================================
// 🔹 DASHBOARD WIDGETS - SMARTRENT+ (VERSIÓN PROFESIONAL PREMIUM FINAL)
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/routes/app_routes.dart';

// ---------------------------------------------------------------
// 🔍 BUSCADOR GLOBAL
// ---------------------------------------------------------------
class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearch;
  const SearchBarWidget({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
        hintText: 'Buscar arriendos, ventas o empleos...',
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// 🏘️ CARRUSEL DE PROPIEDADES
// ---------------------------------------------------------------
class PropertyCarousel extends StatelessWidget {
  final List<dynamic> listado;
  const PropertyCarousel({super.key, required this.listado});

  @override
  Widget build(BuildContext context) {
    if (listado.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text('No hay propiedades disponibles.'),
      );
    }

    return SizedBox(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listado.length,
        itemBuilder: (context, i) {
          return PropertyCardPro(data: listado[i]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------
// 💼 CARRUSEL DE EMPLEOS — usa mismo card PRO
// ---------------------------------------------------------------
class JobsCarousel extends StatelessWidget {
  final List<dynamic> listado;
  const JobsCarousel({super.key, required this.listado});

  @override
  Widget build(BuildContext context) {
    if (listado.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text('No hay empleos disponibles.'),
      );
    }

    return SizedBox(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listado.length,
        itemBuilder: (context, i) {
          return PropertyCardPro(data: listado[i]);
        },
      ),
    );
  }
}

// ===============================================================
// ⭐ CARD PROFESIONAL – MEGA FINAL (Tasty / Airbnb / Marketplace)
// ===============================================================
class PropertyCardPro extends StatefulWidget {
  final Map<String, dynamic> data;

  const PropertyCardPro({super.key, required this.data});

  @override
  State<PropertyCardPro> createState() => _PropertyCardProState();
}

class _PropertyCardProState extends State<PropertyCardPro> {
  bool favorito = false;
  int userRating = 0;

  @override
  void initState() {
    super.initState();
    favorito = widget.data["favorito"] ?? false;
    userRating = (widget.data["rating"] ?? 4.5).round();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    final imagen = d["imagen"] ??
        d["image_url"] ??
        "https://cdn-icons-png.flaticon.com/512/869/869636.png";

    final titulo = d["titulo"] ?? d["title"] ?? "Sin título";
    final precio = d["precio"]?.toString() ?? d["price"]?.toString() ?? "0";

    final comentarios = d["comentarios"]?.length ?? 0;

    final usuario = d["usuario"] ?? {};
    final userNombre = usuario["nombre"] ?? "Usuario";
    final userFoto = usuario["foto"] ??
        "https://cdn-icons-png.flaticon.com/512/3135/3135715.png";

    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- FOTO ----------------
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: Image.network(
                  imagen,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // ❤️ FAVORITO
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => setState(() => favorito = !favorito),
                  child: AnimatedScale(
                    scale: favorito ? 1.3 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      favorito ? Icons.favorite : Icons.favorite_border,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ---------------- TITULO ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // ---------------- PRECIO ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              "\$$precio CLP / mes",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),

          // ---------------- CALIFICACIÓN (interactiva) ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => userRating = i + 1),
                  child: Icon(
                    Icons.star,
                    size: 22,
                    color:
                        (i < userRating) ? Colors.amber : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ---------------- COMENTARIOS ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.comentar,
                arguments: {
                  "id": d["id"],
                  "titulo": titulo,
                  "imagen": imagen,
                  "userFoto": userFoto,
                  "userNombre": userNombre,
                },
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text(
                    "$comentarios comentarios",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ---------------- REACCIONES PRO ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.thumb_up_alt_outlined,
                      size: 22, color: Colors.blueGrey.shade600),
                  Icon(Icons.favorite_border,
                      size: 22, color: Colors.redAccent),
                  Icon(Icons.emoji_emotions_outlined,
                      size: 22, color: Colors.amber.shade800),
                  Icon(Icons.local_fire_department,
                      size: 22, color: Colors.deepOrange),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ---------------- USUARIO ----------------
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(userFoto),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userNombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// 🚀 ACCESOS RÁPIDOS (igual)
// ---------------------------------------------------------------
class UserQuickActions extends StatelessWidget {
  const UserQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _quickButton(
            context, Icons.house_rounded, 'Ver arriendos', '/arriendos'),
        _quickButton(context, Icons.sell, 'Ver ventas', '/ventas'),
        _quickButton(context, Icons.work_outline, 'Empleos', '/empleos'),
        _quickButton(context, Icons.favorite, 'Favoritos', '/favoritos'),
      ],
    );
  }
}

class CompanyQuickActions extends StatelessWidget {
  const CompanyQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _quickButton(context, Icons.add_business, 'Publicar arriendo',
            '/arriendos/crear'),
        _quickButton(
            context, Icons.storefront, 'Publicar venta', '/ventas/crear'),
        _quickButton(context, Icons.work, 'Publicar empleo', '/empleos/crear'),
        _quickButton(
            context, Icons.analytics, 'Ver métricas', '/empresa/panel'),
      ],
    );
  }
}

// ---------------------------------------------------------------
// ✔ BOTÓN UTILITARIO
// ---------------------------------------------------------------
Widget _quickButton(
  BuildContext context,
  IconData icon,
  String label,
  String route,
) {
  return ElevatedButton.icon(
    onPressed: () => Navigator.pushNamed(context, route),
    icon: Icon(icon, color: Colors.white, size: 20),
    label: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}
