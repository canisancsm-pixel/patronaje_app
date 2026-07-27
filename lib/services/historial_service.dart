import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class HistorialService {
  static const String carpetaWindows =
      r'C:/flutter_projects/patronaje_app/patrones_PDF';
  static const String nombreArchivo = 'historial.json';

  /// Carpeta donde se guardan los PDFs y el historial.
  ///
  /// En Windows es la ruta fija del proyecto; en el resto de plataformas se
  /// usa el directorio de documentos de la app para tener una ruta absoluta.
  static Future<Directory> carpetaPatrones() async {
    if (Platform.isWindows) {
      return Directory(carpetaWindows);
    }

    final documentos = await getApplicationDocumentsDirectory();
    return Directory('${documentos.path}/patronaje_app/patrones_PDF');
  }

  Future<File> _archivo() async {
    final carpeta = await carpetaPatrones();
    return File('${carpeta.path}/$nombreArchivo').absolute;
  }

  Future<void> agregarRegistro(Map<String, dynamic> registro) async {
    final historial = await cargarHistorial();
    historial.insert(0, registro);

    final archivo = await _archivo();
    await archivo.parent.create(recursive: true);
    await archivo.writeAsString(jsonEncode(historial));
  }

  Future<List<Map<String, dynamic>>> cargarHistorial() async {
    final archivo = await _archivo();
    if (!await archivo.exists()) return <Map<String, dynamic>>[];

    try {
      final contenido = await archivo.readAsString();
      if (contenido.trim().isEmpty) return <Map<String, dynamic>>[];

      final decodificado = jsonDecode(contenido);
      if (decodificado is! List) return <Map<String, dynamic>>[];

      return decodificado
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on FormatException {
      return <Map<String, dynamic>>[];
    }
  }
}
