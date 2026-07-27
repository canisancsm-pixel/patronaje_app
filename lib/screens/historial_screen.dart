import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../services/historial_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late Future<List<Map<String, dynamic>>> _historial;

  @override
  void initState() {
    super.initState();
    _historial = HistorialService().cargarHistorial();
  }

  void _recargar() {
    setState(() {
      _historial = HistorialService().cargarHistorial();
    });
  }

  Future<void> _abrirPdf(String filePath) async {
    if (!await File(filePath).exists()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PDF ya no existe en el disco')),
      );
      return;
    }

    final resultado = await OpenFilex.open(filePath);
    if (!mounted) return;
    if (resultado.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir el PDF: ${resultado.message}'),
        ),
      );
    }
  }

  String _nombreArchivo(String filePath) =>
      filePath.split(RegExp(r'[\\/]+')).last;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de patrones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recargar,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historial,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar el historial: ${snapshot.error}'),
            );
          }

          final registros = snapshot.data ?? const <Map<String, dynamic>>[];
          if (registros.isEmpty) {
            return const Center(
              child: Text('Todavía no hay patrones generados'),
            );
          }

          return ListView.separated(
            itemCount: registros.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final registro = registros[index];
              final filePath = (registro['filePath'] ?? '').toString();
              final prenda = (registro['prenda'] ?? '-').toString();
              final variante = (registro['variante'] ?? '-').toString();
              final fecha = (registro['fecha'] ?? '-').toString();

              return ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(_nombreArchivo(filePath)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('$prenda · $variante'), Text(fecha)],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Abrir PDF',
                  onPressed: filePath.isEmpty
                      ? null
                      : () => _abrirPdf(filePath),
                ),
                onTap: filePath.isEmpty ? null : () => _abrirPdf(filePath),
              );
            },
          );
        },
      ),
    );
  }
}
