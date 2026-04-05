// Implementación del repositorio de medicamentos.
// Cuando haya API real, solo se cambia el datasource — nada más.

import '../../domain/entities/medicine.dart';
import '../../domain/repositories/i_medicine_repository.dart';
import '../datasources/invima_mock_datasource.dart';

class MedicineRepositoryImpl implements IMedicineRepository {
  const MedicineRepositoryImpl(this._datasource);
  final InvimaMockDataSource _datasource;

  @override
  Future<Medicine?> findByBarcode(String barcode) async {
    try {
      return await _datasource.findByBarcode(barcode);
    } catch (e) {
      throw Exception('Error searching by barcode: $e');
    }
  }

  @override
  Future<Medicine?> findByRegistry(String registry) async {
    try {
      return await _datasource.findByRegistry(registry);
    } catch (e) {
      throw Exception('Error searching by registry: $e');
    }
  }

  @override
  Future<List<Medicine>> search(String query) async {
    try {
      return await _datasource.search(query);
    } catch (e) {
      throw Exception('Error searching medicines: $e');
    }
  }
}
