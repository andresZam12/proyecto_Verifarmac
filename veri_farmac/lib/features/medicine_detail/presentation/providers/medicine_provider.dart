import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../scanner/domain/entities/scan_result.dart';
import '../../data/datasources/invima_api_datasource.dart';
import '../../data/models/medicine_model.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/usecases/get_medicine_usecase.dart';

// Estados posibles al cargar un medicamento
enum MedicineStatus { initial, loading, loaded, notFound, error }

class MedicineState {
  const MedicineState({
    this.status = MedicineStatus.initial,
    this.medicine,
    this.error,
  });

  final MedicineStatus status;
  final Medicine?      medicine;
  final String?        error;
}

class MedicineNotifier extends StateNotifier<MedicineState> {
  MedicineNotifier(this._byBarcode, this._byRegistry)
      : super(const MedicineState());

  final GetMedicineByBarcodeUseCase  _byBarcode;
  final GetMedicineByRegistryUseCase _byRegistry;

  Future<void> loadByBarcode(String barcode) async {
    state = const MedicineState(status: MedicineStatus.loading);
    try {
      final medicine = await _byBarcode(barcode);
      state = medicine != null
          ? MedicineState(status: MedicineStatus.loaded, medicine: medicine)
          : const MedicineState(status: MedicineStatus.notFound);
    } catch (e) {
      state = MedicineState(status: MedicineStatus.error, error: e.toString());
    }
  }

  Future<void> loadByRegistry(String registry) async {
    state = const MedicineState(status: MedicineStatus.loading);
    try {
      final medicine = await _byRegistry(registry);
      state = medicine != null
          ? MedicineState(status: MedicineStatus.loaded, medicine: medicine)
          : const MedicineState(status: MedicineStatus.notFound);
    } catch (e) {
      state = MedicineState(status: MedicineStatus.error, error: e.toString());
    }
  }

  // El análisis visual con IA no siempre puede leer un registro INVIMA en el
  // empaque (empaque deteriorado, ángulo, etc). Cuando no hay nada contra qué
  // consultar, se muestra directamente el veredicto de la IA sin llamar a INVIMA.
  void loadFromVisualAnalysis(ScanResult result) {
    state = MedicineState(
      status: MedicineStatus.loaded,
      medicine: MedicineModel(
        id:             result.id,
        name:           result.medicineName ?? AppStrings.visualAnalysisFallbackName,
        sanitaryRecord: result.sanitaryRecord ?? '—',
        laboratory:     '—',
        condition:      Medicine.parseCondition(result.status ?? ''),
      ),
    );
  }
}

final _datasourceProvider = Provider((_) => InvimaApiDataSource());
final _repositoryProvider = Provider(
  (ref) => MedicineRepositoryImpl(ref.read(_datasourceProvider)),
);

// Fecha de corte del dataset de INVIMA — exigida por la Ley 1712/2014 y la
// licencia CC BY-SA 4.0 de datos.gov.co al reutilizar datos abiertos.
final invimaLastUpdatedProvider = FutureProvider<DateTime?>(
  (ref) => ref.read(_datasourceProvider).getDatasetLastUpdated(),
);

final medicineProvider =
    StateNotifierProvider<MedicineNotifier, MedicineState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return MedicineNotifier(
    GetMedicineByBarcodeUseCase(repo),
    GetMedicineByRegistryUseCase(repo),
  );
});