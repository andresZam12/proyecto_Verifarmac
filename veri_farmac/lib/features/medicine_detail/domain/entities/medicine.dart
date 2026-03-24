// Entidad principal de medicamento — Dart puro.
// TODO: definir id, name, sanitaryRecord, laboratory, status, etc.

// Entidad principal del medicamento — Dart puro.
// Representa toda la información de un medicamento del INVIMA.

// Estados posibles del registro sanitario
enum EstadoMedicamento { vigente, vencido, invalido, sospechoso, desconocido }

extension EstadoMedicamentoX on EstadoMedicamento {
  // Texto legible para mostrar en la UI
  String get etiqueta => switch (this) {
    EstadoMedicamento.vigente     => 'Vigente',
    EstadoMedicamento.vencido     => 'Vencido',
    EstadoMedicamento.invalido    => 'Inválido',
    EstadoMedicamento.sospechoso  => 'Sospechoso',
    EstadoMedicamento.desconocido => 'Desconocido',
  };

  // true solo si el medicamento es seguro para usar
  bool get esSeguro => this == EstadoMedicamento.vigente;
}

class Medicamento {
  const Medicamento({
    required this.id,
    required this.nombre,
    required this.registroSanitario,
    required this.laboratorio,
    required this.estado,
    this.titular,
    this.ingredienteActivo,
    this.concentracion,
    this.formaFarmaceutica,
  });

  final String             id;
  final String             nombre;
  final String             registroSanitario; // INVIMA 2023M-0012345
  final String             laboratorio;
  final EstadoMedicamento  estado;
  final String?            titular;
  final String?            ingredienteActivo;
  final String?            concentracion;
  final String?            formaFarmaceutica;

  // Convierte el string del estado al enum correspondiente
  static EstadoMedicamento parsearEstado(String valor) {
    return switch (valor.toLowerCase()) {
      'vigente'    => EstadoMedicamento.vigente,
      'vencido'    => EstadoMedicamento.vencido,
      'invalido'   => EstadoMedicamento.invalido,
      'sospechoso' => EstadoMedicamento.sospechoso,
      _            => EstadoMedicamento.desconocido,
    };
  }
}