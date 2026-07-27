import 'dart:convert';
import 'dart:io';

class HistorialService {
  final String _path = 'historial.json';

  Future<void> agregarRegistro(Map<String, dynamic> registro) async {
    final file = File(_path);

    List<dynamic> historial = [];

    if (await file.exists()) {
      final contenido = await file.readAsString();
      if (contenido.trim().isNotEmpty) {
        historial = jsonDecode(contenido);
      }
    }

    historial.add(registro);

    await file.writeAsString(jsonEncode(historial), mode: FileMode.write);
  }

  Future<List<dynamic>> cargarHistorial() async {
    final file = File(_path);

    if (!await file.exists()) {
      return [];
    }

    final contenido = await file.readAsString();
    if (contenido.trim().isEmpty) {
      return [];
    }

    return jsonDecode(contenido);
  }
}
