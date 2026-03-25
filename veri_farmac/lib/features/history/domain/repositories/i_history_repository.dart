// Contrato del repositorio de historial.
// TODO: definir saveEntry, getLocalHistory, syncToCloud, deleteEntry, getStats

import '../entities/history_entry.dart';

// Contrato que define qué puede hacer el repositorio del historial.
abstract class IHistoryRepository {
  // Guarda un escaneo en el historial local (SQLite)
  Future<void> guardar(HistoryEntry entrada);

  // Obtiene el historial local paginado
  Future<List<HistoryEntry>> obtener({int pagina = 0, int porPagina = 20});

  // Elimina una entrada del historial
  Future<void> eliminar(String id);

  // Sincroniza el historial local con Supabase
  Future<void> sincronizar(String userId);

  // Obtiene conteo de escaneos por estado (para el dashboard)
  Future<Map<String, int>> obtenerEstadisticas();
}