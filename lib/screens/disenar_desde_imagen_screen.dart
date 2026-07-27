import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/medidas.dart';
import 'generar_patron_screen.dart';

class DisenoDesdeImagenResult {
  final XFile imagen;
  final String prendaDetectada;
  final String varianteDetectada;
  final String estiloDetectado;

  const DisenoDesdeImagenResult({
    required this.imagen,
    required this.prendaDetectada,
    required this.varianteDetectada,
    required this.estiloDetectado,
  });
}

class DisenarDesdeImagenScreen extends StatefulWidget {
  final Medidas medidas;
  final ValueChanged<DisenoDesdeImagenResult>? onResultado;

  const DisenarDesdeImagenScreen({
    super.key,
    required this.medidas,
    this.onResultado,
  });

  @override
  State<DisenarDesdeImagenScreen> createState() =>
      _DisenarDesdeImagenScreenState();
}

class _DisenarDesdeImagenScreenState extends State<DisenarDesdeImagenScreen> {
  static const _prendas = <String>[
    'Blusa',
    'Falda',
    'Pantalón',
    'Vestido',
    'Manga (solo la pieza de manga)',
    'Cuerpo base (solo el torso)',
  ];

  static const _variantes = <String>[
    'Básica',
    'Entallada',
    'Holgada',
    'Corta',
    'Larga',
  ];

  static const _estilos = <String>[
    'Clásico',
    'Casual',
    'Formal',
    'Deportivo',
    'Minimalista',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _imagen;
  Uint8List? _imagenBytes;
  String? _prendaDetectada;
  String? _varianteDetectada;
  String? _estiloDetectado;
  DisenoDesdeImagenResult? _resultado;
  bool _cargandoImagen = false;

  Future<void> _subirImagen() async {
    setState(() {
      _cargandoImagen = true;
    });

    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (imagen == null) {
        return;
      }

      final bytes = await imagen.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _imagen = imagen;
        _imagenBytes = bytes;
        _prendaDetectada = null;
        _varianteDetectada = null;
        _estiloDetectado = null;
        _resultado = null;
      });
    } catch (error) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir la imagen: $error', esError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargandoImagen = false;
        });
      }
    }
  }

  Future<String?> _seleccionarOpcion({
    required String titulo,
    required List<String> opciones,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                titulo,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final opcion in opciones)
                    ListTile(
                      title: Text(opcion),
                      onTap: () => Navigator.pop(context, opcion),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _comprobarImagen() {
    if (_imagen != null) {
      return true;
    }

    _mostrarMensaje(
      'Primero debes subir una imagen de la prenda.',
      esError: true,
    );
    return false;
  }

  Future<void> _detectarPrenda() async {
    if (!_comprobarImagen()) {
      return;
    }

    final seleccion = await _seleccionarOpcion(
      titulo: 'Confirmar prenda detectada',
      opciones: _prendas,
    );
    if (seleccion != null && mounted) {
      setState(() {
        _prendaDetectada = seleccion;
        _resultado = null;
      });
    }
  }

  Future<void> _detectarVariante() async {
    if (!_comprobarImagen()) {
      return;
    }

    final seleccion = await _seleccionarOpcion(
      titulo: 'Confirmar variante detectada',
      opciones: _variantes,
    );
    if (seleccion != null && mounted) {
      setState(() {
        _varianteDetectada = seleccion;
        _resultado = null;
      });
    }
  }

  Future<void> _detectarEstilo() async {
    if (!_comprobarImagen()) {
      return;
    }

    final seleccion = await _seleccionarOpcion(
      titulo: 'Confirmar estilo detectado',
      opciones: _estilos,
    );
    if (seleccion != null && mounted) {
      setState(() {
        _estiloDetectado = seleccion;
        _resultado = null;
      });
    }
  }

  DisenoDesdeImagenResult? _generarPatronDesdeImagen() {
    final imagen = _imagen;
    final prenda = _prendaDetectada;
    final variante = _varianteDetectada;
    final estilo = _estiloDetectado;

    if (imagen == null ||
        prenda == null ||
        variante == null ||
        estilo == null) {
      _mostrarMensaje(
        'Sube una imagen y completa la detección de prenda, variante y estilo.',
        esError: true,
      );
      return null;
    }

    final resultado = DisenoDesdeImagenResult(
      imagen: imagen,
      prendaDetectada: prenda,
      varianteDetectada: variante,
      estiloDetectado: estilo,
    );

    setState(() {
      _resultado = resultado;
    });
    widget.onResultado?.call(resultado);
    _mostrarMensaje('Datos de la imagen preparados para generar el patrón.');
    return resultado;
  }

  void _continuarAGenerarPatron() {
    final resultado = _resultado ?? _generarPatronDesdeImagen();
    if (resultado == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenerarPatronScreen(
          medidas: widget.medidas,
          prendaSeleccionada: resultado.prendaDetectada,
        ),
      ),
    );
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: esError ? Colors.red : Colors.green,
        ),
      );
  }

  Widget _botonDeteccion({
    required String texto,
    required String? valor,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: _imagen == null ? null : onPressed,
      icon: Icon(valor == null ? Icons.search : Icons.check_circle),
      label: Text(valor == null ? texto : '$texto: $valor'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diseñar desde imagen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: _cargandoImagen ? null : _subirImagen,
              icon: _cargandoImagen
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: const Text('Subir imagen'),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _imagenBytes == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined, size: 56),
                              SizedBox(height: 8),
                              Text('Vista previa de la imagen'),
                            ],
                          ),
                        )
                      : Image.memory(
                          _imagenBytes!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _botonDeteccion(
              texto: 'Detectar prenda',
              valor: _prendaDetectada,
              onPressed: _detectarPrenda,
            ),
            const SizedBox(height: 8),
            _botonDeteccion(
              texto: 'Detectar variante',
              valor: _varianteDetectada,
              onPressed: _detectarVariante,
            ),
            const SizedBox(height: 8),
            _botonDeteccion(
              texto: 'Detectar estilo',
              valor: _estiloDetectado,
              onPressed: _detectarEstilo,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _generarPatronDesdeImagen,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar patrón desde imagen'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _continuarAGenerarPatron,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuar a Generar Patrón'),
            ),
          ],
        ),
      ),
    );
  }
}
