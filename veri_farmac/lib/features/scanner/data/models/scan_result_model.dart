// Modelo de ScanResult con serialización JSON.
// TODO: implementar fromJson y toJson, extender ScanResult

import '../../domain/entities/scan_result.dart';

// Extiende ScanResult y agrega conversión desde/hacia JSON.
// Se usa para guardar y leer del historial local (Drift) y Supabase.
class ScanResultModel extends ScanResult {
  const ScanResultModel({
    required super.id,
    required super.valorEscaneado,
    required super.metodo,
    required super.escaneadoEn,
    super.confianza,
    super.nombreMedicamento,
    super.registroSanitario,
    super.estado,
    super.error,
  });

  // Crea un ScanResultModel desde un Map (viene de Drift o Supabase)
  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id:                json['id'] as String,
      valorEscaneado:    json['valor_escaneado'] as String,
      metodo:            _parsearMetodo(json['metodo'] as String),
      escaneadoEn:       DateTime.parse(json['escaneado_en'] as String),
      confianza:         (json['confianza'] as num?)?.toDouble() ?? 0.0,
      nombreMedicamento: json['nombre_medicamento'] as String?,
      registroSanitario: json['registro_sanitario'] as String?,
      estado:            json['estado'] as String?,
      error:             json['error'] as String?,
    );
  }

  // Convierte a Map para guardar en Drift o Supabase
  Map<String, dynamic> toJson() {
    return {
      'id':                 id,
      'valor_escaneado':    valorEscaneado,
      'metodo':             metodo.name,
      'escaneado_en':       escaneadoEn.toIso8601String(),
      'confianza':          confianza,
      'nombre_medicamento': nombreMedicamento,
      'registro_sanitario': registroSanitario,
      'estado':             estado,
      'error':              error,
    };
  }

  // Convierte el string del método al enum correspondiente
  static MetodoEscaneo _parsearMetodo(String valor) {
    switch (valor) {
      case 'ocr':    return MetodoEscaneo.ocr;
      case 'visual': return MetodoEscaneo.visual;
      default:       return MetodoEscaneo.barcode;
    }
  }
}