import 'package:flutter/material.dart';

class RegistroEmpresaPage extends StatelessWidget {
  const RegistroEmpresaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de empresa')),
      body: const Center(child: Text('Formulario de registro de empresa')),
    );
  }
}
