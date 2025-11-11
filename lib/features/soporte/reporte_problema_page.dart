import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smartrent_plus/data/providers/soporte_provider.dart';
import 'package:smartrent_plus/data/services/api_service.dart';
import 'package:smartrent_plus/data/services/soporte_service.dart';

/// Wrapper: si no hay SoporteProvider en el árbol, lo crea localmente.
class ReporteProblemaPage extends StatelessWidget {
  const ReporteProblemaPage({super.key});

  bool _hasProvider(BuildContext context) {
    try {
      Provider.of<SoporteProvider>(context, listen: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasProvider(context)) return const _ReporteBody();
    return ChangeNotifierProvider(
      create: (_) => SoporteProvider(SoporteService(ApiService())),
      child: const _ReporteBody(),
    );
  }
}

class _ReporteBody extends StatefulWidget {
  const _ReporteBody();

  @override
  State<_ReporteBody> createState() => _ReporteBodyState();
}

class _ReporteBodyState extends State<_ReporteBody> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();

  final _quickCategories = const ['app', 'pago', 'cuenta', 'otro'];

  String? _category;
  String _priority = 'media';
  XFile? _image;

  bool _includeDeviceInfo = true;
  bool _consent = false;

  static const _maxDesc = 600;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (img != null) setState(() => _image = img);
  }

  void _removeImage() {
    setState(() => _image = null);
  }

  String _deviceInfo() {
    // Info mínima “fake-safe”. Si tienes paquete device_info_plus puedes reemplazarlo.
    return '(info: plataforma ${Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'otro'})';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar la política de soporte')),
      );
      return;
    }

    final soporte = context.read<SoporteProvider>();

    final baseDesc = _descCtrl.text.trim();
    final finalDesc =
        _includeDeviceInfo ? '$baseDesc\n\n$_deviceInfo()' : baseDesc;

    final ok = await soporte.sendTicket(
      subject: _subjectCtrl.text.trim(),
      description: '[PRIORIDAD: ${_priority.toUpperCase()}] $finalDesc',
      category: _category,
      image: _image,
    );

    if (!mounted) return;

    if (ok) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 56),
          content: const Text(
              'Tu reporte fue enviado. Te notificaremos cuando cambie el estado.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Listo'),
            ),
          ],
        ),
      );
    } else {
      final msg = soporte.error ?? 'Error desconocido';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sending = context.watch<SoporteProvider>().sending;

    return Scaffold(
      appBar: AppBar(title: const Text('Reportar un problema')),
      body: AbsorbPointer(
        absorbing: sending,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // --------- Detalles ---------
                _SectionCard(
                  title: 'Detalles del problema',
                  trailing: Tooltip(
                    message:
                        'Cuéntanos qué ocurrió, qué esperabas que pasara y, si puedes, cómo reproducirlo.',
                    child: const Icon(Icons.info_outline, size: 18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categoría
                      _Labeled(
                        label: 'Categoría',
                        requiredMark: true,
                        helper:
                            'Nos ayuda a derivar el caso al equipo correcto.',
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            hintText: 'Selecciona una categoría',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'app', child: Text('App / UI')),
                            DropdownMenuItem(
                                value: 'pago',
                                child: Text('Pagos / Suscripciones')),
                            DropdownMenuItem(
                                value: 'cuenta',
                                child: Text('Cuenta / Acceso')),
                            DropdownMenuItem(
                                value: 'otro', child: Text('Otro')),
                          ],
                          value: _category,
                          onChanged: (v) => setState(() => _category = v),
                          validator: (v) =>
                              v == null ? 'Selecciona una categoría' : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Chips rápidos
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickCategories
                            .map((c) => ChoiceChip(
                                  label: Text({
                                    'app': 'App/UI',
                                    'pago': 'Pagos',
                                    'cuenta': 'Cuenta',
                                    'otro': 'Otro'
                                  }[c]!),
                                  selected: _category == c,
                                  onSelected: (_) =>
                                      setState(() => _category = c),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 16),

                      // Prioridad
                      _Labeled(
                        label: 'Prioridad',
                        helper: 'Usa “Alta” si te impide continuar.',
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'baja',
                                child: Text('Baja – menor impacto')),
                            DropdownMenuItem(
                                value: 'media',
                                child: Text('Media – afecta uso')),
                            DropdownMenuItem(
                                value: 'alta',
                                child: Text('Alta – bloquea flujo')),
                          ],
                          value: _priority,
                          onChanged: (v) =>
                              setState(() => _priority = v ?? 'media'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Asunto
                      _Labeled(
                        label: 'Asunto',
                        requiredMark: true,
                        child: TextFormField(
                          controller: _subjectCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Ej.: Error al confirmar pago',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingresa un asunto'
                              : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Descripción
                      _Labeled(
                        label: 'Descripción del problema',
                        requiredMark: true,
                        helper:
                            'Incluye pasos para reproducirlo y el mensaje de error si aparece.',
                        child: _DescriptionField(
                          controller: _descCtrl,
                          maxChars: _maxDesc,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Device info + consentimiento
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Incluir info del dispositivo'),
                        subtitle: const Text(
                            'Se agrega información mínima (p. ej., plataforma) para diagnóstico.'),
                        value: _includeDeviceInfo,
                        onChanged: (v) =>
                            setState(() => _includeDeviceInfo = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // --------- Adjuntos ---------
                _SectionCard(
                  title: 'Adjuntos',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.attach_file_rounded),
                        label: const Text('Adjuntar imagen'),
                      ),
                      if (_image != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_image!.path),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _image!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _removeImage,
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Quitar'),
                            ),
                          ],
                        ),
                      ],
                      Text(
                        'Formatos: JPG/PNG (recomendado).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // --------- Resumen / Consentimiento ---------
                _SectionCard(
                  title: 'Resumen',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryRow('Categoría', _category ?? '—'),
                      _SummaryRow('Prioridad', _priority.toUpperCase()),
                      _SummaryRow('Asunto',
                          _subjectCtrl.text.isEmpty ? '—' : _subjectCtrl.text),
                      _SummaryRow(
                          'Adjunto', _image != null ? _image!.name : '—'),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Acepto la política de soporte'),
                        subtitle: const Text(
                            'Autorizo el tratamiento de mi reporte para su resolución.'),
                        value: _consent,
                        onChanged: (v) => setState(() => _consent = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --------- Enviar ---------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (sending) ? null : _submit,
                    icon: sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(sending ? 'Enviando...' : 'Enviar reporte'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ UI helpers ============================

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  final bool requiredMark;
  final String? helper;

  const _Labeled({
    required this.label,
    required this.child,
    this.requiredMark = false,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: labelStyle),
            if (requiredMark)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        child,
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _DescriptionField extends StatefulWidget {
  final TextEditingController controller;
  final int maxChars;
  const _DescriptionField({required this.controller, this.maxChars = 600});

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late int remaining;

  @override
  void initState() {
    super.initState();
    remaining = widget.maxChars;
    widget.controller.addListener(_update);
  }

  void _update() {
    setState(() {
      remaining = widget.maxChars - widget.controller.text.length;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          maxLines: 6,
          maxLength: widget.maxChars,
          decoration: const InputDecoration(
            hintText:
                'Explica qué estabas haciendo, qué pasó y qué esperabas que pasara…',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.trim().length < 10)
              ? 'Describe al menos con 10 caracteres'
              : null,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$remaining caracteres restantes',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: secondary)),
        ],
      ),
    );
  }
}
