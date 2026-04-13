// Caso de uso: escanear por código de barras.
// TODO: llamar a IScannerRepository.processBarcodeValue()

import '../entities/scan_result.dart';
import '../repositories/i_scanner_repository.dart';

// Caso de uso: escanear por código de barras.
class ScanByBarcodeUseCase {
  const ScanByBarcodeUseCase(this._repo);
  final IScannerRepository _repo;

  Future<ScanResult> call(String barcode) => _repo.processBarcode(barcode);
}