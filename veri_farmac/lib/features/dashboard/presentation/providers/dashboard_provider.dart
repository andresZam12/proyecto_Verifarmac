import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/data/datasources/history_local_datasource.dart';
import '../../../history/data/datasources/history_remote_datasource.dart';
import '../../../history/data/repositories/history_repository_impl.dart';
import '../../domain/usecases/get_stats_usecase.dart';
import '../../../../../core/constants/app_strings.dart';

class DashboardState {
  const DashboardState({
    this.stats    = const {},
    this.isLoading = false,
    this.error,
  });
  final Map<String, int> stats;
  final bool             isLoading;
  final String?          error;

  // Totales calculados a partir del mapa de stats
  int get total       => stats.values.fold(0, (a, b) => a + b);
  int get valid       => stats['vigente']       ?? 0;
  int get expired     => stats['vencido']       ?? 0;
  int get invalid     => stats['invalido']      ?? 0;
  int get suspicious  => stats['sospechoso']    ?? 0;
  int get notFound    => stats['no_encontrado'] ?? 0;
  int get alerts      => invalid + suspicious;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._getStats) : super(const DashboardState());
  final GetStatsUseCase _getStats;

  Future<void> load() async {
    state = const DashboardState(isLoading: true);
    try {
      state = DashboardState(stats: await _getStats());
    } catch (_) {
      state = const DashboardState(error: AppStrings.errorLoadingStats);
    }
  }
}

final _localProvider      = Provider((_) => HistoryLocalDataSource());
final _remoteProvider     = Provider((_) => HistoryRemoteDataSource());
final _repositoryProvider = Provider(
  (ref) => HistoryRepositoryImpl(
    ref.read(_localProvider),
    ref.read(_remoteProvider),
  ),
);

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(GetStatsUseCase(ref.read(_repositoryProvider))),
);
