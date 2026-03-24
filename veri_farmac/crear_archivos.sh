#!/bin/bash
# Ejecutar desde la RAÍZ del proyecto (donde está pubspec.yaml)
# bash crear_archivos.sh

echo "Creando archivos del proyecto FarmaCheck..."

# ============================================================
# LIB/ — archivos raíz
# ============================================================
cat > lib/main.dart << 'EOF'
// Punto de entrada de la aplicación.
// TODO: configurar Supabase, Riverpod, i18n y tema
EOF

cat > lib/injection_container.dart << 'EOF'
// Inyección de dependencias con get_it + injectable.
// TODO: configurar get_it y registrar dependencias
EOF

# ============================================================
# CORE/DATABASE
# ============================================================
cat > lib/core/database/app_database.dart << 'EOF'
// Base de datos local con Drift (SQLite).
// TODO: definir tablas y configurar la conexión
EOF

# ============================================================
# CORE/ERROR
# ============================================================
cat > lib/core/error/failure.dart << 'EOF'
// Clases de fallo que retorna el dominio.
// TODO: definir NetworkFailure, ServerFailure, NotFoundFailure, etc.
EOF

cat > lib/core/error/exceptions.dart << 'EOF'
// Excepciones internas de la capa de datos.
// TODO: definir ServerException, CacheException, NetworkException, etc.
EOF

# ============================================================
# CORE/NETWORK
# ============================================================
cat > lib/core/network/dio_client.dart << 'EOF'
// Cliente HTTP central con Dio.
// TODO: configurar baseUrl, timeouts e interceptors
EOF

cat > lib/core/network/network_info.dart << 'EOF'
// Verifica si hay conexión a internet.
// TODO: implementar con connectivity_plus
EOF

cat > lib/core/network/interceptors/auth_interceptor.dart << 'EOF'
// Agrega el token de Supabase a cada request.
// TODO: leer el token de la sesión activa e inyectarlo en el header
EOF

cat > lib/core/network/interceptors/retry_interceptor.dart << 'EOF'
// Reintenta requests fallidos por red (máx 2 intentos).
// TODO: detectar errores de conexión y reintentar
EOF

# ============================================================
# CORE/PROVIDERS
# ============================================================
cat > lib/core/providers/theme_provider.dart << 'EOF'
// Maneja ThemeMode (light / dark / system) con Riverpod.
// TODO: implementar ThemeNotifier y LocaleNotifier con SharedPreferences
EOF

# ============================================================
# CORE/ROUTER
# ============================================================
cat > lib/core/router/app_router.dart << 'EOF'
// Navegación central con go_router.
// TODO: definir todas las rutas y el redirect de autenticación
EOF

# ============================================================
# CORE/THEME
# ============================================================
cat > lib/core/theme/app_theme.dart << 'EOF'
// Temas light y dark de la aplicación.
// TODO: definir AppColors, AppTheme.light y AppTheme.dark
EOF

# ============================================================
# CORE/UTILS/EXTENSIONS
# ============================================================
cat > lib/core/utils/extensions/string_extensions.dart << 'EOF'
// Extensiones útiles para String.
// TODO: capitalized, extractedRegistryCode, truncate
EOF

cat > lib/core/utils/extensions/datetime_extensions.dart << 'EOF'
// Extensiones para DateTime.
// TODO: shortDate, relativeDay, isExpired
EOF

cat > lib/core/utils/extensions/context_extensions.dart << 'EOF'
// Extensiones sobre BuildContext.
// TODO: theme, colors, isDark, screenSize, showSnack
EOF

# ============================================================
# L10N — traducciones
# ============================================================
cat > lib/l10n/app_es.arb << 'EOF'
{
  "@@locale": "es"
}
EOF

cat > lib/l10n/app_en.arb << 'EOF'
{
  "@@locale": "en"
}
EOF

# ============================================================
# SHARED/WIDGETS
# ============================================================
cat > lib/shared/widgets/app_loading.dart << 'EOF'
// Indicador de carga reutilizable.
// TODO: implementar variantes spinner, shimmer y overlay
EOF

