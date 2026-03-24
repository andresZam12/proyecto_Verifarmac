// Resultado de un escaneo.
// TODO: definir id, rawValue, method, confidence, scannedAt, medicine

// Representa el resultado de un escaneo.
// Es Dart puro — sin Flutter, sin Supabase, sin nada externo.

// Método usado para escanear el medicamento
enum MetodoEscaneo { barcode, ocr, visual }

class ScanResult {
  const ScanResult({
    required this.id,
    required this.valorEscaneado,
    required this.metodo,
    required this.escaneadoEn,
    this.confianza = 0.0,
    this.nombreMedicamento,
    this.registroSanitario,
    this.estado,
    this.error,
  });

  final String        id;
  final String        valorEscaneado;   // código o texto crudo leído
  final MetodoEscaneo metodo;
  final DateTime      escaneadoEn;
  final double        confianza;        // 0.0 a 1.0
  final String?       nombreMedicamento;
  final String?       registroSanitario;
  final String?       estado;           // vigente, vencido, invalido, etc.
  final String?       error;            // mensaje si algo falló

  // true si se encontró información del medicamento
  bool get fueExitoso => nombreMedicamento != null && error == null;
}