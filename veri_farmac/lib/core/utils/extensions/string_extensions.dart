// Extensiones útiles para String.
extension StringExtension on String {
  // Primera letra en mayúscula: 'hola mundo' → 'Hola mundo'
  String get capitalizada =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  // Trunca el texto con puntos suspensivos
  // Ejemplo: 'Texto muy largo'.truncar(10) → 'Texto muy ...'
  String truncar(int maxCaracteres) {
    if (length <= maxCaracteres) return this;
    return '${substring(0, maxCaracteres)}...';
  }

  // Extrae un código INVIMA del texto OCR del empaque
  // Ejemplo: 'Reg. San. INVIMA 2023M-0012345' → 'INVIMA2023M0012345'
  String? get codigoInvima {
    final regex = RegExp(
      r'INVIMA\s*\d{4}[A-Z]-?\d{6,7}(?:-?R\d)?',
      caseSensitive: false,
    );
    final resultado = regex.firstMatch(this);
    return resultado?.group(0)?.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
  }

  // Verifica si el string está vacío o solo tiene espacios
  bool get estaVacio => trim().isEmpty;
}