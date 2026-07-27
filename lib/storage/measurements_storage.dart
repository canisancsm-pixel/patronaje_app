import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/measurements_model.dart';

// Clase para gestionar el almacenamiento de medidas usando SharedPreferences
// Permite guardar, cargar, listar y eliminar perfiles de medidas
class MeasurementsStorage {
  // Clave base para almacenar los nombres de los perfiles
  static const String _profilesKey = 'measurement_profiles';

  // Prefijo para cada perfil individual
  static const String _profilePrefix = 'profile_';

  // Guarda las medidas en un perfil específico
  // Si el perfil ya existe, lo sobrescribe
  Future<void> saveMeasurements(
    String profileName,
    MeasurementsModel model,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener la lista actual de perfiles
    final profiles = await getProfiles();

    // Si el perfil no existe, añadirlo a la lista
    if (!profiles.contains(profileName)) {
      profiles.add(profileName);
      await prefs.setStringList(_profilesKey, profiles);
    }

    // Guardar las medidas del perfil como JSON
    final key = '$_profilePrefix$profileName';
    final jsonString = jsonEncode(model.toJson());
    await prefs.setString(key, jsonString);
  }

  // Carga las medidas de un perfil específico
  // Retorna null si el perfil no existe
  Future<MeasurementsModel?> loadMeasurements(String profileName) async {
    final prefs = await SharedPreferences.getInstance();

    final key = '$_profilePrefix$profileName';
    final jsonString = prefs.getString(key);

    if (jsonString == null) {
      return null;
    }

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return MeasurementsModel.fromJson(jsonMap);
    } catch (e) {
      // Si hay error al decodificar, retornar null
      return null;
    }
  }

  // Obtiene la lista de todos los perfiles guardados
  Future<List<String>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = prefs.getStringList(_profilesKey);
    return profiles ?? [];
  }

  // Elimina un perfil específico
  // Retorna true si se eliminó correctamente, false si no existía
  Future<bool> deleteProfile(String profileName) async {
    final prefs = await SharedPreferences.getInstance();

    final profiles = await getProfiles();

    if (!profiles.contains(profileName)) {
      return false;
    }

    // Eliminar el perfil de la lista
    profiles.remove(profileName);
    await prefs.setStringList(_profilesKey, profiles);

    // Eliminar los datos del perfil
    final key = '$_profilePrefix$profileName';
    await prefs.remove(key);

    return true;
  }

  // Verifica si un perfil existe
  Future<bool> profileExists(String profileName) async {
    final profiles = await getProfiles();
    return profiles.contains(profileName);
  }

  // Actualiza el nombre de un perfil existente
  // Retorna true si se actualizó correctamente
  Future<bool> renameProfile(String oldName, String newName) async {
    final profiles = await getProfiles();

    if (!profiles.contains(oldName) || profiles.contains(newName)) {
      return false;
    }

    // Cargar las medidas del perfil antiguo
    final measurements = await loadMeasurements(oldName);
    if (measurements == null) {
      return false;
    }

    // Guardar con el nuevo nombre
    await saveMeasurements(newName, measurements);

    // Eliminar el perfil antiguo
    await deleteProfile(oldName);

    return true;
  }
}
