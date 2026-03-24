// Caso de uso: escanear por texto OCR.
// TODO: llamar a IScannerRepository.processOcrText()

import '../entities/scan_result.dart';
import '../repositories/i_scanner_repository.dart';

// Caso de uso: escanear por texto OCR del empaque.
class ScanByOcrUseCase {
  const ScanByOcrUseCase(this._repo);
  final IScannerRepository _repo;

  Future<ScanResult> call(String texto) => _repo.procesarOcr(texto);
}