import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/history_local_datasource.dart';
import '../../data/datasources/history_remote_datasource.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/history_usecases.dart';

class HistoryState {
  const HistoryState({this.entradas = const [], this.cargando = false, this.error, this.filtro});
  final List<HistoryEntry> entradas;
  final bool               cargando;
  final String?            error;
  final String?            filtro;

  List<HistoryEntry> get entradasFiltradas =>
      filtro == null ? entradas : entradas.where((e) => e.estado == filtro).toList();
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._obtener, this._eliminar, this._sincronizar) : super(const HistoryState());
  final ObtenerHistorialUseCase     _obtener;
  final EliminarHistorialUseCase    _eliminar;
  final SincronizarHistorialUseCase _sincronizar;

  Future<void> cargar() async {
    state = const HistoryState(cargando: true);
    try {
      state = HistoryState(entradas: await _obtener());
    } catch (_) {
      state = const HistoryState(error: 'Error al cargar el historial');
    }
  }

  Future<void> eliminar(String id) async {
    try {
      await _eliminar(id);
      state = HistoryState(entradas: state.entradas.where((e) => e.id != id).toList(), filtro: state.filtro);
    } catch (_) {
      state = HistoryState(entradas: state.entradas, error: 'Error al eliminar');
    }
  }

  void filtrar(String? estado) =>
      state = HistoryState(entradas: state.entradas, filtro: estado);

  Future<void> sincronizar(String userId) async {
    try { await _sincronizar(userId); } catch (_) {}
  }
}

final _localProvider      = Provider((_) => HistoryLocalDataSource());
final _remotoProvider     = Provider((_) => HistoryRemoteDataSource());
final _repositoryProvider = Provider((ref) => HistoryRepositoryImpl(ref.read(_localProvider), ref.read(_remotoProvider)));

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return HistoryNotifier(ObtenerHistorialUseCase(repo), EliminarHistorialUseCase(repo), SincronizarHistorialUseCase(repo));
});
