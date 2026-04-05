import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/invima_mock_datasource.dart';
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

  // Carga el medicamento por código de barras
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

  // Carga el medicamento por registro INVIMA
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
}

final _datasourceProvider = Provider((_) => InvimaMockDataSource());
final _repositoryProvider = Provider(
  (ref) => MedicineRepositoryImpl(ref.read(_datasourceProvider)),
);

final medicineProvider =
    StateNotifierProvider<MedicineNotifier, MedicineState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return MedicineNotifier(
    GetMedicineByBarcodeUseCase(repo),
    GetMedicineByRegistryUseCase(repo),
  );
});
