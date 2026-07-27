import '../models/medidas.dart';

// Clase que representa un punto en el plano 2D
class PatternPoint {
  final double x;
  final double y;

  PatternPoint({required this.x, required this.y});

  @override
  String toString() => '($x, $y)';
}

// Motor de cálculo de patronaje
// Esta clase será responsable de calcular todos los puntos y líneas necesarios
// para generar el patrón de cualquier prenda basándose en las medidas del usuario.
// Más adelante se implementarán las fórmulas reales de patronaje para cada tipo de prenda.
class PatronajeEngine {
  final Medidas medidas;
  final String prendaSeleccionada;

  PatronajeEngine({required this.medidas, required this.prendaSeleccionada});

  // Calcula el patrón que consume el painter de la pantalla de generación.
  Map<String, PatternPoint> calculatePattern() {
    final garment = prendaSeleccionada.trim().toLowerCase();

    if (garment == 'vestido') {
      return calculateDressPatternBasico();
    }
    if (garment == 'blusa') {
      return calculateBlousePatternBasico();
    }
    if (garment == 'falda') {
      return calculateSkirtPatternBasico();
    }
    if (garment.contains('pantal')) {
      return calculatePantsPatternBasico();
    }
    if (garment.contains('manga')) {
      return calculateSleevePatternBasico();
    }

    final requiredMeasurements = <String, double>{
      'largo de talle': medidas.largoTalle,
      'largo de busto': medidas.largoBusto,
      'contorno de sisa': medidas.contornoSisa,
      'ancho de pecho': medidas.anchoPecho,
      'ancho de espalda': medidas.anchoEspalda,
      'ancho de hombros': medidas.anchoHombros,
    };
    for (final entry in requiredMeasurements.entries) {
      if (!entry.value.isFinite || entry.value <= 0) {
        throw ArgumentError(
          'La medida "${entry.key}" debe ser un número mayor que cero.',
        );
      }
    }

    return calculateBodyBasePattern();
  }

  /// Calcula un vestido base uniendo el cuerpo con cintura, cadera y falda.
  Map<String, PatternPoint> calculateDressPattern() {
    final dressMeasurements = <String, double>{
      'contorno de busto': medidas.contornoBusto,
      'contorno de cintura': medidas.contornoCintura,
      'contorno de cadera': medidas.contornoCadera,
      'largo de cadera': medidas.largoCadera,
      'largo de falda': medidas.largoFalda,
    };

    for (final entry in dressMeasurements.entries) {
      if (!entry.value.isFinite || entry.value <= 0) {
        throw ArgumentError(
          'La medida "${entry.key}" debe ser un número mayor que cero.',
        );
      }
    }

    final body = calculateBodyBasePattern();
    final waistY = medidas.largoTalle;
    final hipY = waistY + medidas.largoCadera;
    final hemY = waistY + medidas.largoFalda;
    final waistWidth = (medidas.contornoCintura / 4) + 2;
    final hipWidth = (medidas.contornoCadera / 4) + 1;
    final hemWidth = hipWidth;

    return {
      ...body,
      'puntoD': PatternPoint(x: 0, y: hipY),
      'vestidoCinturaDerecha': PatternPoint(x: waistWidth, y: waistY),
      'vestidoCinturaIzquierda': PatternPoint(x: -waistWidth, y: waistY),
      'vestidoCaderaDerecha': PatternPoint(x: hipWidth, y: hipY),
      'vestidoCaderaIzquierda': PatternPoint(x: -hipWidth, y: hipY),
      'vestidoBajoCentro': PatternPoint(x: 0, y: hemY),
      'vestidoBajoDerecha': PatternPoint(x: hemWidth, y: hemY),
      'vestidoBajoIzquierda': PatternPoint(x: -hemWidth, y: hemY),
    };
  }

  Map<String, PatternPoint> calculateDressPatternBasico() {
    final requiredMeasurements = <String, double>{
      'largo de talle': medidas.largoTalle,
      'largo de busto': medidas.largoBusto,
      'contorno de sisa': medidas.contornoSisa,
      'ancho de pecho': medidas.anchoPecho,
      'ancho de espalda': medidas.anchoEspalda,
      'ancho de hombros': medidas.anchoHombros,
    };
    for (final entry in requiredMeasurements.entries) {
      if (!entry.value.isFinite || entry.value <= 0) {
        throw ArgumentError(
          'La medida "${entry.key}" debe ser un número mayor que cero.',
        );
      }
    }

    return calculateDressPattern();
  }

