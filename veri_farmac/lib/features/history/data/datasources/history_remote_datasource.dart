// Datasource remoto con Supabase.
// Sube y descarga el historial cuando hay conexión a internet.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history_entry_model.dart';

class HistoryRemoteDataSource {
  final _supabase = Supabase.instance.client;
  static const _table = 'scan_history';

  // Sube una lista de entradas a Supabase, asociadas al usuario autenticado.
  // Sin sesión activa no hay a quién asociarlas, así que no sube nada.
  Future<void> uploadEntries(List<HistoryEntryModel> entries) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    final data = entries.map((e) => {...e.toJson(), 'user_id': userId}).toList();
    await _supabase.from(_table).upsert(data);
  }

  // Descarga el historial del usuario desde Supabase
  Future<List<HistoryEntryModel>> downloadHistory(String userId) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('creado_en', ascending: false)
        .limit(100);

    return (response as List)
        .map((json) => HistoryEntryModel.fromJson(json))
        .toList();
  }

  // Elimina una entrada de Supabase
  Future<void> delete(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }

  // Elimina todo el historial del usuario de Supabase
  Future<void> deleteAll() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from(_table).delete().eq('user_id', userId);
  }
}
