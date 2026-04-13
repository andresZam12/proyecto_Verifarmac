import '../../domain/entities/scan_result.dart';

// Extends ScanResult and adds JSON serialization.
// Used to save and read from local history (Drift) and Supabase.
class ScanResultModel extends ScanResult {
  const ScanResultModel({
    required super.id,
    required super.scannedValue,
    required super.method,
    required super.scannedAt,
    super.confidence,
    super.medicineName,
    super.sanitaryRecord,
    super.status,
    super.error,
  });

  // Creates a ScanResultModel from a Map (from Drift or Supabase)
  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id:             json['id'] as String,
      scannedValue:   json['valor_escaneado'] as String,
      method:         _parseMethod(json['metodo'] as String),
      scannedAt:      DateTime.parse(json['escaneado_en'] as String),
      confidence:     (json['confianza'] as num?)?.toDouble() ?? 0.0,
      medicineName:   json['nombre_medicamento'] as String?,
      sanitaryRecord: json['registro_sanitario'] as String?,
      status:         json['estado'] as String?,
      error:          json['error'] as String?,
    );
  }

  // Converts to Map for saving in Drift or Supabase
  Map<String, dynamic> toJson() {
    return {
      'id':                 id,
      'valor_escaneado':    scannedValue,
      'metodo':             method.name,
      'escaneado_en':       scannedAt.toIso8601String(),
      'confianza':          confidence,
      'nombre_medicamento': medicineName,
      'registro_sanitario': sanitaryRecord,
      'estado':             status,
      'error':              error,
    };
  }

  // Converts the method string to the corresponding enum value
  static ScanMethod _parseMethod(String value) {
    switch (value) {
      case 'ocr':    return ScanMethod.ocr;
      case 'visual': return ScanMethod.visual;
      default:       return ScanMethod.barcode;
    }
  }
}