  Map<String, PatternPoint> calculateBlousePatternBasico() {
    final requiredMeasurements = <String, double>{
      'largo de blusa': medidas.largoBlusa,
      'largo de talle': medidas.largoTalle,
      'largo de busto': medidas.largoBusto,
      'contorno de sisa': medidas.contornoSisa,
      'ancho de pecho': medidas.anchoPecho,
      'ancho de espalda': medidas.anchoEspalda,
      'ancho de hombros': medidas.anchoHombros,
    };

    for (final entry in requiredMeasurements.entries) {
      if (!entry.value.isFinite || entry.value <= 0) {
        throw ArgumentError(
          'La medida "${entry.key}" debe ser un número mayor que cero.',
        );
      }
    }

    return {
      ...calculateBodyBasePattern(),
      'puntoD': PatternPoint(x: 0, y: medidas.largoBlusa),
    };
  }

  Map<String, PatternPoint> calculateSkirtPatternBasico() {
    final requiredMeasurements = <String, double>{
      'contorno de cintura': medidas.contornoCintura,
      'contorno de cadera': medidas.contornoCadera,
      'largo de cadera': medidas.largoCadera,
      'largo de falda': medidas.largoFalda,
    };

    for (final entry in requiredMeasurements.entries) {
      if (!entry.value.isFinite || entry.value <= 0) {
        throw ArgumentError(
          'La medida "${entry.key}" debe ser un número mayor que cero.',
        );
      }
    }

    final waistWidth = (medidas.contornoCintura / 4) + 2;
    final hipWidth = (medidas.contornoCadera / 4) + 1;
    final hipY = medidas.largoCadera;
    final hemY = medidas.largoFalda;
    final middleY = hipY + ((hemY - hipY) / 2);

    return {
      'puntoA': PatternPoint(x: 0, y: 0),
      'puntoB': PatternPoint(x: 0, y: hipY),
      'puntoC': PatternPoint(x: 0, y: middleY),
      'puntoD': PatternPoint(x: 0, y: hemY),
      'puntoE': PatternPoint(x: hipWidth, y: hipY),
      'puntoF': PatternPoint(x: -hipWidth, y: hipY),
      'puntoG': PatternPoint(x: waistWidth, y: 0),
      'puntoH': PatternPoint(x: -waistWidth, y: 0),
      'puntoI': PatternPoint(x: waistWidth, y: 0),
      'puntoJ': PatternPoint(x: -waistWidth, y: 0),
    };
  }

  Map<String, PatternPoint> calculatePantsPatternBasico() {
    final requiredMeasurements = <String, double>{
      'contorno de cintura': medidas.contornoCintura,
      'contorno de cadera': medidas.contornoCadera,
      'contorno de rodilla': medidas.contornoRodilla,
      'contorno de tobillo': medidas.contornoTobillo,
      'largo de pantalón': medidas.largoPantalon,
      'largo de tiro': medidas.largoTiro,
    };

    for (final entry in requiredMeasurements.entries) {
      if (!entry.value.isFinite || entry.value <= 0) {
        throw ArgumentError(
          'La medida "${entry.key}" debe ser un número mayor que cero.',
        );
      }
    }

    final waistWidth = (medidas.contornoCintura / 4) + 1;
    final hipWidth = (medidas.contornoCadera / 4) + 1;
    final kneeWidth = medidas.contornoRodilla / 4;
    final ankleWidth = medidas.contornoTobillo / 4;
    final kneeY =
        medidas.largoTiro + ((medidas.largoPantalon - medidas.largoTiro) / 2);

    return {
      'puntoA': PatternPoint(x: 0, y: 0),
      'puntoB': PatternPoint(x: 0, y: medidas.largoTiro),
      'puntoC': PatternPoint(x: 0, y: kneeY),
      'puntoD': PatternPoint(x: 0, y: medidas.largoPantalon),
      'puntoE': PatternPoint(x: hipWidth, y: medidas.largoTiro),
      'puntoF': PatternPoint(x: -hipWidth, y: medidas.largoTiro),
      'puntoG': PatternPoint(x: kneeWidth, y: kneeY),
      'puntoH': PatternPoint(x: -kneeWidth, y: kneeY),
      'puntoI': PatternPoint(x: waistWidth, y: 0),
      'puntoJ': PatternPoint(x: -waistWidth, y: 0),
      'pantalonTobilloDerecho': PatternPoint(
        x: ankleWidth,
        y: medidas.largoPantalon,
      ),
      'pantalonTobilloIzquierdo': PatternPoint(
        x: -ankleWidth,
        y: medidas.largoPantalon,
      ),
    };
  }

