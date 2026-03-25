import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry_model.dart';

class HistoryLocalDataSource {
  static const _clave = 'historial_escaneos';

  Future<void> guardar(HistoryEntryModel entrada) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();
    lista.insert(0, entrada.toJson());
    await prefs.setString(_clave, jsonEncode(lista));
  }

  Future<List<HistoryEntryModel>> obtener({int pagina = 0, int porPagina = 20}) async {
    final lista  = await _obtenerTodos();
    final inicio = pagina * porPagina;
    if (inicio >= lista.length) return [];
    final fin = (inicio + porPagina).clamp(0, lista.length);
    return lista.sublist(inicio, fin).map((j) => HistoryEntryModel.fromJson(j)).toList();
  }

  Future<void> eliminar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();
    lista.removeWhere((e) => e['id'] == id);
    await prefs.setString(_clave, jsonEncode(lista));
  }

  Future<List<HistoryEntryModel>> obtenerNoSincronizados() async {
    final lista = await _obtenerTodos();
    return lista.where((e) => e['sincronizado'] == false).map((j) => HistoryEntryModel.fromJson(j)).toList();
  }

  Future<void> marcarSincronizado(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();
    for (final e in lista) { if (e['id'] == id) { e['sincronizado'] = true; break; } }
    await prefs.setString(_clave, jsonEncode(lista));
  }

  Future<Map<String, int>> obtenerEstadisticas() async {
    final lista = await _obtenerTodos();
    final stats = <String, int>{};
    for (final e in lista) { final est = e['estado'] as String; stats[est] = (stats[est] ?? 0) + 1; }
    return stats;
  }

  Future<List<Map<String, dynamic>>> _obtenerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString(_clave);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }
}
