// ===============================================================
// 💳 PAGO TRANSBANK PAGE – SmartRent+ (Versión Final y Corregida)
// ---------------------------------------------------------------
// ✅ Mantiene el pago dentro del WebView (sin abrir navegador externo)
// ✅ Detecta confirmación del backend y muestra la boleta
// ✅ Diseño moderno, limpio y compatible Android/iOS
// ===============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class PagoTransbankPage extends StatefulWidget {
  final String url; // ✅ URL de pago entregada por backend
  final String plan;
  final String precio;
  final Color color;

  const PagoTransbankPage({
    super.key,
    required this.url,
    required this.plan,
    required this.precio,
    required this.color,
  });

  @override
  State<PagoTransbankPage> createState() => _PagoTransbankPageState();
}

class _PagoTransbankPageState extends State<PagoTransbankPage> {
  bool _cargando = true;
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          // ✅ Evita que se abra el navegador externo
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🌐 Navegando a: ${request.url}');
            if (request.url.startsWith('http') ||
                request.url.startsWith('https')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageStarted: (_) => setState(() => _cargando = true),
          onPageFinished: (url) async {
            setState(() => _cargando = false);

            // ✅ Detecta retorno desde backend (confirmación)
            if (url.contains('/subscriptions/confirm')) {
              try {
                final content = await _controller
                    .runJavaScriptReturningResult("document.body.innerText");
                final decoded = jsonDecode(content.toString());

                // 🔹 Abre la boleta moderna dentro de la app
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComprobantePagoPage(
                        data: decoded,
                        plan: widget.plan,
                        color: widget.color,
                      ),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('⚠️ Error al parsear JSON: $e');
              }
            } else if (url.contains('error') || url.contains('fail')) {
              _mostrarResultado(context, false);
            }
          },
          onWebResourceError: (error) {
            debugPrint('❌ Error WebView: ${error.description}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cargar WebPay: ${error.description}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('WebPay Transbank'),
        backgroundColor: const Color(0xFFDD0031),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_cargando)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/transbank_logo.png',
                        height: 100),
                    const SizedBox(height: 30),
                    const CircularProgressIndicator(
                      color: Color(0xFFDD0031),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Conectando con Transbank...',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Por favor, no cierres esta ventana',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarResultado(BuildContext context, bool exito) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                exito ? Icons.check_circle : Icons.error,
                color: exito ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                exito ? 'Pago aprobado' : 'Pago rechazado',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            exito
                ? 'Tu plan ${widget.plan} ha sido activado correctamente. 🎉'
                : 'El pago no se pudo completar. Inténtalo nuevamente.',
            style: GoogleFonts.poppins(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    });
  }
}

// ===============================================================
// 🧾 COMPROBANTE DE PAGO PAGE – Boleta moderna tipo factura
// ===============================================================
class ComprobantePagoPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String plan;
  final Color color;

  const ComprobantePagoPage({
    super.key,
    required this.data,
    required this.plan,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final result = data['result'] ?? {};
    final fecha =
        DateTime.tryParse(result['transaction_date'] ?? '') ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Comprobante de Pago'),
        backgroundColor: color,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF disponible próximamente')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 12),
                  Text(
                    "Pago Exitoso",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const Divider(height: 30, thickness: 1),
                  _row("💳 Plan contratado", plan),
                  _row("💰 Monto pagado", "\$${result["amount"] ?? "-"}"),
                  _row("🪪 Código de autorización",
                      result["authorization_code"] ?? "-"),
                  _row("💼 Tipo de pago", result["payment_type_code"] ?? "-"),
                  _row("💳 Últimos dígitos",
                      "**** ${result["card_detail"]?["card_number"] ?? "----"}"),
                  _row(
                    "📅 Fecha de pago",
                    "${fecha.day}/${fecha.month}/${fecha.year} "
                        "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}",
                  ),
                  _row("🧾 Orden de compra", result["buy_order"] ?? "-"),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.home),
                    label: Text(
                      "Volver al inicio",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, color: Colors.grey[800])),
          ),
          Expanded(
              flex: 2,
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.black))),
        ],
      ),
    );
  }
}
