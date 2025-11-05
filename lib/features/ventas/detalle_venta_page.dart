import 'package:flutter/material.dart';

class DetalleVentaPage extends StatelessWidget {
  final String ventaId;
  const DetalleVentaPage({super.key, required this.ventaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle venta #$ventaId')),
      body: Center(child: Text('Detalle de la venta $ventaId')),
    );
  }
}
