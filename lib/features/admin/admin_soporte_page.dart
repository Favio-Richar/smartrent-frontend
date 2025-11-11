// ===============================================================
// 🧩 ADMIN SOPORTE PAGE (Diseño refinado para Panel Administrativo)
// ---------------------------------------------------------------
// - Mantiene pestañas internas
// - Quita flecha innecesaria
// - Ajusta color para coincidir con AppTheme
// ===============================================================

import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/features/admin/soporte/tickets_tab.dart';
import 'package:smartrent_plus/features/admin/soporte/feedback_tab.dart';
import 'package:smartrent_plus/features/admin/soporte/community_tab.dart';
import 'package:smartrent_plus/features/admin/soporte/faqs_tab.dart';

class AdminSoportePage extends StatefulWidget {
  const AdminSoportePage({super.key});

  @override
  State<AdminSoportePage> createState() => _AdminSoportePageState();
}

class _AdminSoportePageState extends State<AdminSoportePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(icon: Icon(Icons.support_agent_outlined), text: 'Tickets'),
    Tab(icon: Icon(Icons.star_rate_rounded), text: 'Reseñas'),
    Tab(icon: Icon(Icons.forum_outlined), text: 'Comunidad'),
    Tab(icon: Icon(Icons.help_outline_rounded), text: 'FAQs'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // 👈 elimina la flecha de retroceso innecesaria
        title: const Text('Gestión de Soporte'),
        backgroundColor:
            AppTheme.primaryColor.withOpacity(0.95), // 👈 color más suave
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TicketsTab(),
          FeedbackTab(),
          CommunityTab(),
          FaqsTab(),
        ],
      ),
    );
  }
}
