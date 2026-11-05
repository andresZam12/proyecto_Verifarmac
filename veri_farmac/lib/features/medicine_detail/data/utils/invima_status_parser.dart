// Funciones puras para interpretar/preparar datos de la API de INVIMA
// (Socrata). Sin dependencias externas — fáciles de probar de forma aislada.

class InvimaStatusParser {
  InvimaStatusParser._();

  // Normaliza el texto libre de "estadoregistro" (p. ej. "Vigente",
  // "Vencido", "Suspendido") al valor interno que usa el resto de la app.
  static String normalizeStatus(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('vigente'))                                 return 'vigente';
    if (value.contains('venc'))                                    return 'vencido';
    if (value.contains('invalid') || value.contains('suspendido')) return 'invalido';
    if (value.contains('sospech'))                                 return 'sospechoso';
    return 'desconocido';
  }

  // Escapa comillas simples para interpolar valores en consultas SoQL
  // ($where) sin romper la sintaxis.
  static String escape(String value) => value.replaceAll("'", "''");
}
