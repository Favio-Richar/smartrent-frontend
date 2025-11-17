import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:app_links/app_links.dart';

class PagoWebPayPage extends StatefulWidget {
  final String url;
  final String token;

  const PagoWebPayPage({
    super.key,
    required this.url,
    required this.token,
  });

  @override
  State<PagoWebPayPage> createState() => _PagoWebPayPageState();
}

class _PagoWebPayPageState extends State<PagoWebPayPage> {
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();

    // Listener deep links directos
    final links = AppLinks();
    _sub = links.uriLinkStream.listen((uri) {
      if (uri.scheme == "smartrent" && uri.host == "payment-result") {
        final status = uri.queryParameters["status"] ?? "failed";

        Navigator.of(context).pushNamedAndRemoveUntil(
          status == "success"
              ? "/suscripciones/pago-exitoso"
              : "/suscripciones/pago-fallido",
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final htmlForm = """
      <html>
        <body onload="document.forms[0].submit()">
          <form action="${widget.url}" method="POST">
            <input type="hidden" name="token_ws" value="${widget.token}">
          </form>
        </body>
      </html>
    """;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Procesando pago..."),
        centerTitle: true,
      ),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(data: htmlForm),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
          ),
          android: AndroidInAppWebViewOptions(
            mixedContentMode:
                AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
        ),
        shouldOverrideUrlLoading: (controller, nav) async {
          final url = nav.request.url.toString();
          print("🌐 Navegando: $url");

          // 🔥🔥🔥 CAPTURA EL deep link ANTES DEL CRASH
          if (url.startsWith("smartrent://")) {
            final uri = Uri.parse(url);
            final status = uri.queryParameters["status"] ?? "failed";

            // 🔥 CERRAMOS EL WEBVIEW PRIMERO → evita crash
            Navigator.pop(context);

            Future.microtask(() {
              Navigator.of(context).pushNamedAndRemoveUntil(
                status == "success"
                    ? "/suscripciones/pago-exitoso"
                    : "/suscripciones/pago-fallido",
                (route) => false,
              );
            });

            // 🔥 MUY IMPORTANTE → EVITAR QUE WEBVIEW CARGUE EL deep link
            return NavigationActionPolicy.CANCEL;
          }

          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
