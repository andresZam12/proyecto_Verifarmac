// Modelo de Medicine con serialización JSON.
// TODO: implementar fromJson y toJson, extender Medicine

import '../../domain/entities/medicine.dart';

// Extiende Medicamento y agrega conversión desde/hacia JSON.
class MedicineModel extends Medicamento {
  const MedicineModel({
    required super.id,
    required super.nombre,
    required super.registroSanitario,
    required super.laboratorio,
    required super.estado,
    super.titular,
    super.ingredienteActivo,
    super.concentracion,
    super.formaFarmaceutica,
  });

  // Crea un MedicineModel desde el Map del mock o Supabase
  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id:                json['id'] as String? ?? json['registro'] as String,
      nombre:            json['nombre'] as String,
      registroSanitario: json['registro'] as String,
      laboratorio:       json['laboratorio'] as String,
      estado:            Medicamento.parsearEstado(json['estado'] as String),
      titular:           json['titular'] as String?,
      ingredienteActivo: json['ingrediente'] as String?,
      concentracion:     json['concentracion'] as String?,
      formaFarmaceutica: json['forma'] as String?,
    );
  }

  // Convierte a Map para guardar en Supabase
  Map<String, dynamic> toJson() {
    return {
      'nombre':      nombre,
      'registro':    registroSanitario,
      'laboratorio': laboratorio,
      'estado':      estado.name,
      'titular':     titular,
      'ingrediente': ingredienteActivo,
      'concentracion': concentracion,
      'forma':       formaFarmaceutica,
    };
  }
}