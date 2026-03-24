// Casos de uso: obtener medicamento por barcode u OCR.
// TODO: implementar GetMedicineByBarcodeUseCase y GetMedicineByOcrUseCase

import '../entities/medicine.dart';
import '../repositories/i_medicine_repository.dart';

// Obtiene la información completa de un medicamento por barcode.
class GetMedicineByBarcodeUseCase {
  const GetMedicineByBarcodeUseCase(this._repo);
  final IMedicineRepository _repo;

  Future<Medicamento?> call(String barcode) => _repo.buscarPorBarcode(barcode);
}

// Obtiene la información completa de un medicamento por registro INVIMA.
class GetMedicineByRegistroUseCase {
  const GetMedicineByRegistroUseCase(this._repo);
  final IMedicineRepository _repo;

  Future<Medicamento?> call(String registro) => _repo.buscarPorRegistro(registro);
}

// Busca medicamentos por nombre o ingrediente activo.
class SearchMedicineUseCase {
  const SearchMedicineUseCase(this._repo);
  final IMedicineRepository _repo;

  Future<List<Medicamento>> call(String texto) => _repo.buscarPorTexto(texto);
}