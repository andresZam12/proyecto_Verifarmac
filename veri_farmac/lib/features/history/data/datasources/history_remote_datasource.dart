// Datasource remoto con Supabase.
// TODO: implementar upsertEntries y fetchEntries

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/history_entry_model.dart';

// Sube y descarga el historial desde Supabase.
// Solo se usa cuando hay conexión a internet.
class HistoryRemoteDataSource {
  final _supabase = Supabase.instance.client;
  static const _tabla = 'scan_history';

  // Sube una lista de entradas a Supabase
  Future<void> subirEntradas(List<HistoryEntryModel> entradas) async {
    final datos = entradas.map((e) => e.toJson()).toList();
    await _supabase.from(_tabla).upsert(datos);
  }

  // Descarga el historial del usuario desde Supabase
  Future<List<HistoryEntryModel>> descargarHistorial(String userId) async {
    final respuesta = await _supabase
        .from(_tabla)
        .select()
        .eq('user_id', userId)
        .order('creado_en', ascending: false)
        .limit(100);

    return (respuesta as List)
        .map((json) => HistoryEntryModel.fromJson(json))
        .toList();
  }

  // Elimina una entrada de Supabase
  Future<void> eliminar(String id) async {
    await _supabase.from(_tabla).delete().eq('id', id);
  }
}