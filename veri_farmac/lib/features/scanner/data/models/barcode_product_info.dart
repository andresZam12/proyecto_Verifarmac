// Resultado de una búsqueda de producto por código de barras en una base
// genérica (Open Food Facts, UPCItemDB, etc.). Además del nombre guarda la
// categoría cuando la fuente la entrega, para poder distinguir si lo
// escaneado es un medicamento/producto natural o algo fuera del alcance
// de la app (electrónica, aseo, alimentos, etc.).
class BarcodeProductInfo {
  const BarcodeProductInfo({required this.name, this.category});

  final String  name;
  final String? category;
}
