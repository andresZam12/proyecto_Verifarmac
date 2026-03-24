// Base de datos local con Drift (SQLite).
import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart'; // generado por: dart run build_runner build

// ─────────────────────────────────────────
// TABLA: historial de escaneos local
// ─────────────────────────────────────────

// Cada fila representa un medicamento escaneado
class HistorialLocal extends Table {
  // Identificador único del escaneo
  TextColumn get id => text()();

  // Valor crudo leído por el scanner (código o texto)
  TextColumn get valorEscaneado => text()();

  // Método usado: 'barcode', 'ocr' o 'visual'
  TextColumn get metodo => text()();

  // Nombre del medicamento (puede ser null si no se encontró)
  TextColumn get nombreMedicamento => text().nullable()();

  // Código del registro sanitario INVIMA
  TextColumn get registroSanitario => text().nullable()();

  // Estado: 'vigente', 'vencido', 'invalido', 'sospechoso', 'desconocido'
  TextColumn get estado => text()();

  // Porcentaje de confianza del análisis (0.0 a 1.0)
  RealColumn get confianza => real().nullable()();

  // Si ya se sincronizó con Supabase
  BoolColumn get sincronizado =>
      boolean().withDefault(const Constant(false))();

  // Fecha y hora del escaneo
  DateTimeColumn get creadoEn => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────
// BASE DE DATOS
// ─────────────────────────────────────────

@lazySingleton
@DriftDatabase(tables: [HistorialLocal])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  // Versión del esquema — incrementar si se modifica la tabla
  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrirConexion() {
    return SqfliteQueryExecutor.inDatabaseFolder(
      path: 'verifarmac.sqlite',
      logStatements: false, // cambiar a true para depuración
    );
  }
}
