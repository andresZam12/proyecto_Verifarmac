// Contrato del repositorio de medicamentos.

import '../entities/medicine.dart';

// Define qué puede hacer el repositorio de medicamentos.
abstract class IMedicineRepository {
  // Busca un medicamento por código de barras
  Future<Medicine?> findByBarcode(String barcode);

  // Busca un medicamento por registro sanitario INVIMA
  Future<Medicine?> findByRegistry(String registry);

  // Busca medicamentos por nombre o ingrediente activo
  Future<List<Medicine>> search(String query);
}
