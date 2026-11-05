import 'package:flutter_test/flutter_test.dart';
import 'package:veri_farmac/features/scanner/data/models/barcode_product_info.dart';
import 'package:veri_farmac/features/scanner/data/utils/health_product_classifier.dart';

void main() {
  group('HealthProductClassifier.looksLikeHealthProduct', () {
    test('reconoce un medicamento por el nombre', () {
      const info = BarcodeProductInfo(name: 'Acetaminofén 500mg Tabletas');
      expect(HealthProductClassifier.looksLikeHealthProduct(info), isTrue);
    });

    test('reconoce un producto por la categoría aunque el nombre no lo diga', () {
      const info = BarcodeProductInfo(
        name: 'Boost',
        category: 'Health & Beauty > Vitamins & Supplements',
      );
      expect(HealthProductClassifier.looksLikeHealthProduct(info), isTrue);
    });

    test('rechaza un producto de tecnología sin palabras clave de salud', () {
      const info = BarcodeProductInfo(
        name: 'Cable USB-C 1m',
        category: 'Electronics > Cables',
      );
      expect(HealthProductClassifier.looksLikeHealthProduct(info), isFalse);
    });

    test('rechaza un alimento genérico sin relación con salud', () {
      const info = BarcodeProductInfo(name: 'Galletas de chocolate', category: 'Snacks');
      expect(HealthProductClassifier.looksLikeHealthProduct(info), isFalse);
    });

    test('sin categoría, decide solo por el nombre', () {
      const info = BarcodeProductInfo(name: 'Jarabe para la tos');
      expect(HealthProductClassifier.looksLikeHealthProduct(info), isTrue);
    });
  });
}
