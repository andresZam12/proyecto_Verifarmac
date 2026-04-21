import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';

import 'features/scanner/data/datasources/claude_ai_datasource.dart';
import 'features/scanner/data/datasources/ocr_datasource.dart';
import 'features/scanner/data/datasources/open_food_facts_datasource.dart';
import 'features/scanner/data/repositories/scanner_repository_impl.dart';
import 'features/scanner/domain/repositories/i_scanner_repository.dart';

import 'features/medicine_detail/data/datasources/invima_api_datasource.dart';
import 'features/medicine_detail/data/repositories/medicine_repository_impl.dart';
import 'features/medicine_detail/domain/repositories/i_medicine_repository.dart';

import 'features/history/data/datasources/history_local_datasource.dart';
import 'features/history/data/datasources/history_remote_datasource.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/repositories/i_history_repository.dart';

import 'features/map/data/datasources/location_datasource.dart';
import 'features/map/data/repositories/location_repository_impl.dart';
import 'features/map/domain/usecases/get_location_usecase.dart';

// Instancia global de get_it
final sl = GetIt.instance;

// Registra todas las dependencias de la app.
// Se llama una sola vez en main.dart antes de runApp.
Future<void> setupDependencies() async {
  // ── Utilidades ──────────────────────────────────────────────
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<INetworkInfo>(
    () => NetworkInfo(sl<Connectivity>()),
  );
  sl.registerLazySingleton(() => DioClient());

  // ── Auth ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => AuthRemoteDataSource());
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl<IAuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<IAuthRepository>()));

  // ── Scanner ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => OcrDataSource());
  sl.registerLazySingleton(() => ClaudeAiDataSource(sl<DioClient>().dio));
  sl.registerLazySingleton(() => OpenFoodFactsDatasource());
  sl.registerLazySingleton<IScannerRepository>(
    () => ScannerRepositoryImpl(
      invima:        sl<InvimaApiDataSource>(),
      ocr:           sl<OcrDataSource>(),
      claude:        sl<ClaudeAiDataSource>(),
      openFoodFacts: sl<OpenFoodFactsDatasource>(),
    ),
  );

  // ── Medicine detail ─────────────────────────────────────────
  sl.registerLazySingleton(() => InvimaApiDataSource());
  sl.registerLazySingleton<IMedicineRepository>(
    () => MedicineRepositoryImpl(sl<InvimaApiDataSource>()),
  );

  // ── History ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => HistoryLocalDataSource());
  sl.registerLazySingleton(() => HistoryRemoteDataSource());
  sl.registerLazySingleton<IHistoryRepository>(
    () => HistoryRepositoryImpl(
      sl<HistoryLocalDataSource>(),
      sl<HistoryRemoteDataSource>(),
    ),
  );

  // ── Map ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LocationDataSource());
  sl.registerLazySingleton<ILocationRepository>(
    () => LocationRepositoryImpl(sl<LocationDataSource>()),
  );
  sl.registerLazySingleton(() => GetLocationUseCase(sl<ILocationRepository>()));
}