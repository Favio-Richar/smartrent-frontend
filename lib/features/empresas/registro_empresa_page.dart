import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../data/models/company_model.dart';
import '../../../data/providers/company_provider.dart';

class RegistroEmpresaPage extends StatefulWidget {
  const RegistroEmpresaPage({super.key});

  @override
  State<RegistroEmpresaPage> createState() => _RegistroEmpresaPageState();
}

class _RegistroEmpresaPageState extends State<RegistroEmpresaPage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreEmpresaCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _sitioWebCtrl = TextEditingController(); // ✅ campo nuevo
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _rutCtrl = TextEditingController();
  final _dvCtrl = TextEditingController();
  final _encargadoCtrl = TextEditingController();
  final _duenoCtrl = TextEditingController();

  TimeOfDay? _horaApertura;
  TimeOfDay? _horaCierre;
  List<String> _diasSeleccionados = [];
  bool _permitirTodosLosDias = false;
  File? _imagenSeleccionada;
  final _picker = ImagePicker();
  final int _userId = 1;

  Future<void> _seleccionarImagen() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagenSeleccionada = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "Registrar Empresa",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 📸 Imagen
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _seleccionarImagen,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: _imagenSeleccionada != null
                                  ? FileImage(_imagenSeleccionada!)
                                  : null,
                              child: _imagenSeleccionada == null
                                  ? const Icon(Icons.add_a_photo,
                                      size: 38, color: Colors.blue)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 18),

                          _buildTextField(
                            _nombreEmpresaCtrl,
                            'Nombre de la empresa',
                            Icons.business,
                          ),
                          _buildTextField(
                            _correoCtrl,
                            'Correo electrónico',
                            Icons.email,
                            type: TextInputType.emailAddress,
                          ),

                          // 🌐 Sitio web (nuevo campo)
                          _buildTextField(
                            _sitioWebCtrl,
                            'Sitio web (opcional)',
                            Icons.link,
                            type: TextInputType.url,
                            validator: (value) {
                              if (value == null || value.isEmpty) return null;
                              final uri = Uri.tryParse(value);
                              if (uri == null || !uri.isAbsolute) {
                                return 'Ingrese una URL válida (ej: https://example.com)';
                              }
                              return null;
                            },
                          ),

                          _buildTextField(
                            _telefonoCtrl,
                            'Teléfono (9 dígitos)',
                            Icons.phone,
                            type: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                          ),
                          _buildTextField(
                            _direccionCtrl,
                            'Dirección',
                            Icons.location_on,
                          ),
                          _buildTextField(
                            _descripcionCtrl,
                            'Descripción breve',
                            Icons.description,
                            maxLines: 3,
                          ),

                          // RUT + DV
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildTextField(
                                  _rutCtrl,
                                  'RUT empresa (sin dígito)',
                                  Icons.badge,
                                  type: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                    LengthLimitingTextInputFormatter(8),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _dvCtrl,
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9kK]')),
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    labelText: 'DV',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          _buildTextField(_encargadoCtrl, 'Encargado',
                              Icons.person_outline),
                          _buildTextField(_duenoCtrl, 'Dueño o representante',
                              Icons.person),

                          const SizedBox(height: 16),
                          _buildHorarioSelector(),
                          const SizedBox(height: 24),
                          _buildSubmitButton(context),
                        ],
                      ),
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

  // ------------------- WIDGETS -------------------

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: validator ??
            (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildHorarioSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.schedule, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Horario de atención',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildTimeBox(
                      label: 'Apertura', time: _horaApertura, isStart: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTimeBox(
                      label: 'Cierre', time: _horaCierre, isStart: false)),
            ],
          ),
          const SizedBox(height: 20),
          _buildDiasCalendario(),
        ],
      ),
    );
  }

  Widget _buildTimeBox({
    required String label,
    required TimeOfDay? time,
    required bool isStart,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            if (isStart) {
              _horaApertura = picked;
            } else {
              _horaCierre = picked;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black87)),
            Text(
              time != null ? time.format(context) : '--:--',
              style: TextStyle(
                  color: Colors.blue.shade700, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiasCalendario() {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Row(
          children: const [
            Icon(Icons.calendar_month, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('Días de operación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dias.map((dia) {
                  final esLaboral = _permitirTodosLosDias ||
                      ['Lun', 'Mar', 'Mié', 'Jue'].contains(dia);
                  final selected = _diasSeleccionados.contains(dia);

                  return GestureDetector(
                    onTap: () {
                      if (!esLaboral) return;
                      setState(() {
                        if (selected) {
                          _diasSeleccionados.remove(dia);
                        } else {
                          _diasSeleccionados.add(dia);
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          dia,
                          style: TextStyle(
                            color: esLaboral ? Colors.black87 : Colors.grey,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? Colors.blue.shade700
                                : (esLaboral
                                    ? Colors.grey.shade200
                                    : Colors.transparent),
                            border: Border.all(
                                color: esLaboral
                                    ? Colors.blue.shade400
                                    : Colors.grey.shade300,
                                width: 1.2),
                          ),
                          child: Icon(
                            selected
                                ? Icons.check
                                : (esLaboral
                                    ? Icons.circle_outlined
                                    : Icons.block),
                            color: selected
                                ? Colors.white
                                : (esLaboral
                                    ? Colors.blue.shade300
                                    : Colors.redAccent),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _permitirTodosLosDias,
                    activeColor: Colors.blue.shade700,
                    onChanged: (value) async {
                      if (value == true) {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.amber.shade700),
                                const SizedBox(width: 8),
                                const Text('¿Estás seguro?'),
                              ],
                            ),
                            content: const Text(
                                'Si habilitas esta opción, podrán contactarte todos los días, incluyendo fines de semana.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Confirmar'),
                              ),
                            ],
                          ),
                        );
                        if (confirmar == true) {
                          setState(() => _permitirTodosLosDias = true);
                        }
                      } else {
                        setState(() {
                          _permitirTodosLosDias = false;
                          _diasSeleccionados.removeWhere(
                              (d) => ['Vie', 'Sáb', 'Dom'].contains(d));
                        });
                      }
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Permitir ser contactado todos los días',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _permitirTodosLosDias
                    ? 'Todos los días habilitados.'
                    : 'Solo lunes a jueves disponibles.',
                style: TextStyle(
                    fontSize: 13,
                    color: _permitirTodosLosDias
                        ? Colors.blue.shade700
                        : Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: _onSubmit,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: const Text(
          'Registrar Empresa',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_horaApertura == null ||
        _horaCierre == null ||
        _diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa horario y días.')));
      return;
    }

    final provider = Provider.of<CompanyProvider>(context, listen: false);
    final company = Company(
      nombreEmpresa: _nombreEmpresaCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      rutEmpresa: "${_rutCtrl.text.trim()}-${_dvCtrl.text.trim()}",
      encargado: _encargadoCtrl.text.trim(),
      dueno: _duenoCtrl.text.trim(),
      horaApertura: _horaApertura?.format(context),
      horaCierre: _horaCierre?.format(context),
      diasOperacion: _diasSeleccionados,
      userId: _userId,
      logo: _imagenSeleccionada?.path,
      sitioWeb: _sitioWebCtrl.text.trim(), // ✅ Envío al backend
    );

    final success = await provider.registerCompany(company);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Empresa registrada correctamente')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error al registrar la empresa')));
    }
  }
}
