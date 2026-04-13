// Entidad principal del medicamento — Dart puro.
// Representa toda la información de un medicamento del INVIMA.

// Estados posibles del registro sanitario
enum MedicineCondition { valid, expired, invalid, suspicious, unknown }

extension MedicineConditionX on MedicineCondition {
  // Texto legible para mostrar en la UI (se reemplaza por l10n en widgets)
  String get label => switch (this) {
    MedicineCondition.valid      => 'Vigente',
    MedicineCondition.expired    => 'Vencido',
    MedicineCondition.invalid    => 'Inválido',
    MedicineCondition.suspicious => 'Sospechoso',
    MedicineCondition.unknown    => 'Desconocido',
  };

  // true solo si el medicamento es seguro para usar
  bool get isSafe => this == MedicineCondition.valid;
}

class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.sanitaryRecord,
    required this.laboratory,
    required this.condition,
    this.holder,
    this.activeIngredient,
    this.concentration,
    this.pharmaceuticalForm,
  });

  final String           id;
  final String           name;
  final String           sanitaryRecord;    // Ej: INVIMA 2023M-0012345
  final String           laboratory;
  final MedicineCondition condition;
  final String?          holder;
  final String?          activeIngredient;
  final String?          concentration;
  final String?          pharmaceuticalForm;

  // Convierte el string del estado al enum correspondiente
  static MedicineCondition parseCondition(String value) {
    return switch (value.toLowerCase()) {
      'vigente'    => MedicineCondition.valid,
      'vencido'    => MedicineCondition.expired,
      'invalido'   => MedicineCondition.invalid,
      'sospechoso' => MedicineCondition.suspicious,
      _            => MedicineCondition.unknown,
    };
  }
}
