// ===============================================================
// 💳 PAGO SISTEMA PAGE – SmartRent+ (versión final corregida y mejorada)
// ---------------------------------------------------------------
// ✅ Conexión real al backend NestJS (ruta: /api/subscriptions/pay)
// ✅ Usa SharedPreferences para obtener el userId del login
// ✅ Acepta respuestas 200 y 201 del backend
// ✅ Muestra mensajes de error más claros
// ✅ Verifica conexión con backend antes del pago
// ===============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'pago_transbank_page.dart'; // ✅ Pasarela Webpay (usa WebView real)

class PagoSistemaPage extends StatefulWidget {
  final String plan;
  final String precio;
  final Color color;

  const PagoSistemaPage({
    super.key,
    required this.plan,
    required this.precio,
    required this.color,
  });

  @override
  State<PagoSistemaPage> createState() => _PagoSistemaPageState();
}

class _PagoSistemaPageState extends State<PagoSistemaPage> {
  final _formKey = GlobalKey<FormState>();
  String _metodoSeleccionado = 'Webpay';

  // Controladores de texto
  final _emailCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _direccionCtrl.dispose();
    _ciudadCtrl.dispose();
    _zipCtrl.dispose();
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  // ================================================================
  // 🔸 FORMATEOS
  // ================================================================
  String _formatCardNumber(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final groups = <String>[];
    for (var i = 0; i < digits.length; i += 4) {
      groups.add(
          digits.substring(i, i + 4 > digits.length ? digits.length : i + 4));
    }
    return groups.join(' ');
  }

  String _formatExpiry(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 2) return digits;
    return '${digits.substring(0, 2)}/${digits.substring(2, digits.length > 4 ? 4 : digits.length)}';
  }

  // ================================================================
  // 🔸 FUNCIÓN CONFIRMAR PAGO (real con backend)
  // ================================================================
  Future<void> _confirmarPago() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos requeridos')),
      );
      return;
    }

    try {
      // ✅ Verificar conexión con backend antes de enviar
      final connected = await _testBackendConnection();
      if (!connected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay conexión con el servidor')),
        );
        return;
      }

      // ✅ Cargar el userId guardado del login
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró usuario logueado')),
        );
        return;
      }

      // ✅ URL del backend (usa 10.0.2.2 si es emulador Android)
      final uri = Uri.parse('http://10.0.2.2:3000/api/subscriptions/pay');

      // ✅ Petición POST al backend
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'plan': widget.plan,
        }),
      );

      // 🔹 Aceptamos 200 o 201 (Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['url'] != null && data['token'] != null) {
          final fullUrl = '${data['url']}?token_ws=${data['token']}';

          // 🔹 Abre la pasarela Webpay real
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PagoTransbankPage(
                url: fullUrl,
                plan: widget.plan,
                precio: widget.precio,
                color: widget.color,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Respuesta inválida del backend')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al iniciar pago (${response.statusCode}). Verifica backend.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión con el servidor: $e')),
      );
    }
  }

  // ================================================================
  // 🔸 PRUEBA DE CONEXIÓN (opcional pero útil)
  // ================================================================
  Future<bool> _testBackendConnection() async {
    try {
      final res = await http
          .get(Uri.parse('http://10.0.2.2:3000/api'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } on SocketException {
      return false;
    } on HttpException {
      return false;
    } on FormatException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ================================================================
  // 🔸 INTERFAZ
  // ================================================================
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema de pago', style: GoogleFonts.poppins()),
        backgroundColor: widget.color,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isWide ? _layoutAncho() : _layoutMovil(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmarPago,
        backgroundColor: widget.color,
        label: Text(
          'Pagar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.payment),
      ),
    );
  }

  // ================================================================
  // 🔸 LAYOUTS
  // ================================================================
  Widget _layoutMovil() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _resumenPedido(),
        const SizedBox(height: 14),
        _metodosPago(),
        const SizedBox(height: 14),
        Form(key: _formKey, child: _buildCamposPago()),
      ],
    );
  }

  Widget _layoutAncho() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _resumenPedido()),
        const SizedBox(width: 16),
        Expanded(
            flex: 2, child: Form(key: _formKey, child: _buildCamposPago())),
      ],
    );
  }

  // ================================================================
  // 🔸 COMPONENTES
  // ================================================================
  Widget _resumenPedido() => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumen de pedido',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _rowDetalle('Plan', widget.plan),
              _rowDetalle('Precio', widget.precio),
              _rowDetalle('Tiempo de proceso', 'Hasta 15 minutos'),
            ],
          ),
        ),
      );

  Widget _rowDetalle(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey[700])),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      );

  Widget _metodosPago() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seleccionar método',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: ['Webpay', 'Visa', 'Mastercard', 'Redcompra'].map((m) {
                final selected = _metodoSeleccionado == m;
                return ChoiceChip(
                  selectedColor: widget.color.withOpacity(0.15),
                  selected: selected,
                  avatar: _iconMetodo(m),
                  label: Text(m, style: GoogleFonts.poppins()),
                  onSelected: (_) => setState(() => _metodoSeleccionado = m),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Icon _iconMetodo(String metodo) {
    final map = {
      'Visa': Icons.credit_card,
      'Mastercard': Icons.credit_card,
      'Webpay': Icons.payment,
      'Redcompra': Icons.account_balance,
    };
    return Icon(map[metodo] ?? Icons.payment, color: widget.color, size: 28);
  }

  Widget _buildCamposPago() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _seccionTitulo('Datos del comprador'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'E-mail'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Ingrese un email';
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
              return 'Email inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingrese nombre' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _apellidoCtrl,
              decoration: const InputDecoration(labelText: 'Apellido'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingrese apellido' : null,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        TextFormField(
          controller: _direccionCtrl,
          decoration:
              const InputDecoration(labelText: 'Dirección (calle, número)'),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _ciudadCtrl,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: _zipCtrl,
              decoration: const InputDecoration(labelText: 'Código postal'),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _seccionTitulo('Datos de la tarjeta'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cardCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19)
          ],
          decoration: const InputDecoration(
              labelText: 'Número de tarjeta', hintText: '1234 5678 9012 3456'),
          onChanged: (v) {
            final formatted = _formatCardNumber(v);
            if (formatted != v) {
              _cardCtrl.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
          validator: (v) {
            final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
            if (digits.length < 13) return 'Número inválido';
            return null;
          },
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _expiryCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4)
              ],
              decoration: const InputDecoration(labelText: 'MM/YY'),
              onChanged: (v) {
                final formatted = _formatExpiry(v);
                if (formatted != v) {
                  _expiryCtrl.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingrese expiración';
                if (!RegExp(r'^\d{2}\/\d{2}$').hasMatch(v)) {
                  return 'Formato MM/YY';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: _cvvCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4)
              ],
              decoration: const InputDecoration(labelText: 'CVV'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'CVV';
                if (v.length < 3) return 'CVV inválido';
                return null;
              },
            ),
          ),
        ]),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _confirmarPago,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Confirmar orden y método de pago',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seccionTitulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(texto,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      );
}
