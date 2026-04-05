// Caso de uso: obtener estadísticas del dashboard.
// Reutiliza el repositorio del historial — no necesita uno propio.

import '../../../history/domain/repositories/i_history_repository.dart';

class GetStatsUseCase {
  const GetStatsUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<Map<String, int>> call() => _repo.getStatistics();
}
