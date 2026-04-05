// Scanner repository contract.

import '../entities/scan_result.dart';

// Contract defining what the scanner repository can do.
// The data layer implements it — the domain only knows this interface.
abstract class IScannerRepository {
  // Processes a barcode and looks up the medicine
  Future<ScanResult> processBarcode(String barcode);

  // Processes text extracted via OCR from the packaging
  Future<ScanResult> processOcr(String text);

  // Analyzes the packaging image with Claude API
  Future<ScanResult> analyzeImage(String imagePath);
}
