// Modelo de HistoryEntry con serialización JSON.
// TODO: implementar fromJson y toJson, extender HistoryEntry

import '../../domain/entities/history_entry.dart';

// Extiende HistoryEntry y agrega conversión desde/hacia JSON.
// Se usa para guardar y leer de SQLite (Drift) y Supabase.
class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    required super.id,
    required super.nombreMedicamento,
    required super.registroSanitario,
    required super.estado,
    required super.metodo,
    required super.creadoEn,
    super.laboratorio,
    super.confianza,
    super.sincronizado,
  });

  // Crea un modelo desde un Map (viene de Drift o Supabase)
  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return HistoryEntryModel(
      id:                json['id'] as String,
      nombreMedicamento: json['nombre_medicamento'] as String,
      registroSanitario: json['registro_sanitario'] as String,
      estado:            json['estado'] as String,
      metodo:            json['metodo'] as String,
      creadoEn:          DateTime.parse(json['creado_en'] as String),
      laboratorio:       json['laboratorio'] as String?,
      confianza:         (json['confianza'] as num?)?.toDouble() ?? 0.0,
      sincronizado:      json['sincronizado'] as bool? ?? false,
    );
  }

  // Convierte a Map para guardar en Drift o Supabase
  Map<String, dynamic> toJson() {
    return {
      'id':                 id,
      'nombre_medicamento': nombreMedicamento,
      'registro_sanitario': registroSanitario,
      'estado':             estado,
      'metodo':             metodo,
      'creado_en':          creadoEn.toIso8601String(),
      'laboratorio':        laboratorio,
      'confianza':          confianza,
      'sincronizado':       sincronizado,
    };
  }
}