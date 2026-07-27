import 'package:flutter/material.dart';
import '../models/medidas.dart';
import '../engines/patronaje_engine.dart';
import '../painters/body_base_painter.dart';
import 'exportar_pdf_screen.dart';

class GenerarPatronScreen extends StatefulWidget {
  final Medidas medidas;
  final String prendaSeleccionada;

  const GenerarPatronScreen({
    super.key,
    required this.medidas,
    required this.prendaSeleccionada,
  });

  @override
  State<GenerarPatronScreen> createState() => _GenerarPatronScreenState();
}

class _GenerarPatronScreenState extends State<GenerarPatronScreen> {
  // Almacenar los puntos del patrón calculados
  Map<String, PatternPoint>? _puntosPatron;

  // Controlador de transformación para el InteractiveViewer
  // Permite controlar el zoom y la posición del canvas
  final TransformationController _transformationController =
      TransformationController();

  void _calcularPatron() {
    try {
      final engine = PatronajeEngine(
        medidas: widget.medidas,
        prendaSeleccionada: widget.prendaSeleccionada,
      );
      final puntos = engine.calculatePattern();

      if (puntos.isEmpty ||
          puntos.values.any(
            (punto) => !punto.x.isFinite || !punto.y.isFinite,
          )) {
        throw StateError('El motor no generó un patrón válido.');
      }

      setState(() {
        _puntosPatron = Map<String, PatternPoint>.unmodifiable(puntos);
        _transformationController.value = Matrix4.identity();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patrón calculado: ${puntos.length} puntos generados'),
          backgroundColor: Colors.green,
        ),
      );
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message?.toString() ?? 'Faltan medidas válidas.'),
          backgroundColor: Colors.red,
        ),
      );
    } on StateError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo calcular el patrón: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportarPDF() {
    // Navegar a ExportarPDFScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExportarPDFScreen(
          medidas: widget.medidas,
          prendaSeleccionada: widget.prendaSeleccionada,
        ),
      ),
    );
  }

  // Función para restablecer la vista a su estado inicial
  // Vuelve el zoom a 1.0 y centra el canvas
  void _restablecerVista() {
    // Resetear la transformación a la identidad (sin zoom, sin desplazamiento)
    _transformationController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    // Liberar el controlador de transformación al destruir el widget
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Patrón')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título con la prenda seleccionada
            Text(
              'Generación del patrón para: ${widget.prendaSeleccionada}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Botón para restablecer la vista
            ElevatedButton.icon(
              onPressed: _restablecerVista,
              icon: const Icon(Icons.refresh),
              label: const Text('Restablecer vista'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 16),

            // Área para dibujar el patrón con InteractiveViewer y CustomPaint
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: _puntosPatron != null
                    ? InteractiveViewer(
                        // Controlador de transformación para controlar zoom y posición
                        transformationController: _transformationController,
                        // Escala mínima permitida (50% del tamaño original)
                        minScale: 0.5,
                        // Escala máxima permitida (400% del tamaño original)
                        maxScale: 4.0,
                        // Margen alrededor del contenido para permitir desplazamiento
                        boundaryMargin: const EdgeInsets.all(200),
                        // Habilitar desplazamiento con gestos de arrastre
                        panEnabled: true,
                        // Habilitar zoom con gestos de pellizcado
                        scaleEnabled: true,
                        // Contenido que se puede hacer zoom y desplazar
                        child: CustomPaint(
                          painter: BodyBasePainter(puntos: _puntosPatron!),
                          child: const SizedBox.expand(),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Pulsa "Calcular patrón" para ver el dibujo',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón Calcular patrón
            ElevatedButton(
              onPressed: _calcularPatron,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Calcular patrón',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            // Botón Exportar PDF
            ElevatedButton(
              onPressed: _exportarPDF,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Exportar PDF', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
