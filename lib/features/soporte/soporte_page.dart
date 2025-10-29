import 'package:flutter/material.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';

class SoportePage extends StatelessWidget {
  const SoportePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Centro de Soporte'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "¿Necesitas ayuda? Escríbenos desde la sección de Reporte de Problemas o consulta las Preguntas Frecuentes.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
