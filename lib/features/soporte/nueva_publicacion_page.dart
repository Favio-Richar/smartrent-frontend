import 'package:flutter/material.dart';

class NuevaPublicacionPage extends StatefulWidget {
  const NuevaPublicacionPage({super.key});

  @override
  State<NuevaPublicacionPage> createState() => _NuevaPublicacionPageState();
}

class _NuevaPublicacionPageState extends State<NuevaPublicacionPage> {
  final _formKey = GlobalKey<FormState>();
  final _authorCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _authorCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, String>{
      'author': _authorCtrl.text.trim(),
      'title': _titleCtrl.text.trim(),
      'body': _bodyCtrl.text.trim(),
    };

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva publicación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _Labeled(
                    label: 'Tu nombre (se muestra públicamente)',
                    child: TextFormField(
                      controller: _authorCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ej.: Marta G.',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa tu nombre'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Labeled(
                    label: 'Problema (título)',
                    child: TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        hintText:
                            'Ej.: Problemas con el pago en tarjeta débito',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().length < 6)
                          ? 'Título muy corto'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Labeled(
                    label: 'Solución / Detalles',
                    child: TextFormField(
                      controller: _bodyCtrl,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText:
                            'Cuenta cómo lo resolviste o qué te funcionó. Sé específico para ayudar a otros.',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Escribe más detalles'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Publicar'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tu publicación será visible para todos los usuarios.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labeled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
