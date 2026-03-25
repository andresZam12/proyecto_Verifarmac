// Caso de uso: obtener estadísticas del dashboard.
// TODO: llamar a IHistoryRepository.getStats()

import '../../../history/domain/repositories/i_history_repository.dart';

// Obtiene las estadísticas de escaneos para mostrar en el dashboard.
// Reutiliza el repositorio del historial — no necesita uno propio.
class GetStatsUseCase {
  const GetStatsUseCase(this._repo);
  final IHistoryRepository _repo;

  Future<Map<String, int>> call() => _repo.obtenerEstadisticas();
}