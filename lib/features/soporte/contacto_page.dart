// ===============================================================
// 📞 CONTACTO SOPORTE – SmartRent+
// ---------------------------------------------------------------
// ✅ Llamada directa
// ✅ WhatsApp externo
// ✅ Envío de correo compatible con Android 13/14 (forzado a Gmail)
// ✅ Corregido: uso seguro de BuildContext y eliminación de warnings
// ===============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactoSoportePage extends StatelessWidget {
  const ContactoSoportePage({super.key});

  // Datos de contacto
  static const String _telefonoPretty = '+56 9 5555 5555';
  static const String _telefonoRaw = '56955555555';
  static const String _correo = 'soporte@smartrent.plus';

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------------------------------------------------------
  // 📞 Llamar
  // ---------------------------------------------------------------
  Future<void> _llamar(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _telefonoRaw);
    final canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (canLaunch) {
      await launchUrl(uri);
    } else {
      _toast(context, 'No se pudo iniciar la llamada.');
    }
  }

  // ---------------------------------------------------------------
  // 💬 WhatsApp
  // ---------------------------------------------------------------
  Future<void> _whatsapp(BuildContext context) async {
    final msg = 'Hola, necesito ayuda con SmartRent+. ¿Me pueden asistir?';
    final uri = Uri.parse(
        'https://wa.me/$_telefonoRaw?text=${Uri.encodeComponent(msg)}');
    final canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _toast(context, 'No se pudo abrir WhatsApp.');
    }
  }

  // ---------------------------------------------------------------
  // 📧 Correo de soporte (forzado a Gmail si existe)
  // ---------------------------------------------------------------
  Future<void> _correoSoporte(BuildContext context) async {
    final subject = Uri.encodeComponent('Asistencia SmartRent+');
    final body = Uri.encodeComponent(
        'Hola equipo de soporte,\n\nNecesito ayuda con:\n\nDetalles:\n\nGracias.\n');
    const correo = _correo;

    try {
      final gmailIntent = Uri(
        scheme: 'mailto',
        path: correo,
        query: 'subject=$subject&body=$body',
      );

      final launched = await launchUrl(
        gmailIntent,
        mode: LaunchMode.externalApplication,
      );

      if (!context.mounted) return;
      if (!launched) {
        final mailtoUri =
            Uri.parse('mailto:$correo?subject=$subject&body=$body');
        final canLaunchMail = await canLaunchUrl(mailtoUri);
        if (!context.mounted) return;
        if (canLaunchMail) {
          await launchUrl(mailtoUri);
        } else {
          _toast(context, 'No se pudo abrir Gmail ni el cliente de correo.');
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      _toast(context, 'Error al abrir correo: $e');
    }
  }

  // ---------------------------------------------------------------
  // 🎨 UI
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const titleStyle = TextStyle(fontWeight: FontWeight.w800, fontSize: 20);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Contacto'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FB), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔹 Encabezado con ícono
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withAlpha(30), // ✅ reemplazo moderno
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Cómo desea contactar?',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text('Seleccione el medio de contacto que prefiera.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Opciones de contacto
            _ContactOption(
              icon: Icons.phone_rounded,
              title: 'Llamar a soporte',
              subtitle: _telefonoPretty,
              color: Colors.indigo,
              onTap: () => _llamar(context),
            ),
            _ContactOption(
              faIcon: FontAwesomeIcons.whatsapp,
              title: 'Contactar por WhatsApp',
              subtitle: 'Chatear con soporte',
              color: Colors.green,
              onTap: () => _whatsapp(context),
            ),
            _ContactOption(
              icon: Icons.email_rounded,
              title: 'Enviar correo',
              subtitle: _correo,
              color: Colors.deepPurple,
              onTap: () => _correoSoporte(context),
            ),

            const SizedBox(height: 8),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 8),

            Text('Horario de atención', style: titleStyle),
            const SizedBox(height: 6),
            Text(
              'Lunes a Viernes, 09:00 a 18:00 hrs (GMT-3).',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            Text('Tiempo de respuesta promedio', style: titleStyle),
            const SizedBox(height: 6),
            Text(
              'Respondemos la mayoría de los casos dentro de 24–48 horas hábiles.',
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'SmartRent+ © 2025',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 💬 Widget reutilizable para las opciones
// ===============================================================
class _ContactOption extends StatelessWidget {
  final IconData? icon;
  final IconData? faIcon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactOption({
    this.icon,
    this.faIcon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shadowColor: color.withAlpha(40), // ✅ sin deprecated
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withAlpha(25), // ✅ reemplazo moderno
                  borderRadius: BorderRadius.circular(12),
                ),
                child: faIcon != null
                    ? Center(child: FaIcon(faIcon, color: color))
                    : Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
