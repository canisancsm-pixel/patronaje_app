import 'package:flutter/material.dart';
import '../models/medidas.dart';
import '../engines/pdf_engine.dart';
import '../engines/a4_layout_engine.dart';
import '../engines/patronaje_engine.dart';

class ExportarPDFScreen extends StatefulWidget {
  final Medidas medidas;
  final String prendaSeleccionada;

  const ExportarPDFScreen({
    super.key,
    required this.medidas,
    required this.prendaSeleccionada,
  });

  @override
  State<ExportarPDFScreen> createState() => _ExportarPDFScreenState();
}

class _ExportarPDFScreenState extends State<ExportarPDFScreen> {
  bool _isGenerating = false;

  Future<void> _generarPDF() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Crear motor de patronaje para calcular los puntos
      final patronajeEngine = PatronajeEngine(
        medidas: widget.medidas,
        prendaSeleccionada: widget.prendaSeleccionada,
      );

      // Calcular el patrón base del cuerpo
      final puntos = patronajeEngine.calculateBodyBasePattern();

      // Crear motor de layout A4 para dividir el patrón en páginas
      final a4LayoutEngine = A4LayoutEngine(
        puntos: puntos,
        canvasSize: const Size(800, 600),
      );

      // Dividir el patrón en páginas A4
      final a4Pages = a4LayoutEngine.splitIntoA4Pages();

      // Crear motor de PDF y generar el documento
      final pdfEngine = PDFEngine(
        a4Pages: a4Pages,
        patternPoints: puntos,
        garmentName: widget.prendaSeleccionada,
        medidas: widget.medidas,
      );

      await pdfEngine.generatePDF();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El PDF ha sido generado correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar PDF')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Prenda: ${widget.prendaSeleccionada}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              'Generar PDF del patrón',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'El PDF se generará con el patrón dividido en páginas A4, incluyendo cuadrícula, marcas de montaje y todas las medidas utilizadas.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generarPDF,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generar PDF', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
