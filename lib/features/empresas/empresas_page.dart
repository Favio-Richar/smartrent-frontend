// ===============================================================
// 🔹 EMPRESAS PAGE - SmartRent+ (sin AppBar interno)
// ===============================================================

import 'package:flutter/material.dart';

class EmpresasPage extends StatelessWidget {
  const EmpresasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apartment_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '📋 Aquí se mostrarán las empresas registradas desde el backend.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
