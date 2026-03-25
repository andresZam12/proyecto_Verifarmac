// Datasource local con Drift (SQLite).
// TODO: implementar insertEntry, getEntries, deleteEntry, markAsSynced

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry_model.dart';

// Guarda el historial localmente usando SharedPreferences.
// Usamos SharedPreferences en vez de Drift para simplificar —
// Drift requiere generar código con build_runner.
// Para producción se puede migrar a Drift sin cambiar el repositorio.
class HistoryLocalDataSource {
  static const _clave = 'historial_escaneos';

  // Guarda una entrada en el historial local
  Future<void> guardar(HistoryEntryModel entrada) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();

    // Agrega la nueva entrada al inicio de la lista
    lista.insert(0, entrada.toJson());

    await prefs.setString(_clave, jsonEncode(lista));
  }

  // Obtiene el historial paginado
  Future<List<HistoryEntryModel>> obtener({
    int pagina = 0,
    int porPagina = 20,
  }) async {
    final lista = await _obtenerTodos();
    final inicio = pagina * porPagina;

    if (inicio >= lista.length) return [];

    final fin = (inicio + porPagina).clamp(0, lista.length);

    return lista
        .sublist(inicio, fin)
        .map((json) => HistoryEntryModel.fromJson(json))
        .toList();
  }

  // Elimina una entrada por su id
  Future<void> eliminar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();

    lista.removeWhere((entry) => entry['id'] == id);

    await prefs.setString(_clave, jsonEncode(lista));
  }

  // Obtiene entradas que aún no se han sincronizado con Supabase
  Future<List<HistoryEntryModel>> obtenerNoSincronizados() async {
    final lista = await _obtenerTodos();
    return lista
        .where((entry) => entry['sincronizado'] == false)
        .map((json) => HistoryEntryModel.fromJson(json))
        .toList();
  }

  // Marca una entrada como sincronizada
  Future<void> marcarSincronizado(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();

    for (final entry in lista) {
      if (entry['id'] == id) {
        entry['sincronizado'] = true;
        break;
      }
    }

    await prefs.setString(_clave, jsonEncode(lista));
  }

  // Obtiene estadísticas por estado
  Future<Map<String, int>> obtenerEstadisticas() async {
    final lista = await _obtenerTodos();
    final stats = <String, int>{};

    for (final entry in lista) {
      final estado = entry['estado'] as String;
      stats[estado] = (stats[estado] ?? 0) + 1;
    }

    return stats;
  }

  // Helper: obtiene todos los registros como lista de Maps
  Future<List<Map<String, dynamic>>> _obtenerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_clave);
    if (json == null) return [];

    final lista = jsonDecode(json) as List;
    return lista.cast<Map<String, dynamic>>();
  }
}