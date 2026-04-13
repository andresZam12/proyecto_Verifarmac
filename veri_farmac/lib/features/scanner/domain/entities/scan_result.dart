// Resultado de un escaneo — Dart puro, sin dependencias externas.

// Método usado para escanear el medicamento
enum ScanMethod { barcode, ocr, visual }

class ScanResult {
  const ScanResult({
    required this.id,
    required this.scannedValue,
    required this.method,
    required this.scannedAt,
    this.confidence = 0.0,
    this.medicineName,
    this.sanitaryRecord,
    this.status,
    this.error,
  });

  final String     id;
  final String     scannedValue;   // código o texto crudo leído
  final ScanMethod method;
  final DateTime   scannedAt;
  final double     confidence;     // 0.0 a 1.0
  final String?    medicineName;
  final String?    sanitaryRecord;
  final String?    status;         // vigente, vencido, invalido, etc.
  final String?    error;          // mensaje si algo falló

  // true si se encontró información del medicamento
  bool get isSuccessful => medicineName != null && error == null;
}
