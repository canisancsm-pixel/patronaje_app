import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../engines/a4_layout_engine.dart';
import '../engines/patronaje_engine.dart';
import '../models/medidas.dart';
import '../services/historial_service.dart';

String _asciiSafe(String value) {
  const replacements = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
    'Ü': 'U',
    'Ñ': 'N',
    '—': '_',
    '–': '_',
    ':': '_',
  };

  var result = value;
  for (final replacement in replacements.entries) {
    result = result.replaceAll(replacement.key, replacement.value);
  }

  return result
      .replaceAll(RegExp(r'\s+'), '_')
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

/// Genera un documento PDF con el patrón dividido en páginas A4.
class PDFEngine {
  final List<A4Page> a4Pages;
  final Map<String, PatternPoint> patternPoints;
  final String garmentName;
  final Medidas medidas;

  const PDFEngine({
    required this.a4Pages,
    required this.patternPoints,
    required this.garmentName,
    required this.medidas,
  });

  String get fileName => 'Patron_${_asciiSafe(garmentName)}_Escala_1_1.pdf';

  Future<Uint8List> generatePDF() async {
    final safeGarmentName = _asciiSafe(garmentName);
    final safeTitle = 'Patron_${safeGarmentName}_Escala_1_1';
    final pdf = pw.Document(
      title: safeTitle,
      subject: safeTitle,
      creator: 'Patronaje_App',
    );
    final regularFont = PdfFont.helvetica(pdf.document);
    final boldFont = PdfFont.helveticaBold(pdf.document);

    for (final a4Page in a4Pages) {
      final painter = PDFPainter(
        a4Page: a4Page,
        patternPoints: patternPoints,
        garmentName: safeGarmentName,
        medidas: medidas,
        currentPage: a4Page.pageNumber,
        totalPages: a4Pages.length,
        regularFont: regularFont,
        boldFont: boldFont,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) => pw.CustomPaint(
            size: PdfPoint(PdfPageFormat.a4.width, PdfPageFormat.a4.height),
            painter: painter.paint,
          ),
        ),
      );
    }

    // BLOQUE DEL HISTORIAL
    final bytes = await pdf.save();

    final registro = {
      "filePath": fileName,
      "prenda": garmentName,
      "variante": garmentName,
      "fecha": DateTime.now().toIso8601String(),
    };

    await HistorialService().agregarRegistro(registro);

    return bytes;
  }
}

/// Dibuja todo el contenido vectorial de una página A4.
///
/// En el paquete `pdf`, [pw.CustomPaint] usa un callback que recibe
/// [PdfGraphics] y [PdfPoint], equivalentes al canvas y al tamaño de Flutter.
class PDFPainter {
  static const double _margin = 36;
  static const double _gridSize = 180;
  static const double _patternOffset = 50;

  final A4Page a4Page;
  final Map<String, PatternPoint> patternPoints;
  final String garmentName;
  final Medidas medidas;
  final int currentPage;
  final int totalPages;
  final PdfFont regularFont;
  final PdfFont boldFont;

  const PDFPainter({
    required this.a4Page,
    required this.patternPoints,
    required this.garmentName,
    required this.medidas,
    required this.currentPage,
    required this.totalPages,
    required this.regularFont,
    required this.boldFont,
  });

  void paint(PdfGraphics canvas, PdfPoint size) {
    _drawMargin(canvas, size);
    _drawGrid(canvas, size);
    _drawMountingMarks(canvas, size);

    if (currentPage == 1) {
      _drawTitle(canvas, size);
      _drawMeasurementsInfo(canvas, size);
    }

    _drawPattern(canvas, size);
    _drawPageNumber(canvas, size);
  }

  void _drawMargin(PdfGraphics canvas, PdfPoint size) {
    canvas
      ..setStrokeColor(PdfColors.grey300)
      ..setLineWidth(1)
      ..drawRect(
        _margin,
        _margin,
        size.x - (_margin * 2),
        size.y - (_margin * 2),
      )
      ..strokePath();
  }

  void _drawGrid(PdfGraphics canvas, PdfPoint size) {
    canvas
      ..setStrokeColor(PdfColors.grey300)
      ..setLineWidth(0.5);

    for (double x = _margin; x <= size.x - _margin; x += _gridSize) {
      _drawLineFromTop(canvas, size, x, _margin, x, size.y - _margin);
    }

    for (double y = _margin; y <= size.y - _margin; y += _gridSize) {
      _drawLineFromTop(canvas, size, _margin, y, size.x - _margin, y);
    }
  }

  void _drawMountingMarks(PdfGraphics canvas, PdfPoint size) {
    canvas
      ..setStrokeColor(PdfColors.black)
      ..setLineWidth(2);

    final horizontalMarks = <double>[
      _margin + 50,
      size.x / 2,
      size.x - _margin - 50,
    ];
    for (final x in horizontalMarks) {
      _drawLineFromTop(canvas, size, x, _margin - 10, x, _margin + 10);
      _drawLineFromTop(
        canvas,
        size,
        x,
        size.y - _margin - 10,
        x,
        size.y - _margin + 10,
      );
    }

    final verticalMarks = <double>[
      _margin + 50,
      size.y / 2,
      size.y - _margin - 50,
    ];
    for (final y in verticalMarks) {
      _drawLineFromTop(
        canvas,
        size,
        size.x - _margin - 10,
        y,
        size.x - _margin + 10,
        y,
      );
    }
  }

