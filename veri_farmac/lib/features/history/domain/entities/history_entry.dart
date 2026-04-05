// Entidad de entrada del historial — Dart puro, sin dependencias externas.
// Representa un escaneo guardado localmente.

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.medicineName,
    required this.sanitaryRecord,
    required this.status,
    required this.method,
    required this.createdAt,
    this.laboratory,
    this.confidence = 0.0,
    this.synced = false,
  });

  final String   id;
  final String   medicineName;
  final String   sanitaryRecord;
  final String   status;       // vigente, vencido, invalido, etc. (valor del API)
  final String   method;       // barcode, ocr, visual
  final DateTime createdAt;
  final String?  laboratory;
  final double   confidence;   // 0.0 a 1.0
  final bool     synced;       // si ya se subió a Supabase
}
