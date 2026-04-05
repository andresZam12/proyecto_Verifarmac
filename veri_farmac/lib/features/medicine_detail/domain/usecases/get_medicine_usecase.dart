// Casos de uso para obtener información de medicamentos del INVIMA.

import '../entities/medicine.dart';
import '../repositories/i_medicine_repository.dart';

// Obtiene la información completa de un medicamento por código de barras.
class GetMedicineByBarcodeUseCase {
  const GetMedicineByBarcodeUseCase(this._repo);
  final IMedicineRepository _repo;

  Future<Medicine?> call(String barcode) => _repo.findByBarcode(barcode);
}

// Obtiene la información completa de un medicamento por registro INVIMA.
class GetMedicineByRegistryUseCase {
  const GetMedicineByRegistryUseCase(this._repo);
  final IMedicineRepository _repo;

  Future<Medicine?> call(String registry) => _repo.findByRegistry(registry);
}

// Busca medicamentos por nombre o ingrediente activo.
class SearchMedicineUseCase {
  const SearchMedicineUseCase(this._repo);
  final IMedicineRepository _repo;

  Future<List<Medicine>> call(String query) => _repo.search(query);
}