  Map<String, PatternPoint> calculateSleevePatternBasico() {
    final requiredMeasurements = <String, double>{
      'contorno de sisa': medidas.contornoSisa,
      'contorno de manga': medidas.contornoManga,
      'contorno de puño': medidas.contornoPuno,
      'largo de manga': medidas.largoManga34,
    };

    for (final entry in requiredMeasurements.entries) {
      if (!entry.value.isFinite || entry.value <= 0) {
        throw ArgumentError(
          'La medida "${entry.key}" debe ser un número mayor que cero.',
        );
      }
    }

    final sleeveWidth = medidas.contornoManga / 2;
    final halfSleeveWidth = sleeveWidth / 2;
    final capHeight = medidas.contornoSisa / 4;
    final cuffWidth = medidas.contornoPuno / 2;
    final sleeveLength = medidas.largoManga34;
    final elbowY = sleeveLength / 2;

    return {
      'puntoA': PatternPoint(x: 0, y: 0),
      'puntoB': PatternPoint(x: 0, y: capHeight),
      'puntoC': PatternPoint(x: 0, y: elbowY),
      'puntoD': PatternPoint(x: 0, y: sleeveLength),
      'puntoE': PatternPoint(x: halfSleeveWidth, y: capHeight),
      'puntoF': PatternPoint(x: -halfSleeveWidth, y: capHeight),
      'puntoG': PatternPoint(x: halfSleeveWidth, y: capHeight),
      'puntoH': PatternPoint(x: -halfSleeveWidth, y: capHeight),
      'puntoI': PatternPoint(x: halfSleeveWidth / 2, y: capHeight / 2),
      'puntoJ': PatternPoint(x: -halfSleeveWidth / 2, y: capHeight / 2),
      'mangaPunoDerecho': PatternPoint(x: cuffWidth / 2, y: sleeveLength),
      'mangaPunoIzquierdo': PatternPoint(x: -cuffWidth / 2, y: sleeveLength),
    };
  }

