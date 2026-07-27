import 'package:flutter/material.dart';
import '../engines/patronaje_engine.dart';

// CustomPainter para dibujar el patrón base del cuerpo
// Recibe los puntos calculados por PatronajeEngine.calculateBodyBasePattern()
class BodyBasePainter extends CustomPainter {
  final Map<String, PatternPoint> puntos;

  BodyBasePainter({required this.puntos});

  @override
  void paint(Canvas canvas, Size size) {
    if (puntos.isEmpty || size.isEmpty) {
      return;
    }

    final minX = puntos.values
        .map((punto) => punto.x)
        .reduce((value, element) => value < element ? value : element);
    final maxX = puntos.values
        .map((punto) => punto.x)
        .reduce((value, element) => value > element ? value : element);
    final minY = puntos.values
        .map((punto) => punto.y)
        .reduce((value, element) => value < element ? value : element);
    final maxY = puntos.values
        .map((punto) => punto.y)
        .reduce((value, element) => value > element ? value : element);

    const padding = 32.0;
    final patternWidth = (maxX - minX).abs();
    final patternHeight = (maxY - minY).abs();
    final availableWidth = (size.width - padding * 2).clamp(
      1.0,
      double.infinity,
    );
    final availableHeight = (size.height - padding * 2).clamp(
      1.0,
      double.infinity,
    );
    final scaleX = patternWidth == 0 ? 1.0 : availableWidth / patternWidth;
    final scaleY = patternHeight == 0 ? 1.0 : availableHeight / patternHeight;
    final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.1, 10.0);
    final drawingWidth = patternWidth * scale;
    final drawingHeight = patternHeight * scale;

    canvas.save();
    canvas.translate(
      (size.width - drawingWidth) / 2 - minX * scale,
      (size.height - drawingHeight) / 2 - minY * scale,
    );
    canvas.scale(scale);

    // Configurar el paint para las líneas
    final linePaint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Configurar el paint para los puntos
    final pointPaint = Paint()
      ..color = Colors.red[600]!
      ..style = PaintingStyle.fill;