cat > lib/shared/widgets/app_error_widget.dart << 'EOF'
// Widget de error con botón de reintentar.
// TODO: implementar con ícono, mensaje y callback onRetry
EOF

cat > lib/shared/widgets/app_empty_state.dart << 'EOF'
// Estado vacío reutilizable (historial vacío, sin resultados).
// TODO: implementar con ilustración, título y acción opcional
EOF

cat > lib/shared/widgets/offline_banner.dart << 'EOF'
// Banner que aparece cuando no hay conexión.
// TODO: implementar con connectivity_plus y MaterialBanner
EOF

cat > lib/shared/widgets/confidence_bar.dart << 'EOF'
// Barra animada que muestra el porcentaje de confianza del análisis IA.
// TODO: implementar con flutter_animate
EOF

# ============================================================
# SHARED/EXTENSIONS
# ============================================================
cat > lib/shared/extensions/extensions.dart << 'EOF'
// Barrel export de todas las extensiones del proyecto.
// TODO: exportar string_extensions, datetime_extensions y context_extensions
EOF

# ============================================================
# FEATURE: SPLASH
# ============================================================
cat > lib/features/splash/presentation/pages/splash_page.dart << 'EOF'
// Pantalla de splash con animación.
// TODO: animar logo, verificar sesión y navegar a login o home
EOF

# ============================================================
# FEATURE: AUTH
# ============================================================

# domain
cat > lib/features/auth/domain/entities/app_user.dart << 'EOF'
// Entidad de usuario — Dart puro, sin dependencias externas.
// TODO: definir id, email, displayName, avatarUrl, pharmacyId
EOF

cat > lib/features/auth/domain/repositories/i_auth_repository.dart << 'EOF'
// Contrato del repositorio de autenticación.
// TODO: definir signInWithGoogle, signOut, authStateChanges, currentUser
EOF

cat > lib/features/auth/domain/usecases/sign_in_with_google_usecase.dart << 'EOF'
// Caso de uso: iniciar sesión con Google.
// TODO: llamar a IAuthRepository.signInWithGoogle()
EOF

cat > lib/features/auth/domain/usecases/sign_out_usecase.dart << 'EOF'
// Caso de uso: cerrar sesión.
// TODO: llamar a IAuthRepository.signOut()
EOF

# data
cat > lib/features/auth/data/datasources/auth_remote_datasource.dart << 'EOF'
// Datasource de autenticación con Supabase Auth.
// TODO: implementar signInWithGoogle, signOut y authStateChanges
EOF

cat > lib/features/auth/data/models/app_user_model.dart << 'EOF'
// Modelo de usuario con serialización JSON.
// TODO: implementar fromJson y toJson, extender AppUser
EOF

cat > lib/features/auth/data/repositories/auth_repository_impl.dart << 'EOF'
// Implementación del repositorio de auth.
// TODO: conectar datasource con dominio, convertir excepciones a Failure
EOF

# presentation
cat > lib/features/auth/presentation/pages/login_page.dart << 'EOF'
// Pantalla de login con Google.
// TODO: diseñar UI con logo, tagline y botón GoogleSignInButton
EOF

cat > lib/features/auth/presentation/widgets/google_sign_in_button.dart << 'EOF'
// Botón de "Continuar con Google".
// TODO: diseñar con logo de Google, texto y estado de carga
EOF

cat > lib/features/auth/presentation/providers/auth_provider.dart << 'EOF'
// Estado de autenticación con Riverpod.
// TODO: implementar AuthNotifier con SignInWithGoogleUseCase
EOF

# ============================================================
# FEATURE: SCANNER
# ============================================================

# domain
cat > lib/features/scanner/domain/entities/scan_result.dart << 'EOF'
// Resultado de un escaneo.
// TODO: definir id, rawValue, method, confidence, scannedAt, medicine
EOF

cat > lib/features/scanner/domain/repositories/i_scanner_repository.dart << 'EOF'
// Contrato del repositorio de escaneo.
// TODO: definir processBarcodeValue, processOcrText, analyzeImage
EOF