  void _drawTitle(PdfGraphics canvas, PdfPoint size) {
    final title = 'Patron_${garmentName}_Escala_1_1';
    const fontSize = 24.0;
    final textWidth = boldFont.stringMetrics(title).size.x * fontSize;

    _drawTextFromTop(
      canvas,
      size,
      title,
      boldFont,
      fontSize,
      (size.x - textWidth) / 2,
      60,
    );
  }

  void _drawMeasurementsInfo(PdfGraphics canvas, PdfPoint size) {
    final boxX = _margin + 20;
    const boxTop = 100.0;
    final boxWidth = size.x - (_margin * 2) - 40;
    const boxHeight = 200.0;

    canvas
      ..setStrokeColor(PdfColors.black)
      ..setLineWidth(1)
      ..drawRect(boxX, size.y - boxTop - boxHeight, boxWidth, boxHeight)
      ..strokePath();

    _drawTextFromTop(
      canvas,
      size,
      'Medidas utilizadas:',
      boldFont,
      14,
      boxX + 10,
      boxTop + 10,
    );

    final measurements = <String>[
      'Contorno de cuello: ${medidas.contornoCuello} cm',
      'Contorno de busto: ${medidas.contornoBusto} cm',
      'Contorno de cintura: ${medidas.contornoCintura} cm',
      'Contorno de cadera: ${medidas.contornoCadera} cm',
      'Contorno de sisa: ${medidas.contornoSisa} cm',
      'Largo de talle: ${medidas.largoTalle} cm',
      'Largo de busto: ${medidas.largoBusto} cm',
      'Ancho de pecho: ${medidas.anchoPecho} cm',
      'Ancho de espalda: ${medidas.anchoEspalda} cm',
      'Ancho de hombros: ${medidas.anchoHombros} cm',
    ];

    var top = boxTop + 35;
    for (final measurement in measurements) {
      _drawTextFromTop(
        canvas,
        size,
        measurement,
        regularFont,
        10,
        boxX + 10,
        top,
      );
      top += 12;
    }
  }

  void _drawPattern(PdfGraphics canvas, PdfPoint size) {
    _drawPatternLines(canvas, size);

    for (final entry in a4Page.puntos.entries) {
      final point = patternPoints[entry.key] ?? entry.value;
      final x = _margin + _patternOffset + point.x;
      final top = _margin + _patternOffset + point.y;
      final y = size.y - top;

      canvas
        ..setStrokeColor(PdfColors.red)
        ..setLineWidth(3)
        ..drawEllipse(x, y, 3, 3)
        ..strokePath();

      _drawTextFromTop(canvas, size, entry.key, boldFont, 10, x + 8, top - 5);
    }
  }

  void _drawPatternLines(PdfGraphics canvas, PdfPoint size) {
    const straightConnections = <List<String>>[
      ['puntoA', 'puntoB'],
      ['puntoB', 'puntoC'],
      ['puntoC', 'puntoD'],
      ['puntoF', 'puntoB'],
      ['puntoB', 'puntoE'],
      ['puntoA', 'puntoI'],
      ['puntoA', 'puntoJ'],
    ];
    _drawConnections(canvas, size, straightConnections, PdfColors.blue);

    const curveConnections = <List<String>>[
      ['puntoI', 'puntoG'],
      ['puntoG', 'puntoE'],
      ['puntoJ', 'puntoH'],
      ['puntoH', 'puntoF'],
    ];
    _drawConnections(canvas, size, curveConnections, PdfColors.purple);
  }

  void _drawConnections(
    PdfGraphics canvas,
    PdfPoint size,
    List<List<String>> connections,
    PdfColor color,
  ) {
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(2);

    for (final connection in connections) {
      final startPoint = _pointOnPage(connection[0]);
      final endPoint = _pointOnPage(connection[1]);
      if (startPoint == null || endPoint == null) {
        continue;
      }

      _drawLineFromTop(
        canvas,
        size,
        _margin + _patternOffset + startPoint.x,
        _margin + _patternOffset + startPoint.y,
        _margin + _patternOffset + endPoint.x,
        _margin + _patternOffset + endPoint.y,
      );
    }
  }

  PatternPoint? _pointOnPage(String name) {
    if (!a4Page.puntos.containsKey(name)) {
      return null;
    }
    return patternPoints[name] ?? a4Page.puntos[name];
  }

  void _drawPageNumber(PdfGraphics canvas, PdfPoint size) {
    final text = 'Página $currentPage de $totalPages';
    const fontSize = 10.0;
    final textWidth = regularFont.stringMetrics(text).size.x * fontSize;

    _drawTextFromTop(
      canvas,
      size,
      text,
      regularFont,
      fontSize,
      size.x - _margin - textWidth,
      size.y - _margin - 20,
    );
  }

  void _drawLineFromTop(
    PdfGraphics canvas,
    PdfPoint size,
    double x1,
    double top1,
    double x2,
    double top2,
  ) {
    canvas
      ..drawLine(x1, size.y - top1, x2, size.y - top2)
      ..strokePath();
  }

  void _drawTextFromTop(
    PdfGraphics canvas,
    PdfPoint size,
    String text,
    PdfFont font,
    double fontSize,
    double x,
    double top,
  ) {
    canvas
      ..setFillColor(PdfColors.black)
      ..drawString(font, fontSize, text, x, size.y - top - fontSize);
  }
}
