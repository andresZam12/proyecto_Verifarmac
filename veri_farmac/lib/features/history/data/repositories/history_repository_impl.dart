// Implementación del repositorio de historial.
// TODO: coordinar local (Drift) y remoto (Supabase)

import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/i_history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../datasources/history_remote_datasource.dart';
import '../models/history_entry_model.dart';

// Coordina el historial local (SharedPreferences) y remoto (Supabase).
// Estrategia: guarda siempre en local primero, sincroniza con Supabase después.
class HistoryRepositoryImpl implements IHistoryRepository {
  const HistoryRepositoryImpl(this._local, this._remoto);

  final HistoryLocalDataSource  _local;
  final HistoryRemoteDataSource _remoto;

  @override
  Future<void> guardar(HistoryEntry entrada) async {
    // Convierte la entidad a modelo para guardarlo
    final modelo = HistoryEntryModel(
      id:                entrada.id,
      nombreMedicamento: entrada.nombreMedicamento,
      registroSanitario: entrada.registroSanitario,
      estado:            entrada.estado,
      metodo:            entrada.metodo,
      creadoEn:          entrada.creadoEn,
      laboratorio:       entrada.laboratorio,
      confianza:         entrada.confianza,
      sincronizado:      false, // siempre empieza como no sincronizado
    );

    // Guarda primero en local
    await _local.guardar(modelo);

    // Intenta subir a Supabase — si falla, se sincronizará después
    try {
      await _remoto.subirEntradas([modelo]);
      await _local.marcarSincronizado(entrada.id);
    } catch (_) {
      // Sin conexión — se sincronizará cuando vuelva internet
    }
  }

  @override
  Future<List<HistoryEntry>> obtener({int pagina = 0, int porPagina = 20}) {
    return _local.obtener(pagina: pagina, porPagina: porPagina);
  }

  @override
  Future<void> eliminar(String id) async {
    await _local.eliminar(id);
    try {
      await _remoto.eliminar(id);
    } catch (_) {
      // Si falla en remoto, al menos se eliminó localmente
    }
  }

  @override
  Future<void> sincronizar(String userId) async {
    try {
      // Obtiene los registros que aún no se han subido
      final noSincronizados = await _local.obtenerNoSincronizados();

      if (noSincronizados.isEmpty) return;

      // Los sube a Supabase
      await _remoto.subirEntradas(noSincronizados);

      // Los marca como sincronizados en local
      for (final entrada in noSincronizados) {
        await _local.marcarSincronizado(entrada.id);
      }
    } catch (_) {
      // Sin conexión — se intentará de nuevo más tarde
    }
  }

  @override
  Future<Map<String, int>> obtenerEstadisticas() {
    return _local.obtenerEstadisticas();
  }
}