cat > lib/features/scanner/domain/usecases/scan_by_barcode_usecase.dart << 'EOF'
// Caso de uso: escanear por código de barras.
// TODO: llamar a IScannerRepository.processBarcodeValue()
EOF

cat > lib/features/scanner/domain/usecases/scan_by_ocr_usecase.dart << 'EOF'
// Caso de uso: escanear por texto OCR.
// TODO: llamar a IScannerRepository.processOcrText()
EOF

cat > lib/features/scanner/domain/usecases/analyze_image_usecase.dart << 'EOF'
// Caso de uso: analizar imagen con Claude API.
// TODO: llamar a IScannerRepository.analyzeImage()
EOF

# data
cat > lib/features/scanner/data/datasources/barcode_datasource.dart << 'EOF'
// Datasource de código de barras con mobile_scanner.
// TODO: implementar stream de barcodes y control de la cámara
EOF

cat > lib/features/scanner/data/datasources/ocr_datasource.dart << 'EOF'
// Datasource de OCR con Google ML Kit.
// TODO: implementar extracción de texto de imagen
EOF

cat > lib/features/scanner/data/datasources/invima_datasource.dart << 'EOF'
// Datasource de consulta al INVIMA (mock o real).
// TODO: implementar findByBarcode, findByRegistryCode, searchByText
EOF

cat > lib/features/scanner/data/datasources/claude_ai_datasource.dart << 'EOF'
// Datasource de análisis visual con Claude API.
// TODO: implementar analyzePackagingImage con la API de Anthropic
EOF

cat > lib/features/scanner/data/models/scan_result_model.dart << 'EOF'
// Modelo de ScanResult con serialización JSON.
// TODO: implementar fromJson y toJson, extender ScanResult
EOF

cat > lib/features/scanner/data/repositories/scanner_repository_impl.dart << 'EOF'
// Implementación del repositorio de escaneo.
// TODO: orquestar barcode + OCR + INVIMA, convertir excepciones a Failure
EOF

# presentation
cat > lib/features/scanner/presentation/pages/scanner_page.dart << 'EOF'
// Pantalla del scanner con cámara y overlay.
// TODO: integrar mobile_scanner, overlay de escaneo y modo barcode/OCR
EOF

cat > lib/features/scanner/presentation/widgets/scanner_overlay.dart << 'EOF'
// Overlay visual sobre la cámara con marco y guías.
// TODO: implementar con CustomPainter
EOF

cat > lib/features/scanner/presentation/widgets/scan_mode_toggle.dart << 'EOF'
// Toggle para cambiar entre modo Barcode y OCR.
// TODO: implementar con SegmentedButton o tabs animados
EOF

cat > lib/features/scanner/presentation/providers/scanner_provider.dart << 'EOF'
// Estado del scanner con Riverpod.
// TODO: implementar ScannerNotifier con modo, estado y resultado
EOF

# ============================================================
# FEATURE: MEDICINE DETAIL
# ============================================================

# domain
cat > lib/features/medicine_detail/domain/entities/medicine.dart << 'EOF'
// Entidad principal de medicamento — Dart puro.
// TODO: definir id, name, sanitaryRecord, laboratory, status, etc.
EOF

cat > lib/features/medicine_detail/domain/repositories/i_medicine_repository.dart << 'EOF'
// Contrato del repositorio de medicamentos.
// TODO: definir getByBarcode, getByOcrText, getByRegistryCode, searchByName
EOF

cat > lib/features/medicine_detail/domain/usecases/get_medicine_usecase.dart << 'EOF'
// Casos de uso: obtener medicamento por barcode u OCR.
// TODO: implementar GetMedicineByBarcodeUseCase y GetMedicineByOcrUseCase
EOF

# data
cat > lib/features/medicine_detail/data/datasources/invima_mock_datasource.dart << 'EOF'
// Mock con medicamentos reales del INVIMA para desarrollo.
// TODO: agregar al menos 10 medicamentos colombianos reales
EOF

cat > lib/features/medicine_detail/data/models/medicine_model.dart << 'EOF'
// Modelo de Medicine con serialización JSON.
// TODO: implementar fromJson y toJson, extender Medicine
EOF

