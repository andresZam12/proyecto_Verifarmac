import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/invima_mock_datasource.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/entities/medicine.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/usecases/get_medicine_usecase.dart';

enum EstadoMedicina { inicial, cargando, cargado, noEncontrado, error }

class MedicineState {
  const MedicineState({this.estado = EstadoMedicina.inicial, this.medicamento, this.error});
  final EstadoMedicina estado;
  final Medicamento?   medicamento;
  final String?        error;
}

class MedicineNotifier extends StateNotifier<MedicineState> {
  MedicineNotifier(this._porBarcode, this._porRegistro) : super(const MedicineState());
  final GetMedicineByBarcodeUseCase  _porBarcode;
  final GetMedicineByRegistroUseCase _porRegistro;

  Future<void> cargarPorBarcode(String barcode) async {
    state = const MedicineState(estado: EstadoMedicina.cargando);
    try {
      final m = await _porBarcode(barcode);
      state = m != null ? MedicineState(estado: EstadoMedicina.cargado, medicamento: m)
                        : const MedicineState(estado: EstadoMedicina.noEncontrado);
    } catch (e) {
      state = MedicineState(estado: EstadoMedicina.error, error: e.toString());
    }
  }

  Future<void> cargarPorRegistro(String registro) async {
    state = const MedicineState(estado: EstadoMedicina.cargando);
    try {
      final m = await _porRegistro(registro);
      state = m != null ? MedicineState(estado: EstadoMedicina.cargado, medicamento: m)
                        : const MedicineState(estado: EstadoMedicina.noEncontrado);
    } catch (e) {
      state = MedicineState(estado: EstadoMedicina.error, error: e.toString());
    }
  }
}

final _datasourceProvider = Provider((_) => InvimaMockDataSource());
final _repositoryProvider = Provider((ref) => MedicineRepositoryImpl(ref.read(_datasourceProvider)));
final medicineProvider = StateNotifierProvider<MedicineNotifier, MedicineState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return MedicineNotifier(GetMedicineByBarcodeUseCase(repo), GetMedicineByRegistroUseCase(repo));
});
