import 'package:flutter/material.dart';

class MisVentasPage extends StatelessWidget {
  const MisVentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis ventas')),
      body: const Center(child: Text('Listado de mis ventas')),
    );
  }
}