cat > lib/features/medicine_detail/data/repositories/medicine_repository_impl.dart << 'EOF'
// Implementación del repositorio de medicamentos.
// TODO: conectar mock/API de INVIMA con el dominio
EOF

# presentation
cat > lib/features/medicine_detail/presentation/pages/medicine_detail_page.dart << 'EOF'
// Pantalla de resultado del medicamento.
// TODO: mostrar StatusBadge, nombre, registro, laboratorio y detalles
EOF

cat > lib/features/medicine_detail/presentation/widgets/status_badge.dart << 'EOF'
// Badge visual con el estado del medicamento (Vigente, Vencido, etc.).
// TODO: implementar con color semántico según MedicineStatus
EOF

cat > lib/features/medicine_detail/presentation/widgets/medicine_card.dart << 'EOF'
// Card con resumen del medicamento para listas.
// TODO: mostrar nombre, registro, laboratorio y StatusBadge
EOF

cat > lib/features/medicine_detail/presentation/providers/medicine_provider.dart << 'EOF'
// Estado del medicamento actual con Riverpod.
// TODO: implementar MedicineNotifier con GetMedicineUseCase
EOF

# ============================================================
# FEATURE: HISTORY
# ============================================================

# domain
cat > lib/features/history/domain/entities/history_entry.dart << 'EOF'
// Entidad de entrada del historial.
// TODO: definir id, scanResult, pharmacyId, createdAt, latitude, longitude
EOF

cat > lib/features/history/domain/repositories/i_history_repository.dart << 'EOF'
// Contrato del repositorio de historial.
// TODO: definir saveEntry, getLocalHistory, syncToCloud, deleteEntry, getStats
EOF

cat > lib/features/history/domain/usecases/history_usecases.dart << 'EOF'
// Casos de uso del historial.
// TODO: implementar SaveHistoryEntryUseCase, GetHistoryUseCase, DeleteHistoryEntryUseCase
EOF

# data
cat > lib/features/history/data/datasources/history_local_datasource.dart << 'EOF'
// Datasource local con Drift (SQLite).
// TODO: implementar insertEntry, getEntries, deleteEntry, markAsSynced
EOF

cat > lib/features/history/data/datasources/history_remote_datasource.dart << 'EOF'
// Datasource remoto con Supabase.
// TODO: implementar upsertEntries y fetchEntries
EOF

cat > lib/features/history/data/models/history_entry_model.dart << 'EOF'
// Modelo de HistoryEntry con serialización JSON.
// TODO: implementar fromJson y toJson, extender HistoryEntry
EOF

cat > lib/features/history/data/repositories/history_repository_impl.dart << 'EOF'
// Implementación del repositorio de historial.
// TODO: coordinar local (Drift) y remoto (Supabase)
EOF

# presentation
cat > lib/features/history/presentation/pages/history_page.dart << 'EOF'
// Pantalla de historial con lista paginada y filtros.
// TODO: implementar lista, filtros por estado y búsqueda
EOF

cat > lib/features/history/presentation/widgets/history_entry_tile.dart << 'EOF'
// Tile de una entrada del historial.
// TODO: mostrar nombre, StatusBadge, fecha y opción de eliminar
EOF

cat > lib/features/history/presentation/providers/history_provider.dart << 'EOF'
// Estado del historial con Riverpod.
// TODO: implementar HistoryNotifier con paginación y filtros
EOF

# ============================================================
# FEATURE: DASHBOARD
# ============================================================
cat > lib/features/dashboard/domain/usecases/get_stats_usecase.dart << 'EOF'
// Caso de uso: obtener estadísticas del dashboard.
// TODO: llamar a IHistoryRepository.getStats()
EOF

cat > lib/features/dashboard/data/datasources/stats_datasource.dart << 'EOF'
// Datasource de estadísticas desde Supabase o Drift.
// TODO: implementar consultas de conteo por estado
EOF

