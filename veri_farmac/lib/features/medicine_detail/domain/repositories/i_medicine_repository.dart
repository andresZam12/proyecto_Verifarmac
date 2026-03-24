// Contrato del repositorio de medicamentos.
// TODO: definir getByBarcode, getByOcrText, getByRegistryCode, searchByName

import '../entities/medicine.dart';

// Contrato que define qué puede hacer el repositorio de medicamentos.
abstract class IMedicineRepository {
  // Busca un medicamento por código de barras
  Future<Medicamento?> buscarPorBarcode(String barcode);

  // Busca un medicamento por registro sanitario INVIMA
  Future<Medicamento?> buscarPorRegistro(String registro);

  // Busca medicamentos por nombre o ingrediente activo
  Future<List<Medicamento>> buscarPorTexto(String texto);
}