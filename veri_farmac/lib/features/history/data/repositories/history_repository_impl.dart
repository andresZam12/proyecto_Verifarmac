// Implementación del repositorio de historial.
// Estrategia: guarda siempre en local primero, sincroniza con Supabase después.

import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/i_history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../datasources/history_remote_datasource.dart';
import '../models/history_entry_model.dart';

class HistoryRepositoryImpl implements IHistoryRepository {
  const HistoryRepositoryImpl(this._local, this._remote);

  final HistoryLocalDataSource  _local;
  final HistoryRemoteDataSource _remote;

  @override
  Future<void> save(HistoryEntry entry) async {
    final model = HistoryEntryModel(
      id:             entry.id,
      medicineName:   entry.medicineName,
      sanitaryRecord: entry.sanitaryRecord,
      status:         entry.status,
      method:         entry.method,
      createdAt:      entry.createdAt,
      laboratory:     entry.laboratory,
      confidence:     entry.confidence,
      synced:         false,
    );

    // Guarda primero en local
    await _local.save(model);

    // Intenta subir a Supabase — si falla, se sincronizará después
    try {
      await _remote.uploadEntries([model]);
      await _local.markSynced(entry.id);
    } catch (_) {
      // Sin conexión — se sincronizará cuando vuelva internet
    }
  }

  @override
  Future<List<HistoryEntry>> fetch({int page = 0, int pageSize = 20}) {
    return _local.fetch(page: page, pageSize: pageSize);
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    try {
      await _remote.delete(id);
    } catch (_) {
      // Si falla en remoto, al menos se eliminó localmente
    }
  }

  @override
  Future<void> sync(String userId) async {
    try {
      final unsynced = await _local.fetchUnsynced();
      if (unsynced.isEmpty) return;
      await _remote.uploadEntries(unsynced);
      for (final entry in unsynced) {
        await _local.markSynced(entry.id);
      }
    } catch (_) {
      // Sin conexión — se intentará de nuevo más tarde
    }
  }

  @override
  Future<Map<String, int>> getStatistics() {
    return _local.getStatistics();
  }
}
