import 'package:flutter/material.dart';
import '../models/medidas.dart';
import '../storage/measurements_storage.dart';

class SeleccionarPerfilScreen extends StatefulWidget {
  const SeleccionarPerfilScreen({super.key});

  @override
  State<SeleccionarPerfilScreen> createState() =>
      _SeleccionarPerfilScreenState();
}

class _SeleccionarPerfilScreenState extends State<SeleccionarPerfilScreen> {
  final MeasurementsStorage _storage = MeasurementsStorage();
  List<String> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  // Cargar la lista de perfiles guardados
  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profiles = await _storage.getProfiles();
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfiles: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Cargar las medidas de un perfil específico y volver a MedidasScreen
  Future<void> _cargarPerfil(String profileName) async {
    try {
      final model = await _storage.loadMeasurements(profileName);

      if (model == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudieron cargar las medidas del perfil'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Crear objeto Medidas desde el modelo cargado
      final medidas = Medidas(
        contornoCuello: model.cuello,
        contornoBusto: model.busto,
        contornoCintura: model.cintura,
        contornoCadera: model.cadera,
        contornoSisa: model.sisa,
        contornoPuno: model.puno,
        contornoManga: model.manga,
        contornoRodilla: model.rodilla,
        contornoTobillo: model.tobillo,
        largoTalle: model.largoTalle,
        largoPinza: 0.0, // Valor por defecto si no está en el modelo
        largoBusto: model.largoBusto,
        largoBlusa: model.largoBlusa,
        largoCodo: model.largoCodo,
        largoMangaCorta: model.largoMangaCorta,
        largoManga34: model.largoManga34,
        largoEscoteDelantero: model.largoEscoteDelantero,
        largoEscoteEspalda: model.largoEscoteEspalda,
        largoCadera: model.largoCadera,
        largoFalda: model.largoFalda,
        largoPantalon: model.largoPantalon,
        largoTiro: model.largoTiro,
        caidaBusto: model.caidaBusto,
        separacionBusto: model.separacionBusto,
        anchoPecho: model.anchoPecho,
        anchoHombros: model.anchoHombros,
        anchoEspalda: model.anchoEspalda,
      );

      // Volver a MedidasScreen con las medidas cargadas
      if (mounted) {
        Navigator.pop(context, medidas);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Eliminar un perfil con confirmación
  Future<void> _eliminarPerfil(String profileName) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el perfil "$profileName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final eliminado = await _storage.deleteProfile(profileName);

      if (eliminado) {
        _loadProfiles(); // Recargar la lista de perfiles
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Perfiles guardados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _profiles.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay perfiles guardados',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _profiles.length,
                      itemBuilder: (context, index) {
                        final profileName = _profiles[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(
                              profileName,
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () => _eliminarPerfil(profileName),
                                  tooltip: 'Eliminar perfil',
                                ),
                                const Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                            onTap: () => _cargarPerfil(profileName),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
