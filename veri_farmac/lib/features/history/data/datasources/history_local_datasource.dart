import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/app_strings.dart';
import '../models/history_entry_model.dart';

class HistoryLocalDataSource {
  static const _storageKey = AppStrings.prefHistoryKey;

  Future<void> save(HistoryEntryModel entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await _fetchAll();
    list.insert(0, entry.toJson());
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<List<HistoryEntryModel>> fetch({int page = 0, int pageSize = 20}) async {
    final list  = await _fetchAll();
    final start = page * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end).map((j) => HistoryEntryModel.fromJson(j)).toList();
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await _fetchAll();
    list.removeWhere((e) => e['id'] == id);
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<List<HistoryEntryModel>> fetchUnsynced() async {
    final list = await _fetchAll();
    return list
        .where((e) => e['sincronizado'] == false)
        .map((j) => HistoryEntryModel.fromJson(j))
        .toList();
  }

  Future<void> markSynced(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = await _fetchAll();
    for (final e in list) {
      if (e['id'] == id) {
        e['sincronizado'] = true;
        break;
      }
    }
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<Map<String, int>> getStatistics() async {
    final list  = await _fetchAll();
    final stats = <String, int>{};
    for (final e in list) {
      final s = e['estado'] as String;
      stats[s] = (stats[s] ?? 0) + 1;
    }
    return stats;
  }

  Future<List<Map<String, dynamic>>> _fetchAll() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString(_storageKey);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }
}
