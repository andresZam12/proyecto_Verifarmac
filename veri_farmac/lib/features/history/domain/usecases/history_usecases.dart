// Casos de uso del historial.

import '../entities/history_entry.dart';
import '../repositories/i_history_repository.dart';

// Guarda un escaneo en el historial local.
class SaveHistoryEntryUseCase {
  const SaveHistoryEntryUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<void> call(HistoryEntry entry) => _repo.save(entry);
}

// Obtiene el historial paginado.
class FetchHistoryUseCase {
  const FetchHistoryUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<List<HistoryEntry>> call({int page = 0}) => _repo.fetch(page: page);
}

// Elimina una entrada del historial.
class DeleteHistoryEntryUseCase {
  const DeleteHistoryEntryUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<void> call(String id) => _repo.delete(id);
}

// Sincroniza el historial local con Supabase.
class SyncHistoryUseCase {
  const SyncHistoryUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<void> call(String userId) => _repo.sync(userId);
}

// Obtiene estadísticas para el dashboard.
class GetStatisticsUseCase {
  const GetStatisticsUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<Map<String, int>> call() => _repo.getStatistics();
}
