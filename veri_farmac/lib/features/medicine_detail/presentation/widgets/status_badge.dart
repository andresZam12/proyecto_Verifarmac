// Badge visual con el estado del medicamento (Vigente, Vencido, etc.).

// Pequeño — para listas e historial
StatusBadge(estado: EstadoMedicamento.vigente)

// Grande — para la pantalla de resultado
StatusBadge(estado: EstadoMedicamento.vencido, grande: true)
