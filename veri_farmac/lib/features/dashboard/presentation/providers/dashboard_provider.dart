// Estado del dashboard con Riverpod.
// TODO: implementar DashboardNotifier con GetDashboardStatsUseCase

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/data/datasources/history_local_datasource.dart';
import '../../../history/data/datasources/history_remote_datasource.dart';
import '../../../history/data/repositories/history_repository_impl.dart';
import '../../domain/usecases/get_stats_usecase.dart';

class DashboardState {
  const DashboardState({
    this.stats = const {},
    this.cargando = false,
    this.error,
  });

  final Map<String, int> stats;
  final bool             cargando;
  final String?          error;

  // Total de escaneos realizados
  int get total => stats.values.fold(0, (a, b) => a + b);

  // Conteo por estado
  int get vigentes    => stats['vigente']     ?? 0;
  int get vencidos    => stats['vencido']     ?? 0;
  int get invalidos   => stats['invalido']    ?? 0;
  int get sospechosos => stats['sospechoso']  ?? 0;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._getStats) : super(const DashboardState());

  final GetStatsUseCase _getStats;

  // Carga las estadísticas del historial
  Future<void> cargar() async {
    state = const DashboardState(cargando: true);
    try {
      final stats = await _getStats();
      state = DashboardState(stats: stats);
    } catch (e) {
      state = DashboardState(error: 'Error al cargar estadísticas');
    }
  }
}

// Providers
final _localProvider  = Provider((_) => HistoryLocalDataSource());
final _remotoProvider = Provider((_) => HistoryRemoteDataSource());

final _repositoryProvider = Provider((ref) => HistoryRepositoryImpl(
      ref.read(_localProvider),
      ref.read(_remotoProvider),
    ));

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    GetStatsUseCase(ref.read(_repositoryProvider)),
  );
});