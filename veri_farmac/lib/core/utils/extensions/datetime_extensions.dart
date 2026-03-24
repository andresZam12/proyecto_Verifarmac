// Extensiones para DateTime.
extension DateTimeExtension on DateTime {
  // Fecha corta: '15 ene 2024'
  String get fechaCorta {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '$day ${meses[month - 1]} $year';
  }

  // Fecha relativa: 'Hoy', 'Ayer' o la fecha corta
  String get fechaRelativa {
    final hoy = DateTime.now();
    final diferencia = DateTime(hoy.year, hoy.month, hoy.day)
        .difference(DateTime(year, month, day))
        .inDays;

    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Ayer';
    return fechaCorta;
  }

  // Verifica si la fecha ya pasó (útil para registros vencidos)
  bool get estaVencido => isBefore(DateTime.now());
}