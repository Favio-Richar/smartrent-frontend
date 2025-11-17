// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartrent_plus/data/providers/company_provider.dart';
import 'package:smartrent_plus/features/empresas/perfil_empresa_page.dart';

class EmpresasPage extends StatefulWidget {
  const EmpresasPage({super.key});

  @override
  State<EmpresasPage> createState() => _EmpresasPageState();
}

class _EmpresasPageState extends State<EmpresasPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String query = "";

  @override
  void initState() {
    super.initState();
    Provider.of<CompanyProvider>(context, listen: false).loadCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // 🔵 Fondo degradado
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 Título principal
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Center(
                    child: Text(
                      "Empresas Registradas",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔍 BUSCADOR flotante
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Buscar empresa...",
                      ),
                      onChanged: (value) {
                        setState(() => query = value.toLowerCase());
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Expanded(child: _buildCompanyList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyList() {
    return Consumer<CompanyProvider>(
      builder: (_, provider, __) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // FILTRAR POR BUSQUEDA
        final filtered = provider.companies.where((c) {
          final name = c.nombreEmpresa.toLowerCase();
          final desc = c.descripcion?.toLowerCase() ?? "";
          return name.contains(query) || desc.contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "No se encontraron empresas.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final c = filtered[i];

            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PerfilEmpresaPage(
                        companyId: c.id ?? 0,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 🟦 Avatar empresa
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.apartment_rounded,
                          size: 32,
                          color: Colors.blue.shade700,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 📄 Info empresa
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.nombreEmpresa,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.descripcion ?? "Sin descripción",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Colors.grey.shade500,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
