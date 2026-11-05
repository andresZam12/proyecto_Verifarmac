// Consulta Open Products Facts — misma organización y formato de API que
// Open Food Facts, pero para productos NO alimenticios (el resto del
// catálogo: aseo, electrónica, papelería, etc.). Sin API key, gratis.
//
// API: https://world.openproductsfacts.org/api/v0/product/{barcode}.json

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/barcode_product_info.dart';

class OpenProductsFactsDatasource {
  OpenProductsFactsDatasource() {
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

  /// Devuelve nombre + categoría del producto para un código EAN, o null si
  /// no se encuentra.
  Future<BarcodeProductInfo?> getProductInfo(String ean) async {
    try {
      debugPrint('[OPF] Buscando EAN: $ean');
      final response = await _dio.get(
        'https://world.openproductsfacts.org/api/v0/product/$ean.json',
      );

      final data = response.data as Map<String, dynamic>;

      // status 1 = encontrado, 0 = no encontrado
      if ((data['status'] as int? ?? 0) != 1) {
        debugPrint('[OPF] EAN no encontrado en Open Products Facts');
        return null;
      }

      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final name = (product['product_name']    as String?)?.trim() ??
                   (product['generic_name']     as String?)?.trim() ??
                   (product['product_name_es']  as String?)?.trim() ??
                   (product['product_name_en']  as String?)?.trim();

      if (name == null || name.isEmpty) {
        debugPrint('[OPF] Producto encontrado pero sin nombre');
        return null;
      }

      final category = (product['categories'] as String?)?.trim();

      debugPrint('[OPF] Nombre encontrado: $name (categoría: $category)');
      return BarcodeProductInfo(name: name, category: category);
    } catch (e) {
      debugPrint('[OPF] Error: $e');
      return null;
    }
  }
}
