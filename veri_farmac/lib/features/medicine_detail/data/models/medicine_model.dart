// Modelo de Medicine con serialización JSON.
// Extiende Medicine y agrega conversión desde/hacia JSON.

import '../../domain/entities/medicine.dart';

class MedicineModel extends Medicine {
  const MedicineModel({
    required super.id,
    required super.name,
    required super.sanitaryRecord,
    required super.laboratory,
    required super.condition,
    super.holder,
    super.activeIngredient,
    super.concentration,
    super.pharmaceuticalForm,
  });

  // Crea un MedicineModel desde el Map del mock o Supabase
  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id:                 json['id'] as String? ?? json['registro'] as String,
      name:               json['nombre'] as String,
      sanitaryRecord:     json['registro'] as String,
      laboratory:         json['laboratorio'] as String,
      condition:          Medicine.parseCondition(json['estado'] as String),
      holder:             json['titular'] as String?,
      activeIngredient:   json['ingrediente'] as String?,
      concentration:      json['concentracion'] as String?,
      pharmaceuticalForm: json['forma'] as String?,
    );
  }

  // Convierte a Map para guardar en Supabase
  Map<String, dynamic> toJson() {
    return {
      'nombre':        name,
      'registro':      sanitaryRecord,
      'laboratorio':   laboratory,
      'estado':        condition.name,
      'titular':       holder,
      'ingrediente':   activeIngredient,
      'concentracion': concentration,
      'forma':         pharmaceuticalForm,
    };
  }
}
