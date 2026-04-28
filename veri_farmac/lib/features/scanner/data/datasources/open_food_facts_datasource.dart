// Consulta la API pública de Open Food Facts para obtener el nombre
// de un producto a partir de su código EAN/UPC.
//
// API: https://world.openfoodfacts.org/api/v0/product/{barcode}.json
// Sin API key. Gratis y open source.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OpenFoodFactsDatasource {
  OpenFoodFactsDatasource() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept':     'application/json',
        'User-Agent': 'VeriFarmac/1.0 (Android; verifarmac@example.com)',
      },
    ));
  }

  late final Dio _dio;

  /// Devuelve el nombre del producto para un código EAN, o null si no se encuentra.
  Future<String?> getProductName(String ean) async {
    try {
      debugPrint('[OFF] Buscando EAN: $ean');
      final response = await _dio.get(
        'https://world.openfoodfacts.org/api/v0/product/$ean.json',
      );

      final data = response.data as Map<String, dynamic>;

      // status 1 = encontrado, 0 = no encontrado
      if ((data['status'] as int? ?? 0) != 1) {
        debugPrint('[OFF] EAN no encontrado en Open Food Facts');
        return null;
      }

      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      // Intentar varios campos de nombre en orden de preferencia
      final name = (product['product_name']    as String?)?.trim() ??
                   (product['generic_name']     as String?)?.trim() ??
                   (product['product_name_es']  as String?)?.trim() ??
                   (product['product_name_en']  as String?)?.trim();

      if (name == null || name.isEmpty) {
        debugPrint('[OFF] Producto encontrado pero sin nombre');
        return null;
      }

      debugPrint('[OFF] Nombre encontrado: $name');
      return name;
    } catch (e) {
      debugPrint('[OFF] Error: $e');
      return null;
    }
  }
}