  // Función que calcula el patrón base del cuerpo usando fórmulas de patronaje
  // Este patrón base sirve como fundamento para construir cualquier prenda
  Map<String, PatternPoint> calculateBodyBasePattern() {
    // Extraer medidas para facilitar el cálculo
    final largoTalle = medidas.largoTalle;
    final largoBusto = medidas.largoBusto;
    final anchoPecho = medidas.anchoPecho;
    final anchoEspalda = medidas.anchoEspalda;
    final contornoSisa = medidas.contornoSisa;

    // Profundidad de sisa (aproximadamente 1/4 del contorno de sisa + holgura)
    final profundidadSisa = (contornoSisa / 4) + 2;

    // Ancho de hombro (mitad del ancho total de hombros)
    final anchoHombro = medidas.anchoHombros / 2;

    // Definir punto de origen (centro delantero en cuello)
    final puntoA = PatternPoint(x: 0, y: 0);

    // Punto B: centro delantero en línea de busto
    // Y = largo de busto (distancia del cuello al busto)
    final puntoB = PatternPoint(x: 0, y: largoBusto);

    // Punto C: centro delantero en línea de cintura
    // Y = largo de talle (distancia del cuello a la cintura)
    final puntoC = PatternPoint(x: 0, y: largoTalle);

    // Punto D: centro delantero en línea de cadera
    // Y = largo de talle + 18cm (distancia estándar de cintura a cadera)
    final puntoD = PatternPoint(x: 0, y: largoTalle + 18);

    // Punto E: ancho de pecho (línea lateral delantera en busto)
    // X = ancho de pecho proporcionado por el usuario
    // Y = largo de busto (misma altura que punto B)
    final puntoE = PatternPoint(x: anchoPecho, y: largoBusto);

    // Punto F: ancho de espalda (línea lateral trasera en busto)
    // X = -ancho de espalda (negativo porque está a la izquierda del centro)
    // Y = largo de busto (misma altura que punto B)
    final puntoF = PatternPoint(x: -anchoEspalda, y: largoBusto);

    // Punto G: sisa delantera (punto más bajo de la sisa delantera)
    // X = ancho de pecho
    // Y = profundidad de sisa desde el cuello
    final puntoG = PatternPoint(x: anchoPecho, y: profundidadSisa);

    // Punto H: sisa espalda (punto más bajo de la sisa trasera)
    // X = -ancho de espalda
    // Y = profundidad de sisa desde el cuello
    final puntoH = PatternPoint(x: -anchoEspalda, y: profundidadSisa);

    // Punto I: hombro delantero (extremo del hombro delantero)
    // X = ancho de hombro
    // Y = 4cm (caída estándar del hombro desde el cuello)
    final puntoI = PatternPoint(x: anchoHombro, y: 4);

    // Punto J: hombro espalda (extremo del hombro trasero)
    // X = -ancho de hombro
    // Y = 4cm (caída estándar del hombro desde el cuello)
    final puntoJ = PatternPoint(x: -anchoHombro, y: 4);

    // Devolver mapa con todos los puntos calculados
    return {
      'puntoA': puntoA, // Centro delantero en cuello
      'puntoB': puntoB, // Centro delantero en busto
      'puntoC': puntoC, // Centro delantero en cintura
      'puntoD': puntoD, // Centro delantero en cadera
      'puntoE': puntoE, // Ancho de pecho
      'puntoF': puntoF, // Ancho de espalda
      'puntoG': puntoG, // Sisa delantera
      'puntoH': puntoH, // Sisa espalda
      'puntoI': puntoI, // Hombro delantero
      'puntoJ': puntoJ, // Hombro espalda
    };
  }

  // Función que calcula el patrón base de falda usando fórmulas de patronaje
  // Este patrón base sirve como fundamento para construir faldas de diferentes estilos
  Map<String, PatternPoint> calculateSkirtBasePattern() {
    // Extraer medidas para facilitar el cálculo
    final contornoCintura = medidas.contornoCintura;
    final contornoCadera = medidas.contornoCadera;
    final largoFalda = medidas.largoFalda;
    final largoCadera = medidas.largoCadera;

    // Cálculos básicos de patronaje de falda
    // Ancho de cuarto de cintura (mitad delantera)
    final anchoCuartoCintura = contornoCintura / 4;

    // Ancho de cuarto de cadera (mitad delantera)
    final anchoCuartoCadera = contornoCadera / 4;

    // Holgura estándar para cintura (2 cm)
    final holguraCintura = 2.0;

    // Holgura estándar para cadera (1 cm)
    final holguraCadera = 1.0;

    // Definir punto de origen (centro delantero en cintura)
    final puntoA = PatternPoint(x: 0, y: 0);

    // Punto B: centro delantero en línea de cadera
    // Y = largo de cadera (distancia de la cintura a la cadera)
    final puntoB = PatternPoint(x: 0, y: largoCadera);

    // Punto C: centro delantero en línea del bajo de falda
    // Y = largo de falda (distancia total de la falda)
    final puntoC = PatternPoint(x: 0, y: largoFalda);

    // Punto D: ancho de cintura (línea lateral en cintura)
    // X = ancho de cuarto de cintura + holgura
    // Y = 0 (misma altura que punto A)
    final puntoD = PatternPoint(x: anchoCuartoCintura + holguraCintura, y: 0);

    // Punto E: ancho de cadera (línea lateral en cadera)
    // X = ancho de cuarto de cadera + holgura
    // Y = largo de cadera (misma altura que punto B)
    final puntoE = PatternPoint(
      x: anchoCuartoCadera + holguraCadera,
      y: largoCadera,
    );

    // Punto F: lateral del bajo (extremo lateral del bajo de falda)
    // X = ancho de cadera (misma coordenada X que punto E)
    // Y = largo de falda (misma altura que punto C)
    final puntoF = PatternPoint(
      x: anchoCuartoCadera + holguraCadera,
      y: largoFalda,
    );

    // Punto G: inicio de pinza delantera (en la línea de cintura)
    // X = 3 cm desde el centro delantero
    // Y = 0 (en la línea de cintura)
    final puntoG = PatternPoint(x: 3.0, y: 0);

    // Punto H: fin de pinza delantera (punto más profundo de la pinza)
    // X = 3 cm desde el centro delantero (misma X que punto G)
    // Y = 12 cm hacia abajo desde la cintura (largo estándar de pinza)
    final puntoH = PatternPoint(x: 3.0, y: 12.0);

    // Devolver mapa con todos los puntos calculados
    return {
      'puntoA': puntoA, // Centro delantero en cintura
      'puntoB': puntoB, // Centro delantero en cadera
      'puntoC': puntoC, // Centro delantero en bajo
      'puntoD': puntoD, // Ancho de cintura
      'puntoE': puntoE, // Ancho de cadera
      'puntoF': puntoF, // Lateral del bajo
      'puntoG': puntoG, // Inicio de pinza
      'puntoH': puntoH, // Fin de pinza
    };
  }

