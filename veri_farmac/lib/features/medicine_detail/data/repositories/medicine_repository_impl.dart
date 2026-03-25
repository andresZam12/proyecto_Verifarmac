// Implementación del repositorio de medicamentos.
// TODO: conectar mock/API de INVIMA con el dominio

import '../../domain/entities/medicine.dart';
import '../../domain/repositories/i_medicine_repository.dart';
import '../datasources/invima_mock_datasource.dart';

// Implementa IMedicineRepository usando el mock del INVIMA.
// Cuando haya API real, solo se cambia el datasource — nada más.
class MedicineRepositoryImpl implements IMedicineRepository {
  const MedicineRepositoryImpl(this._datasource);
  final InvimaMockDataSource _datasource;

  @override
  Future<Medicamento?> buscarPorBarcode(String barcode) async {
    try {
      return await _datasource.buscarPorBarcode(barcode);
    } catch (e) {
      throw Exception('Error al buscar por código: $e');
    }
  }

  @override
  Future<Medicamento?> buscarPorRegistro(String registro) async {
    try {
      return await _datasource.buscarPorRegistro(registro);
    } catch (e) {
      throw Exception('Error al buscar por registro: $e');
    }
  }

  @override
  Future<List<Medicamento>> buscarPorTexto(String texto) async {
    try {
      return await _datasource.buscarPorTexto(texto);
    } catch (e) {
      throw Exception('Error al buscar por texto: $e');
    }
  }
}