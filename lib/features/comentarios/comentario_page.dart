import 'package:flutter/material.dart';
import 'package:smartrent_plus/data/services/comentarios_service.dart';

class ComentarPage extends StatefulWidget {
  const ComentarPage({super.key});

  @override
  State<ComentarPage> createState() => _ComentarPageState();
}

class _ComentarPageState extends State<ComentarPage> {
  final TextEditingController controller = TextEditingController();
  bool enviando = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final int id = args["id"];
    final String titulo = args["titulo"] ?? "Publicación";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comentar"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Escribe tu comentario...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: enviando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Enviar comentario"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final texto = controller.text.trim();
                        if (texto.isEmpty) return;

                        setState(() => enviando = true);

                        final ok = await ComentariosService.agregarComentario(
                          id,
                          texto,
                        );

                        setState(() => enviando = false);

                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Error al enviar comentario"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context, true);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
