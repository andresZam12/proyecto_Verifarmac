// Funciones puras para interpretar el texto leído de un empaque (OCR o
// IA visual): extraer el código de registro INVIMA, la fecha de
// vencimiento, y decidir si un valor escaneado es un código EAN/UPC.
// Sin dependencias externas — pensadas para poder probarse de forma
// aislada (ver test/features/scanner/domain/utils/scan_text_parser_test.dart).

class ScanTextParser {
  ScanTextParser._();

  static final _invimaCodePattern = RegExp(
    r'INVIMA\s*\d{4}[A-Z]\s*-?\s*\d{6,7}',
    caseSensitive: false,
  );

  // Extrae un código INVIMA del texto OCR del empaque.
  // Acepta espacios alrededor del guion: "2008M- 007952" o "2008M-007952".
  static String? extractInvimaCode(String text) =>
      _invimaCodePattern.firstMatch(text)?.group(0);

  // Los códigos EAN/UPC son puramente numéricos (8–14 dígitos).
  static bool isEanBarcode(String value) =>
      RegExp(r'^\d{8,14}$').hasMatch(value.trim());

  static final _expiryPattern = RegExp(
    r'(?:vence|vencimiento|f\.?\s*(?:v|venc)\.?|exp(?:iry|ires)?)'
    r'\s*[:\.]?\s*'
    r'(\d{1,2})\s*[/\-\.]\s*(\d{2,4})',
    caseSensitive: false,
  );

  // Extrae la fecha de vencimiento del texto OCR del empaque.
  // Acepta formatos: MM/YYYY, MM/YY y espacios alrededor del separador.
  // Ej: "VENCE: 07/2020", "EXP. 07 / 2020", "F.V.: 07/20"
  static DateTime? extractExpiryDate(String text) {
    final match = _expiryPattern.firstMatch(text);
    if (match == null) return null;
    return parseMonthYear(match.group(1)!, match.group(2)!);
  }

  // Interpreta una fecha "MM/YYYY" como la que devuelve el análisis de IA.
  static DateTime? parseExpiryString(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null') return null;
    final parts = raw.trim().split(RegExp(r'\s*[/\-\.]\s*'));
    if (parts.length < 2) return null;
    return parseMonthYear(parts[0], parts[1]);
  }

  static DateTime? parseMonthYear(String monthStr, String yearStr) {
    try {
      final month = int.parse(monthStr.trim());
      var   year  = int.parse(yearStr.trim());
      if (year < 100) year += 2000;
      if (month < 1 || month > 12) return null;
      // Vence el último día de ese mes.
      return DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
    } catch (_) {
      return null;
    }
  }

  // `now` es opcional solo para poder fijar una fecha de referencia en
  // las pruebas — en producción siempre se usa el momento actual real.
  static bool isExpired(DateTime? date, {DateTime? now}) =>
      date != null && date.isBefore(now ?? DateTime.now());
}
