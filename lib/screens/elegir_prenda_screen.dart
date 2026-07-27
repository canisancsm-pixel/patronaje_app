import 'package:flutter/material.dart';
import 'patronaje_screen.dart';
import '../models/medidas.dart';
import 'disenar_desde_imagen_screen.dart';

class ElegirPrendaScreen extends StatelessWidget {
  final Medidas medidas;

  const ElegirPrendaScreen({super.key, required this.medidas});

  // Lista de prendas disponibles
  final List<String> _prendas = const [
    'Blusa',
    'Falda',
    'Pantalón',
    'Vestido',
    'Manga (solo la pieza de manga)',
    'Cuerpo base (solo el torso)',
  ];

  void _navegarAPatronaje(BuildContext context, String prenda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PatronajeScreen(prendaSeleccionada: prenda, medidas: medidas),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elegir Prenda')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _prendas.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.add_photo_alternate_outlined),
                  title: const Text(
                    'Diseñar desde imagen',
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: const Text(
                    'Sube una referencia y prepara sus características',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DisenarDesdeImagenScreen(medidas: medidas),
                    ),
                  ),
                ),
              );
            }

            final prenda = _prendas[index - 1];
            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 2,
              child: ListTile(
                title: Text(prenda, style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navegarAPatronaje(context, prenda),
              ),
            );
          },
        ),
      ),
    );
  }
}
