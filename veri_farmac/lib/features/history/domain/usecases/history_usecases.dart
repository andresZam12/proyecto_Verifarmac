// Casos de uso del historial.
// TODO: implementar SaveHistoryEntryUseCase, GetHistoryUseCase, DeleteHistoryEntryUseCase

import '../entities/history_entry.dart';
import '../repositories/i_history_repository.dart';

// Guarda un escaneo en el historial local.
class GuardarHistorialUseCase {
  const GuardarHistorialUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<void> call(HistoryEntry entrada) => _repo.guardar(entrada);
}

// Obtiene el historial paginado.
class ObtenerHistorialUseCase {
  const ObtenerHistorialUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<List<HistoryEntry>> call({int pagina = 0}) =>
      _repo.obtener(pagina: pagina);
}

// Elimina una entrada del historial.
class EliminarHistorialUseCase {
  const EliminarHistorialUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<void> call(String id) => _repo.eliminar(id);
}

// Sincroniza el historial local con Supabase.
class SincronizarHistorialUseCase {
  const SincronizarHistorialUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<void> call(String userId) => _repo.sincronizar(userId);
}

// Obtiene estadísticas para el dashboard.
class ObtenerEstadisticasUseCase {
  const ObtenerEstadisticasUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<Map<String, int>> call() => _repo.obtenerEstadisticas();
}