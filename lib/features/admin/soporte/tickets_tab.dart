// ===============================================================
// 🧾 TICKETS TAB – Gestión de reportes y soporte
// ---------------------------------------------------------------
// - Código completo fusionado con tu versión “Seguimiento Mejorado”
// - Incluye imagen, seguimiento, animaciones y CRUD
// ===============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartrent_plus/core/theme/app_theme.dart';
import 'package:smartrent_plus/data/services/api_service.dart';
import 'package:smartrent_plus/data/services/soporte_service.dart';

class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> with TickerProviderStateMixin {
  final _svc = SoporteService(ApiService());
  List<dynamic> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  // ===========================================================
  // 🔹 Cargar tickets desde el backend
  // ===========================================================
  Future<void> _loadTickets() async {
    setState(() => _loading = true);
    try {
      final data = await _svc.fetchAllTickets();
      setState(() => _tickets = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando soporte: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===========================================================
  // 🔹 Mostrar detalle con animación y datos completos
  // ===========================================================
  void _mostrarDetalle(Map t) {
    final estado = t['status'] ?? 'Pendiente';
    final titulo = t['subject'] ?? 'Sin asunto';
    final descripcion = t['description'] ?? 'Sin descripción disponible.';
    final usuario = t['user']?['nombre'] ?? '—';
    final fecha = t['createdAt'] ?? '—';
    final categoria = t['category'] ?? 'General';
    final prioridad = t['prioridad'] ?? 'Normal';
    final seguimiento = t['seguimiento'] ?? 'Sin seguimiento';
    final imagen = t['imageBase64'] ?? t['imagen'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              top: 16,
              left: 18,
              right: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ticket #${t['id'] ?? '-'}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(estado),
                      backgroundColor: _colorEstado(estado),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(titulo.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Divider(height: 25),

                // 🔹 Imagen del reporte
                if (imagen.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 220,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _renderImage(imagen),
                    ),
                  ),

                Text("📂 Categoría: $categoria"),
                Text("⚡ Prioridad: $prioridad"),
                Text("👤 Usuario: $usuario"),
                Text("📅 Fecha: ${_formatearFecha(fecha)}"),
                Text("📋 Seguimiento: $seguimiento"),
                const Divider(height: 25),

                Text(descripcion,
                    style:
                        const TextStyle(fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 20),

                if ((t['respuesta'] ?? '').isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.reply, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(t['respuesta'],
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 25),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.reply),
                      label: const Text('Responder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _abrirRespuesta(t);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Resolver'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () async {
                        await _svc
                            .updateTicket(t['id'], {'status': 'Resuelto'});
                        if (!mounted) return;
                        Navigator.pop(context);
                        _loadTickets();
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        final confirm = await _confirmarEliminar();
                        if (confirm) {
                          await _svc.deleteTicket(t['id']);
                          if (!mounted) return;
                          Navigator.pop(context);
                          _loadTickets();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ticket eliminado con éxito')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _renderImage(String imagen) {
    try {
      if (imagen.startsWith('data:image')) {
        return Image.memory(
          base64Decode(imagen.split(',').last),
          fit: BoxFit.cover,
        );
      } else if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(imagen)) {
        return Image.memory(base64Decode(imagen), fit: BoxFit.cover);
      } else {
        return Image.network(imagen,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image, size: 60)));
      }
    } catch (_) {
      return const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey));
    }
  }

  // ===========================================================
  // 🔹 Modal moderno para responder ticket
  // ===========================================================
  void _abrirRespuesta(Map t) {
    final ctrlRespuesta = TextEditingController(text: t['respuesta'] ?? '');
    String seguimiento = t['seguimiento'] ?? 'Sin seguimiento';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Responder Ticket #${t['id']}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrlRespuesta,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu respuesta aquí...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Seguimiento del caso
              DropdownButtonFormField<String>(
                value: seguimiento,
                decoration: InputDecoration(
                  labelText: 'Seguimiento del caso',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Sin seguimiento', child: Text('Sin seguimiento')),
                  DropdownMenuItem(
                      value: 'Usuario conforme',
                      child: Text('Usuario conforme')),
                  DropdownMenuItem(
                      value: 'Requiere seguimiento',
                      child: Text('Requiere seguimiento')),
                ],
                onChanged: (v) => seguimiento = v ?? 'Sin seguimiento',
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text('Enviar',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor),
                    onPressed: () async {
                      await _svc.updateTicket(t['id'], {
                        'respuesta': ctrlRespuesta.text.trim(),
                        'status': 'En proceso',
                        'seguimiento': seguimiento,
                      });
                      if (!mounted) return;
                      Navigator.pop(context);
                      _loadTickets();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Respuesta enviada')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================
  // 🔹 Confirmar eliminación
  // ===========================================================
  Future<bool> _confirmarEliminar() async {
    bool eliminar = false;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar ticket'),
        content: const Text('¿Seguro que deseas eliminar este ticket?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                eliminar = true;
                Navigator.pop(context);
              },
              child: const Text('Eliminar')),
        ],
      ),
    );
    return eliminar;
  }

  // ===========================================================
  // 🔹 Helpers visuales
  // ===========================================================
  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return '—';
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(fecha));
    } catch (_) {
      return '—';
    }
  }

  Color _colorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'resuelto':
        return Colors.green.shade100;
      case 'en proceso':
        return Colors.amber.shade100;
      default:
        return Colors.red.shade100;
    }
  }

  // ===========================================================
  // 🔹 UI principal
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadTickets,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _tickets.length,
              itemBuilder: (_, i) {
                final t = _tickets[i];
                final estado = t['status'] ?? 'Pendiente';
                final animController = AnimationController(
                  vsync: this,
                  duration: const Duration(milliseconds: 400),
                )..forward();

                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animController,
                    curve: Curves.easeIn,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: animController, curve: Curves.easeOut)),
                    child: Card(
                      color: _colorEstado(estado),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: const Icon(Icons.support_agent, size: 30),
                        title: Text(
                          (t['subject'] ?? 'Sin asunto')
                              .toString()
                              .toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Text('Estado: $estado'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () => _mostrarDetalle(t),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
