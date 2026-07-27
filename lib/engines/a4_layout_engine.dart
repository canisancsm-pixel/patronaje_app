import 'dart:ui' as ui;
import '../engines/patronaje_engine.dart';

// Clase que representa una página A4 con su contenido
class A4Page {
  final int pageNumber;
  final Map<String, PatternPoint> puntos; // Puntos que pertenecen a esta página
  final double x; // Coordenada X de recorte en el canvas original
  final double y; // Coordenada Y de recorte en el canvas original
  final double width; // Ancho de la página
  final double height; // Alto de la página

  A4Page({
    required this.pageNumber,
    required this.puntos,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

// Motor de diseño para dividir patrones en páginas A4
// Esta clase calcula cómo dividir un patrón grande en múltiples páginas A4
// para que pueda imprimirse o exportarse en PDF
class A4LayoutEngine {
  final Map<String, PatternPoint> puntos;
  final ui.Size canvasSize;

  // Dimensiones estándar de página A4 en milímetros
  static const double a4WidthMm = 210.0;
  static const double a4HeightMm = 297.0;

  // Factor de conversión de milímetros a píxeles (72 DPI estándar)
  static const double mmToPixels = 2.834645669;

  // Dimensiones de página A4 en píxeles
  static final double a4WidthPixels = a4WidthMm * mmToPixels;
  static final double a4HeightPixels = a4HeightMm * mmToPixels;

  // Margen de seguridad en milímetros (para evitar que el dibujo quede en el borde)
  static const double marginMm = 10.0;
  static final double marginPixels = marginMm * mmToPixels;

  A4LayoutEngine({required this.puntos, required this.canvasSize});

  // Calcula el área total que ocupa el patrón
  // Encuentra los valores mínimos y máximos de X y Y entre todos los puntos
  Map<String, double> calculatePatternArea() {
    if (puntos.isEmpty) {
      return {
        'minX': 0,
        'maxX': 0,
        'minY': 0,
        'maxY': 0,
        'width': 0,
        'height': 0,
      };
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    // Recorrer todos los puntos para encontrar los extremos
    for (final punto in puntos.values) {
      if (punto.x < minX) minX = punto.x;
      if (punto.x > maxX) maxX = punto.x;
      if (punto.y < minY) minY = punto.y;
      if (punto.y > maxY) maxY = punto.y;
    }

    final width = maxX - minX;
    final height = maxY - minY;

    return {
      'minX': minX,
      'maxX': maxX,
      'minY': minY,
      'maxY': maxY,
      'width': width,
      'height': height,
    };
  }

  // Calcula el número de páginas A4 necesarias
  // Basado en el área del patrón y las dimensiones de A4
  int calculateRequiredPages(Map<String, double> area) {
    final patternWidth = area['width']!;
    final patternHeight = area['height']!;

    // Calcular cuántas páginas se necesitan horizontal y verticalmente
    // Usamos el área útil de A4 (restando márgenes)
    final usableA4Width = a4WidthPixels - (marginPixels * 2);
    final usableA4Height = a4HeightPixels - (marginPixels * 2);

    final pagesHorizontal = (patternWidth / usableA4Width).ceil().toDouble();
    final pagesVertical = (patternHeight / usableA4Height).ceil().toDouble();

    // Asegurar al menos 1 página en cada dirección
    final finalPagesHorizontal = pagesHorizontal < 1 ? 1 : pagesHorizontal;
    final finalPagesVertical = pagesVertical < 1 ? 1 : pagesVertical;

    return (finalPagesHorizontal * finalPagesVertical).toInt();
  }

  // Función principal que divide el patrón en páginas A4
  // Devuelve una lista de páginas con sus puntos y coordenadas de recorte
  List<A4Page> splitIntoA4Pages() {
    // Calcular el área del patrón
    final area = calculatePatternArea();

    // Calcular cuántas páginas se necesitan
    final totalPages = calculateRequiredPages(area);

    // Si el patrón cabe en una sola página, devolverla completa
    if (totalPages == 1) {
      return [
        A4Page(
          pageNumber: 1,
          puntos: puntos,
          x: area['minX']! - marginPixels,
          y: area['minY']! - marginPixels,
          width: a4WidthPixels,
          height: a4HeightPixels,
        ),
      ];
    }

    // Calcular dimensiones para la cuadrícula de páginas
    final patternWidth = area['width']!;
    final patternHeight = area['height']!;
    final usableA4Width = a4WidthPixels - (marginPixels * 2);
    final usableA4Height = a4HeightPixels - (marginPixels * 2);

    final pagesHorizontal = (patternWidth / usableA4Width).ceil();
    final pagesVertical = (patternHeight / usableA4Height).ceil();

    final List<A4Page> pages = [];
    int pageNumber = 1;

    // Dividir el patrón en una cuadrícula de páginas
    for (int row = 0; row < pagesVertical; row++) {
      for (int col = 0; col < pagesHorizontal; col++) {
        // Calcular las coordenadas de recorte para esta página
        final pageX = area['minX']! + (col * usableA4Width) - marginPixels;
        final pageY = area['minY']! + (row * usableA4Height) - marginPixels;

        // Filtrar los puntos que pertenecen a esta página
        final pagePoints = _filterPointsForPage(
          pageX,
          pageY,
          usableA4Width + (marginPixels * 2),
          usableA4Height + (marginPixels * 2),
        );

        // Crear la página y añadirla a la lista
        pages.add(
          A4Page(
            pageNumber: pageNumber,
            puntos: pagePoints,
            x: pageX,
            y: pageY,
            width: a4WidthPixels,
            height: a4HeightPixels,
          ),
        );

        pageNumber++;
      }
    }

    return pages;
  }

  // Filtra los puntos que pertenecen a una página específica
  // Un punto pertenece a la página si está dentro del área de recorte
  Map<String, PatternPoint> _filterPointsForPage(
    double pageX,
    double pageY,
    double pageWidth,
    double pageHeight,
  ) {
    final Map<String, PatternPoint> filteredPoints = {};

    for (final entry in puntos.entries) {
      final pointName = entry.key;
      final point = entry.value;

      // Verificar si el punto está dentro del área de la página
      // Usamos un pequeño margen para incluir puntos cercanos al borde
      final margin = 5.0; // 5 píxeles de margen

      if (point.x >= pageX - margin &&
          point.x <= pageX + pageWidth + margin &&
          point.y >= pageY - margin &&
          point.y <= pageY + pageHeight + margin) {
        filteredPoints[pointName] = point;
      }
    }

    return filteredPoints;
  }

  // Obtiene información sobre el layout de páginas
  // Útil para mostrar al usuario cuántas páginas se necesitan
  Map<String, dynamic> getLayoutInfo() {
    final area = calculatePatternArea();
    final totalPages = calculateRequiredPages(area);

    return {
      'totalPages': totalPages,
      'patternWidth': area['width'],
      'patternHeight': area['height'],
      'patternWidthMm': area['width']! / mmToPixels,
      'patternHeightMm': area['height']! / mmToPixels,
      'a4WidthMm': a4WidthMm,
      'a4HeightMm': a4HeightMm,
    };
  }
}
