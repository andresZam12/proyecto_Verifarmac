// Contrato del repositorio de historial.

import '../entities/history_entry.dart';

abstract class IHistoryRepository {
  // Guarda un escaneo en el historial local
  Future<void> save(HistoryEntry entry);

  // Obtiene el historial local paginado
  Future<List<HistoryEntry>> fetch({int page = 0, int pageSize = 20});

  // Elimina una entrada del historial
  Future<void> delete(String id);

  // Elimina todo el historial
  Future<void> deleteAll();

  // Sincroniza el historial local con Supabase
  Future<void> sync(String userId);

  // Descarga el historial del usuario desde Supabase y lo combina con el local
  // (ej: al iniciar sesión en un dispositivo nuevo o tras reinstalar la app)
  Future<void> pullRemote(String userId);

  // Obtiene conteo de escaneos por estado (para el dashboard)
  Future<Map<String, int>> getStatistics();
}
