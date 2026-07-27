import 'dart:convert';
import 'dart:io';

class HistorialService {
  static const String carpetaPatrones =
      r'C:/flutter_projects/patronaje_app/patrones_PDF';
  static const String nombreArchivo = 'historial.json';

  File get _archivo => File('$carpetaPatrones/$nombreArchivo');

  Future<void> agregarRegistro(Map<String, dynamic> registro) async {
    final historial = await cargarHistorial();
    historial.insert(0, registro);

    final archivo = _archivo;
    await archivo.parent.create(recursive: true);
    await archivo.writeAsString(jsonEncode(historial));
  }

  Future<List<Map<String, dynamic>>> cargarHistorial() async {
    final archivo = _archivo;
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
