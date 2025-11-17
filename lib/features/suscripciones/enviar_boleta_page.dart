import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/invoice_service.dart';

class EnviarBoletaPage extends StatefulWidget {
  final int paymentId;
  final int userId;

  const EnviarBoletaPage({
    super.key,
    required this.paymentId,
    required this.userId,
  });

  @override
  State<EnviarBoletaPage> createState() => _EnviarBoletaPageState();
}

class _EnviarBoletaPageState extends State<EnviarBoletaPage> {
  final TextEditingController controller = TextEditingController();
  bool sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar boleta')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Correo para enviar boleta:'),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'correo@ejemplo.com',
              ),
            ),
            const SizedBox(height: 20),
            sending
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => sending = true);

                      final resp = await InvoiceService.sendInvoiceEmail(
                        widget.paymentId,
                        controller.text.trim(),
                      );

                      if (!mounted) return;

                      setState(() => sending = false);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(resp)),
                      );
                    },
                    child: const Text("Enviar"),
                  ),
          ],
        ),
      ),
    );
  }
}
