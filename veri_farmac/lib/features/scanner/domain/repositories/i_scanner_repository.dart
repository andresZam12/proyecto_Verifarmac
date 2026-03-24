// Contrato del repositorio de escaneo.
// TODO: definir processBarcodeValue, processOcrText, analyzeImage

import '../entities/scan_result.dart';

// Contrato que define qué puede hacer el repositorio del scanner.
// La capa de datos lo implementa — el dominio solo conoce esta interfaz.
abstract class IScannerRepository {
  // Procesa un código de barras y busca el medicamento
  Future<ScanResult> procesarBarcode(String barcode);

  // Procesa texto extraído con OCR del empaque
  Future<ScanResult> procesarOcr(String texto);

  // Analiza la imagen del empaque con Claude API
  Future<ScanResult> analizarImagen(String rutaImagen);
}