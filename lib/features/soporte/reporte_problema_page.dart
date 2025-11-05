import 'package:flutter/material.dart';

class ReporteProblemaPage extends StatelessWidget {
  const ReporteProblemaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar problema')),
      body: const Center(child: Text('Formulario de reporte de problema')),
    );
  }
}