  // Función que calcula el patrón base de manga usando fórmulas de patronaje
  // Este patrón base sirve como fundamento para construir mangas de diferentes estilos
  Map<String, PatternPoint> calculateSleeveBasePattern() {
    // Extraer medidas para facilitar el cálculo
    final contornoSisa = medidas.contornoSisa;
    final contornoManga = medidas.contornoManga;
    final largoManga34 = medidas.largoManga34;
    final contornoPuno = medidas.contornoPuno;

    // Cálculos básicos de patronaje de manga
    // Ancho de manga (mitad del ancho total)
    final anchoManga = contornoManga / 2;

    // Altura de copa de manga (aproximadamente 1/4 del contorno de sisa)
    final alturaCopa = contornoSisa / 4;

    // Largo de brazo estándar (usar largo de manga 3/4 como referencia)
    final largoBrazo = largoManga34;

    // Ancho de puño (mitad del contorno de puño)
    final anchoPuno = contornoPuno / 2;

    // Definir punto de origen (inicio de copa de manga)
    final puntoA = PatternPoint(x: 0, y: 0);

    // Punto B: punto delantero de copa
    // X = ancho de manga / 3 (tercio del ancho hacia el delantero)
    // Y = altura de copa (punto más alto de la copa delantera)
    final puntoB = PatternPoint(x: anchoManga / 3, y: alturaCopa);

    // Punto C: punto central de copa (punto más alto de la copa)
    // X = ancho de manga / 2 (centro de la manga)
    // Y = altura de copa + 2cm (pico central de la copa)
    final puntoC = PatternPoint(x: anchoManga / 2, y: alturaCopa + 2);

    // Punto D: punto espalda de copa
    // X = (ancho de manga / 3) * 2 (dos tercios del ancho hacia la espalda)
    // Y = altura de copa (punto más alto de la copa trasera)
    final puntoD = PatternPoint(x: (anchoManga / 3) * 2, y: alturaCopa);

    // Punto E: bajo delantero (extremo inferior delantero de la manga)
    // X = 0 (alineado con el inicio de copa)
    // Y = largo de brazo (largo total de la manga)
    final puntoE = PatternPoint(x: 0, y: largoBrazo);

    // Punto F: bajo espalda (extremo inferior trasero de la manga)
    // X = ancho de manga (ancho total de la manga)
    // Y = largo de brazo (largo total de la manga)
    final puntoF = PatternPoint(x: anchoManga, y: largoBrazo);

    // Punto G: puño delantero (inicio de línea de puño)
    // X = (ancho de manga - ancho de puño) / 2 (centrado)
    // Y = largo de brazo (en el bajo de la manga)
    final puntoG = PatternPoint(x: (anchoManga - anchoPuno) / 2, y: largoBrazo);

    // Punto H: puño espalda (fin de línea de puño)
    // X = (ancho de manga + ancho de puño) / 2 (centrado)
    // Y = largo de brazo (en el bajo de la manga)
    final puntoH = PatternPoint(x: (anchoManga + anchoPuno) / 2, y: largoBrazo);

    // Devolver mapa con todos los puntos calculados
    return {
      'puntoA': puntoA, // Inicio de copa
      'puntoB': puntoB, // Punto delantero de copa
      'puntoC': puntoC, // Punto central de copa
      'puntoD': puntoD, // Punto espalda de copa
      'puntoE': puntoE, // Bajo delantero
      'puntoF': puntoF, // Bajo espalda
      'puntoG': puntoG, // Puño delantero
      'puntoH': puntoH, // Puño espalda
    };
  }