    // Configurar el paint para las curvas
    final curvePaint = Paint()
      ..color = Colors.purple[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Configurar el paint para líneas auxiliares
    final auxiliaryPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Extraer puntos del mapa
    final puntoA = puntos['puntoA']!; // Centro delantero en cuello
    final puntoB = puntos['puntoB']!; // Centro delantero en busto
    final puntoC = puntos['puntoC']!; // Centro delantero en cintura
    final puntoD = puntos['puntoD']!; // Centro delantero en cadera
    final puntoE = puntos['puntoE']!; // Ancho de pecho
    final puntoF = puntos['puntoF']!; // Ancho de espalda
    final puntoG = puntos['puntoG']!; // Sisa delantera
    final puntoH = puntos['puntoH']!; // Sisa espalda
    final puntoI = puntos['puntoI']!; // Hombro delantero
    final puntoJ = puntos['puntoJ']!; // Hombro espalda

    // Dibujar línea vertical del centro delantero (A -> B -> C -> D)
    canvas.drawLine(
      Offset(puntoA.x, puntoA.y),
      Offset(puntoB.x, puntoB.y),
      auxiliaryPaint,
    );
    canvas.drawLine(
      Offset(puntoB.x, puntoB.y),
      Offset(puntoC.x, puntoC.y),
      auxiliaryPaint,
    );
    canvas.drawLine(
      Offset(puntoC.x, puntoC.y),
      Offset(puntoD.x, puntoD.y),
      auxiliaryPaint,
    );

    // Dibujar línea horizontal de busto (F -> B -> E)
    canvas.drawLine(
      Offset(puntoF.x, puntoF.y),
      Offset(puntoB.x, puntoB.y),
      linePaint,
    );
    canvas.drawLine(
      Offset(puntoB.x, puntoB.y),
      Offset(puntoE.x, puntoE.y),
      linePaint,
    );

    // Dibujar línea horizontal de cintura (proyectada desde C)
    final cinturaIzquierda = Offset(puntoF.x, puntoC.y);
    final cinturaDerecha = Offset(puntoE.x, puntoC.y);
    canvas.drawLine(cinturaIzquierda, cinturaDerecha, linePaint);

    // Dibujar línea horizontal de cadera (proyectada desde D)
    final caderaIzquierda = Offset(puntoF.x, puntoD.y);
    final caderaDerecha = Offset(puntoE.x, puntoD.y);
    canvas.drawLine(caderaIzquierda, caderaDerecha, linePaint);

    // Dibujar línea del hombro delantero (A -> I)
    canvas.drawLine(
      Offset(puntoA.x, puntoA.y),
      Offset(puntoI.x, puntoI.y),
      linePaint,
    );

    // Dibujar línea del hombro espalda (A -> J)
    canvas.drawLine(
      Offset(puntoA.x, puntoA.y),
      Offset(puntoJ.x, puntoJ.y),
      linePaint,
    );

    // Dibujar curva básica de sisa delantera (I -> G -> E)
    final sisaDelanteraPath = Path()
      ..moveTo(puntoI.x, puntoI.y)
      ..quadraticBezierTo(
        puntoI.x + (puntoG.x - puntoI.x) / 2,
        puntoI.y,
        puntoG.x,
        puntoG.y,
      )
      ..quadraticBezierTo(
        puntoG.x + (puntoE.x - puntoG.x) / 2,
        puntoG.y,
        puntoE.x,
        puntoE.y,
      );
    canvas.drawPath(sisaDelanteraPath, curvePaint);

    // Dibujar curva básica de sisa espalda (J -> H -> F)
    final sisaEspaldaPath = Path()
      ..moveTo(puntoJ.x, puntoJ.y)
      ..quadraticBezierTo(
        puntoJ.x + (puntoH.x - puntoJ.x) / 2,
        puntoJ.y,
        puntoH.x,
        puntoH.y,
      )
      ..quadraticBezierTo(
        puntoH.x + (puntoF.x - puntoH.x) / 2,
        puntoH.y,
        puntoF.x,
        puntoF.y,
      );
    canvas.drawPath(sisaEspaldaPath, curvePaint);

    // Dibujar escote delantero (curva suave desde A hacia abajo)
    final escoteDelanteroPath = Path()
      ..moveTo(puntoA.x, puntoA.y)
      ..quadraticBezierTo(puntoA.x + 3, puntoA.y + 5, puntoA.x, puntoA.y + 8);
    canvas.drawPath(escoteDelanteroPath, curvePaint);

    // Dibujar escote espalda (curva suave desde A hacia abajo)
    final escoteEspaldaPath = Path()
      ..moveTo(puntoA.x, puntoA.y)
      ..quadraticBezierTo(puntoA.x - 2, puntoA.y + 3, puntoA.x, puntoA.y + 5);
    canvas.drawPath(escoteEspaldaPath, curvePaint);

    // Dibujar todos los puntos como círculos pequeños
    _drawPoint(canvas, puntoA, pointPaint, 'A');
    _drawPoint(canvas, puntoB, pointPaint, 'B');
    _drawPoint(canvas, puntoC, pointPaint, 'C');
    _drawPoint(canvas, puntoD, pointPaint, 'D');
    _drawPoint(canvas, puntoE, pointPaint, 'E');
    _drawPoint(canvas, puntoF, pointPaint, 'F');
    _drawPoint(canvas, puntoG, pointPaint, 'G');
    _drawPoint(canvas, puntoH, pointPaint, 'H');
    _drawPoint(canvas, puntoI, pointPaint, 'I');
    _drawPoint(canvas, puntoJ, pointPaint, 'J');

    final cinturaDerechaVestido = puntos['vestidoCinturaDerecha'];
    final cinturaIzquierdaVestido = puntos['vestidoCinturaIzquierda'];
    final caderaDerechaVestido = puntos['vestidoCaderaDerecha'];
    final caderaIzquierdaVestido = puntos['vestidoCaderaIzquierda'];
    final bajoCentro = puntos['vestidoBajoCentro'];
    final bajoDerecha = puntos['vestidoBajoDerecha'];
    final bajoIzquierda = puntos['vestidoBajoIzquierda'];

    if (cinturaDerechaVestido != null &&
        cinturaIzquierdaVestido != null &&
        caderaDerechaVestido != null &&
        caderaIzquierdaVestido != null &&
        bajoCentro != null &&
        bajoDerecha != null &&
        bajoIzquierda != null) {
      final dressOutline = Path()
        ..moveTo(puntoE.x, puntoE.y)
        ..lineTo(cinturaDerechaVestido.x, cinturaDerechaVestido.y)
        ..lineTo(caderaDerechaVestido.x, caderaDerechaVestido.y)
        ..lineTo(bajoDerecha.x, bajoDerecha.y)
        ..lineTo(bajoIzquierda.x, bajoIzquierda.y)
        ..lineTo(caderaIzquierdaVestido.x, caderaIzquierdaVestido.y)
        ..lineTo(cinturaIzquierdaVestido.x, cinturaIzquierdaVestido.y)
        ..lineTo(puntoF.x, puntoF.y);
      canvas.drawPath(dressOutline, linePaint);

      canvas.drawLine(
        Offset(cinturaIzquierdaVestido.x, cinturaIzquierdaVestido.y),
        Offset(cinturaDerechaVestido.x, cinturaDerechaVestido.y),
        auxiliaryPaint,
      );
      canvas.drawLine(
        Offset(caderaIzquierdaVestido.x, caderaIzquierdaVestido.y),
        Offset(caderaDerechaVestido.x, caderaDerechaVestido.y),
        auxiliaryPaint,
      );
      canvas.drawLine(
        Offset(puntoD.x, puntoD.y),
        Offset(bajoCentro.x, bajoCentro.y),
        auxiliaryPaint,
      );

      _drawPoint(canvas, cinturaDerechaVestido, pointPaint, 'CD');
      _drawPoint(canvas, cinturaIzquierdaVestido, pointPaint, 'CI');
      _drawPoint(canvas, caderaDerechaVestido, pointPaint, 'HD');
      _drawPoint(canvas, caderaIzquierdaVestido, pointPaint, 'HI');
      _drawPoint(canvas, bajoDerecha, pointPaint, 'BD');
      _drawPoint(canvas, bajoIzquierda, pointPaint, 'BI');
    }

    canvas.restore();
  }

  // Función auxiliar para dibujar un punto con su etiqueta
  void _drawPoint(
    Canvas canvas,
    PatternPoint punto,
    Paint paint,
    String label,
  ) {
    // Dibujar círculo del punto
    canvas.drawCircle(Offset(punto.x, punto.y), 4.0, paint);

    // Dibujar etiqueta del punto
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(punto.x + 6, punto.y - 6));
  }

  @override
  bool shouldRepaint(BodyBasePainter oldDelegate) {
    return oldDelegate.puntos != puntos;
  }
}
