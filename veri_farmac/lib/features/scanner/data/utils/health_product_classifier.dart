// Heurística de mejor esfuerzo para decidir si un producto encontrado en
// una base de código de barras genérica (Open Food Facts, UPCItemDB, etc.)
// parece ser un medicamento o producto natural — lo único que VeriFarmac
// puede verificar contra INVIMA. Esas bases no tienen una categoría
// "medicamento" estandarizada, así que se busca por palabras clave en el
// nombre y la categoría que sí reportan.

import '../models/barcode_product_info.dart';

class HealthProductClassifier {
  HealthProductClassifier._();

  static const keywords = [
    'medic', 'farmac', 'drug', 'pill', 'tablet', 'tableta', 'capsul',
    'jarabe', 'syrup', 'suplement', 'supplement', 'vitamin', 'vitamina',
    'salud', 'health', 'natural', 'herbal', 'fitoterap', 'analges',
    'antibiot', 'antiinflamat', 'dolor', 'pain relief', 'pharma',
  ];

  static bool looksLikeHealthProduct(BarcodeProductInfo info) {
    final text = '${info.name} ${info.category ?? ''}'.toLowerCase();
    return keywords.any(text.contains);
  }
}