  // Función que calcula el patrón base de pantalón usando fórmulas de patronaje
  // Este patrón base sirve como fundamento para construir pantalones de diferentes estilos
  Map<String, PatternPoint> calculatePantsBasePattern() {
    // Extraer medidas para facilitar el cálculo
    final contornoCadera = medidas.contornoCadera;
    final largoPantalon = medidas.largoPantalon;
    final largoTiro = medidas.largoTiro;
    final contornoRodilla = medidas.contornoRodilla;
    final contornoTobillo = medidas.contornoTobillo;

    // Avance de tiro delantero
    final avanceTiroDelantero = (contornoCadera / 10) + 1.0;

    // Avance de tiro espalda (más profundo que el delantero)
    final avanceTiroEspalda = (contornoCadera / 10) + 3.0;

    // Ancho de rodilla (mitad del contorno de rodilla)
    final anchoRodilla = contornoRodilla / 2;

    // Ancho de tobillo (mitad del contorno de tobillo)
    final anchoTobillo = contornoTobillo / 2;

    // Definir punto de origen (cintura delantera)
    final puntoA = PatternPoint(x: 0, y: 0);

    // Punto B: avance de tiro delantero
    // X = avance de tiro delantero
    // Y = largo de tiro (distancia de la cintura al inicio de la entrepierna)
    final puntoB = PatternPoint(x: avanceTiroDelantero, y: largoTiro);

    // Punto C: rodilla delantera
    // X = ancho de rodilla / 2 (mitad del ancho de rodilla)
    // Y = largo de pantalón - 30cm (posición estándar de la rodilla)
    final posicionRodilla = largoPantalon - 30.0;
    final puntoC = PatternPoint(x: anchoRodilla / 2, y: posicionRodilla);

    // Punto D: tobillo delantero
    // X = ancho de tobillo / 2 (mitad del ancho de tobillo)
    // Y = largo de pantalón (extremo inferior del pantalón)
    final puntoD = PatternPoint(x: anchoTobillo / 2, y: largoPantalon);

    // Punto E: cintura espalda (con aumento de altura)
    // X = 0 (alineado con la cintura delantera pero en la parte trasera)
    // Y = -2cm (2 cm más alto que la cintura delantera para dar forma)
    final puntoE = PatternPoint(x: 0, y: -2.0);

    // Punto F: avance de tiro espalda
    // X = -avance de tiro espalda (negativo porque está detrás)
    // Y = largo de tiro (misma altura que punto B)
    final puntoF = PatternPoint(x: -avanceTiroEspalda, y: largoTiro);

    // Punto G: rodilla espalda
    // X = -ancho de rodilla / 2 (mitad del ancho de rodilla hacia atrás)
    // Y = largo de pantalón - 30cm (misma altura que punto C)
    final puntoG = PatternPoint(x: -anchoRodilla / 2, y: posicionRodilla);

    // Punto H: tobillo espalda
    // X = -ancho de tobillo / 2 (mitad del ancho de tobillo hacia atrás)
    // Y = largo de pantalón (misma altura que punto D)
    final puntoH = PatternPoint(x: -anchoTobillo / 2, y: largoPantalon);

    // Devolver mapa con todos los puntos calculados
    return {
      'puntoA': puntoA, // Cintura delantera
      'puntoB': puntoB, // Avance de tiro delantero
      'puntoC': puntoC, // Rodilla delantera
      'puntoD': puntoD, // Tobillo delantero
      'puntoE': puntoE, // Cintura espalda
      'puntoF': puntoF, // Avance de tiro espalda
      'puntoG': puntoG, // Rodilla espalda
      'puntoH': puntoH, // Tobillo espalda
    };
  }
}
