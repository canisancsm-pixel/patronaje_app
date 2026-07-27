import 'package:flutter/material.dart';
import '../models/medidas.dart';
import 'generar_patron_screen.dart';

class PatronajeScreen extends StatelessWidget {
  final String prendaSeleccionada;
  final Medidas medidas;

  const PatronajeScreen({
    super.key,
    required this.prendaSeleccionada,
    required this.medidas,
  });

  @override
  Widget build(BuildContext context) {
    // Navegar directamente a GenerarPatronScreen
    return GenerarPatronScreen(
      medidas: medidas,
      prendaSeleccionada: prendaSeleccionada,
    );
  }
}
