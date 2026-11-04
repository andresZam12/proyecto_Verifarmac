// Respaldo de Open Food Facts para códigos EAN/UPC que no son alimentos.
//
// API: https://api.upcitemdb.com/prod/trial/lookup?upc={code}
// Trial gratuito sin API key, limitado a ~100 consultas/día por IP.
// Cobertura mayormente de EE.UU./minorista general — tampoco tiene una
// base de medicamentos colombianos (no existe una base pública gratuita
// que cruce código de barras ↔ registro INVIMA), pero amplía el universo
// de productos reconocibles más allá de Open Food Facts, que es casi
// exclusivamente alimentos.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/barcode_product_info.dart';

class UpcLookupDataSource {
  UpcLookupDataSource() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));
  }

  late final Dio _dio;

  /// Devuelve nombre + categoría del producto para un código EAN/UPC, o null
  /// si no se encuentra o la consulta falla (p. ej. límite diario agotado).
  Future<BarcodeProductInfo?> getProductInfo(String code) async {
    try {
      debugPrint('[UPCItemDB] Buscando: $code');
      final response = await _dio.get(
        'https://api.upcitemdb.com/prod/trial/lookup',
        queryParameters: {'upc': code},
      );

      final data  = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) {
        debugPrint('[UPCItemDB] Sin resultados');
        return null;
      }

      final item  = items.first as Map<String, dynamic>;
      final title = (item['title'] as String?)?.trim();
      if (title == null || title.isEmpty) return null;

      final category = (item['category'] as String?)?.trim();

      debugPrint('[UPCItemDB] Nombre encontrado: $title (categoría: $category)');
      return BarcodeProductInfo(name: title, category: category);
    } catch (e) {
      debugPrint('[UPCItemDB] Error: $e');
      return null;
    }
  }
}
