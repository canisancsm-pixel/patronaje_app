import 'package:flutter/material.dart';
import '../models/medidas.dart';
import '../models/measurements_model.dart';
import '../storage/measurements_storage.dart';

class GuardarMedidasScreen extends StatefulWidget {
  final Medidas medidas;

  const GuardarMedidasScreen({super.key, required this.medidas});

  @override
  State<GuardarMedidasScreen> createState() => _GuardarMedidasScreenState();
}

class _GuardarMedidasScreenState extends State<GuardarMedidasScreen> {
  final TextEditingController _nombrePerfilController = TextEditingController();
  final MeasurementsStorage _storage = MeasurementsStorage();
  bool _isSaving = false;

  @override
  void dispose() {
    _nombrePerfilController.dispose();
    super.dispose();
  }

  Future<void> _guardarMedidas() async {
    final nombrePerfil = _nombrePerfilController.text.trim();

    if (nombrePerfil.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un nombre para el perfil'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Crear modelo de medidas desde las medidas actuales
      final model = MeasurementsModel(
        cuello: widget.medidas.contornoCuello,
        busto: widget.medidas.contornoBusto,
        cintura: widget.medidas.contornoCintura,
        cadera: widget.medidas.contornoCadera,
        sisa: widget.medidas.contornoSisa,
        puno: widget.medidas.contornoPuno,
        manga: widget.medidas.contornoManga,
        rodilla: widget.medidas.contornoRodilla,
        tobillo: widget.medidas.contornoTobillo,
        largoTalle: widget.medidas.largoTalle,
        largoBusto: widget.medidas.largoBusto,
        largoBlusa: widget.medidas.largoBlusa,
        largoCodo: widget.medidas.largoCodo,
        largoMangaCorta: widget.medidas.largoMangaCorta,
        largoManga34: widget.medidas.largoManga34,
        largoEscoteDelantero: widget.medidas.largoEscoteDelantero,
        largoEscoteEspalda: widget.medidas.largoEscoteEspalda,
        largoCadera: widget.medidas.largoCadera,
        largoFalda: widget.medidas.largoFalda,
        largoPantalon: widget.medidas.largoPantalon,
        largoTiro: widget.medidas.largoTiro,
        caidaBusto: widget.medidas.caidaBusto,
        separacionBusto: widget.medidas.separacionBusto,
        anchoPecho: widget.medidas.anchoPecho,
        anchoHombros: widget.medidas.anchoHombros,
        anchoEspalda: widget.medidas.anchoEspalda,
      );

      // Guardar las medidas en SharedPreferences
      await _storage.saveMeasurements(nombrePerfil, model);

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medidas guardadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar el campo de texto
        _nombrePerfilController.clear();
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar medidas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardar Medidas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Guardar perfil de medidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nombrePerfilController,
              decoration: const InputDecoration(
                labelText: 'Nombre del perfil',
                hintText: 'Ej: Mi perfil estándar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            const Text(
              'Las medidas se guardarán con este nombre para poder cargarlas posteriormente.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _guardarMedidas,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Guardar medidas',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
