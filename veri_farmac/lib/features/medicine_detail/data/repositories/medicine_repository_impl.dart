                                                                                                                                                                                                                                                                                                                                              // Implementación del repositorio de medicamentos.
// Usa la API pública del INVIMA en datos.gov.co para consultas reales.

import '../../domain/entities/medicine.dart';
import '../../domain/repositories/i_medicine_repository.dart';
import '../datasources/invima_api_datasource.dart';

class MedicineRepositoryImpl implements IMedicineRepository {
  const MedicineRepositoryImpl(this._datasource);
  final InvimaApiDataSource _datasource;

  // Recibe el sanitaryRecord del scanner (ej: "INVIMA 2019M-0017142-R1")
  // o el barcode crudo si el scanner no encontró nada.
  @override
  Future<Medicine?> findByBarcode(String barcode) async {
    try {
      // Si parece registro INVIMA, busca por expediente en la API
      final isRegistry = RegExp(
        r'INVIMA|^\d{4}[A-Z]',
        caseSensitive: false,
      ).hasMatch(barcode);

      return isRegistry
          ? await _datasource.findByRegistry(barcode)
          : await _datasource.findByName(barcode);
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