cat > lib/features/dashboard/data/repositories/stats_repository_impl.dart << 'EOF'
// Implementación del repositorio de estadísticas.
// TODO: conectar datasource con dominio
EOF

cat > lib/features/dashboard/presentation/pages/dashboard_page.dart << 'EOF'
// Pantalla de inicio con estadísticas y acceso rápido.
// TODO: mostrar gráfica donut, conteos y botón de escaneo rápido
EOF

cat > lib/features/dashboard/presentation/widgets/stats_donut_chart.dart << 'EOF'
// Gráfica donut con fl_chart para distribución de estados.
// TODO: implementar con PieChart de fl_chart
EOF

cat > lib/features/dashboard/presentation/widgets/quick_scan_button.dart << 'EOF'
// Botón flotante para abrir el scanner directamente.
// TODO: implementar con FloatingActionButton y animación Hero
EOF

cat > lib/features/dashboard/presentation/providers/dashboard_provider.dart << 'EOF'
// Estado del dashboard con Riverpod.
// TODO: implementar DashboardNotifier con GetDashboardStatsUseCase
EOF

# ============================================================
# FEATURE: MAP
# ============================================================
cat > lib/features/map/domain/usecases/get_location_usecase.dart << 'EOF'
// Caso de uso: obtener ubicación actual.
// TODO: llamar a ILocationRepository.getCurrentPosition()
EOF

cat > lib/features/map/data/datasources/location_datasource.dart << 'EOF'
// Datasource de ubicación con geolocator.
// TODO: implementar getCurrentPosition y requestPermission
EOF

cat > lib/features/map/data/repositories/location_repository_impl.dart << 'EOF'
// Implementación del repositorio de ubicación.
// TODO: conectar geolocator con dominio, manejar permisos
EOF

cat > lib/features/map/presentation/pages/map_page.dart << 'EOF'
// Pantalla del mapa con farmacias cercanas.
// TODO: implementar con google_maps_flutter y marcadores
EOF

cat > lib/features/map/presentation/widgets/pharmacy_marker.dart << 'EOF'
// Marcador personalizado para farmacias en el mapa.
// TODO: implementar con BitmapDescriptor
EOF

cat > lib/features/map/presentation/providers/map_provider.dart << 'EOF'
// Estado del mapa con Riverpod.
// TODO: implementar MapNotifier con GetLocationUseCase
EOF

# ============================================================
# FEATURE: SETTINGS
# ============================================================
cat > lib/features/settings/presentation/pages/settings_page.dart << 'EOF'
// Pantalla principal de ajustes.
// TODO: mostrar secciones de cuenta, apariencia, idioma y acerca de
EOF

cat > lib/features/settings/presentation/pages/language_page.dart << 'EOF'
// Pantalla de selección de idioma (onboarding y settings).
// TODO: mostrar opciones ES/EN con banderas y guardar en SharedPreferences
EOF

cat > lib/features/settings/presentation/pages/theme_settings_page.dart << 'EOF'
// Pantalla para elegir tema: Light, Dark o Sistema.
// TODO: usar ThemeNotifier de core/providers
EOF

cat > lib/features/settings/presentation/pages/profile_page.dart << 'EOF'
// Pantalla de perfil del usuario.
// TODO: mostrar datos de Supabase y opción de cerrar sesión
EOF

cat > lib/features/settings/presentation/widgets/settings_tile.dart << 'EOF'
// Tile reutilizable para cada opción de ajustes.
// TODO: implementar con ícono, título, subtitle, trailing y isDestructive
EOF

cat > lib/features/settings/presentation/providers/settings_provider.dart << 'EOF'
// Re-exporta ThemeNotifier y LocaleNotifier para la pantalla de ajustes.
// TODO: exportar desde core/providers/theme_provider.dart
EOF

# ============================================================
# VERIFICACIÓN FINAL
# ============================================================
echo ""
echo "✓ Archivos creados. Contando..."
echo ""
echo "Archivos .dart: $(find lib -name '*.dart' | wc -l)"
echo "Archivos .arb:  $(find lib -name '*.arb' | wc -l)"
echo ""
echo "Estructura final:"
find lib -type f | sort
