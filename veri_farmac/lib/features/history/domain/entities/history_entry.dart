// Entidad de entrada del historial.
// TODO: definir id, scanResult, pharmacyId, createdAt, latitude, longitude

// Representa un escaneo guardado en el historial.
// Dart puro — sin dependencias externas.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.nombreMedicamento,
    required this.registroSanitario,
    required this.estado,
    required this.metodo,
    required this.creadoEn,
    this.laboratorio,
    this.confianza = 0.0,
    this.sincronizado = false,
  });

  final String   id;
  final String   nombreMedicamento;
  final String   registroSanitario;
  final String   estado;           // vigente, vencido, invalido, etc.
  final String   metodo;           // barcode, ocr, visual
  final DateTime creadoEn;
  final String?  laboratorio;
  final double   confianza;        // 0.0 a 1.0
  final bool     sincronizado;     // si ya se subió a Supabase
}