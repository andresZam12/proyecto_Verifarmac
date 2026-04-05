// Modelo de HistoryEntry con serialización JSON.
// Extiende HistoryEntry y agrega conversión desde/hacia JSON.

import '../../domain/entities/history_entry.dart';

class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    required super.id,
    required super.medicineName,
    required super.sanitaryRecord,
    required super.status,
    required super.method,
    required super.createdAt,
    super.laboratory,
    super.confidence,
    super.synced,
  });

  // Crea un modelo desde un Map (viene de SharedPreferences o Supabase)
  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return HistoryEntryModel(
      id:             json['id'] as String,
      medicineName:   json['nombre_medicamento'] as String,
      sanitaryRecord: json['registro_sanitario'] as String,
      status:         json['estado'] as String,
      method:         json['metodo'] as String,
      createdAt:      DateTime.parse(json['creado_en'] as String),
      laboratory:     json['laboratorio'] as String?,
      confidence:     (json['confianza'] as num?)?.toDouble() ?? 0.0,
      synced:         json['sincronizado'] as bool? ?? false,
    );
  }

  // Convierte a Map para guardar en SharedPreferences o Supabase
  Map<String, dynamic> toJson() {
    return {
      'id':                 id,
      'nombre_medicamento': medicineName,
      'registro_sanitario': sanitaryRecord,
      'estado':             status,
      'metodo':             method,
      'creado_en':          createdAt.toIso8601String(),
      'laboratorio':        laboratory,
      'confianza':          confidence,
      'sincronizado':       synced,
    };
  }
}
