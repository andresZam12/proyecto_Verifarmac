import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/history_local_datasource.dart';
import '../../data/datasources/history_remote_datasource.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/history_usecases.dart';
import '../../../../../core/constants/app_strings.dart';

class HistoryState {
  const HistoryState({
    this.entries   = const [],
    this.isLoading = false,
    this.error,
    this.filter,
  });
  final List<HistoryEntry> entries;
  final bool               isLoading;
  final String?            error;
  final String?            filter;

  List<HistoryEntry> get filteredEntries =>
      filter == null ? entries : entries.where((e) => e.status == filter).toList();
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._fetch, this._delete, this._sync)
      : super(const HistoryState());

  final FetchHistoryUseCase       _fetch;
  final DeleteHistoryEntryUseCase _delete;
  final SyncHistoryUseCase        _sync;

  Future<void> load() async {
    state = const HistoryState(isLoading: true);
    try {
      state = HistoryState(entries: await _fetch());
    } catch (_) {
      state = const HistoryState(error: AppStrings.errorLoadingHistory);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete(id);
      state = HistoryState(
        entries: state.entries.where((e) => e.id != id).toList(),
        filter: state.filter,
      );
    } catch (_) {
      state = HistoryState(entries: state.entries, error: AppStrings.errorDeleting);
    }
  }

  void filterBy(String? status) =>
      state = HistoryState(entries: state.entries, filter: status);

  Future<void> sync(String userId) async {
    try {
      await _sync(userId);
    } catch (_) {}
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

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return HistoryNotifier(
    FetchHistoryUseCase(repo),
    DeleteHistoryEntryUseCase(repo),
    SyncHistoryUseCase(repo),
  );
});
