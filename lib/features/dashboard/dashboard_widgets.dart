// ===============================================================
// 🔹 DASHBOARD WIDGETS - SMARTRENT+ (versión corregida y optimizada)
// ===============================================================

import 'package:flutter/material.dart';

// ---------------------------------------------------------------
// 🔍 Buscador Global
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
// 🏘️ Carruseles visuales
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
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listado.length,
        itemBuilder: (context, i) {
          final item = listado[i];
          return _CardItem(
            image: item['image_url'] ??
                'https://cdn-icons-png.flaticon.com/512/869/869636.png',
            title: item['title'] ?? 'Propiedad',
            subtitle: item['price'] != null
                ? '\$${item['price']} CLP'
                : 'Ver detalle',
          );
        },
      ),
    );
  }
}

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
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listado.length,
        itemBuilder: (context, i) {
          final item = listado[i];
          return _CardItem(
            image: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
            title: item['title'] ?? 'Empleo',
            subtitle: item['category'] ?? 'General',
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------
// 🪧 Card genérica reutilizable
// ---------------------------------------------------------------
class _CardItem extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _CardItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              image,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// 🚀 Accesos rápidos según tipo de usuario
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
          context,
          Icons.house_rounded,
          'Ver arriendos',
          '/arriendos',
        ),
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
        _quickButton(
          context,
          Icons.add_business,
          'Publicar arriendo',
          '/arriendos/crear',
        ),
        _quickButton(
          context,
          Icons.storefront,
          'Publicar venta',
          '/ventas/crear',
        ),
        _quickButton(context, Icons.work, 'Publicar empleo', '/empleos/crear'),
        _quickButton(
          context,
          Icons.analytics,
          'Ver métricas',
          '/empresa/panel',
        ),
      ],
    );
  }
}

Widget _quickButton(
  BuildContext context,
  IconData icon,
  String label,
  String route,
) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    // ✅ Aquí se corrige el error de tipo
    onPressed: () => Navigator.pushNamed(context, route),
    icon: Icon(icon, color: Colors.white, size: 20),
    label: Text(
      label,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}
