// Caso de uso: analizar imagen con Claude API.
// TODO: llamar a IScannerRepository.analyzeImage()

import '../entities/scan_result.dart';
import '../repositories/i_scanner_repository.dart';

// Caso de uso: analizar imagen del empaque con Claude API.
class AnalyzeImageUseCase {
  const AnalyzeImageUseCase(this._repo);
  final IScannerRepository _repo;

  Future<ScanResult> call(String rutaImagen) => _repo.analizarImagen(rutaImagen);
}