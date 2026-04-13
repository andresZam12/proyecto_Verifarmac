// Constantes de texto de la aplicación.
// Todas las cadenas hardcodeadas de la UI deben declararse aquí.
// El código llama a la constante — nunca repite el string directamente.

// ignore_for_file: constant_identifier_names

class AppStrings {
  AppStrings._();

  // ─── App ───────────────────────────────────────────────────
  static const appName    = 'VeriFarmac';
  static const appTagline = 'Verificación de medicamentos';

  // ─── General ───────────────────────────────────────────────
  static const retry  = 'Reintentar';
  static const cancel = 'Cancelar';
  static const delete = 'Eliminar';

  // ─── Auth ──────────────────────────────────────────────────
  static const welcome            = 'Bienvenido';
  static const signInSubtitle     = 'Inicia sesión para verificar\ntus medicamentos';
  static const continueWithGoogle = 'Continuar con Google';
  static const signOut            = 'Cerrar sesión';
  static const confirmSignOut     = '¿Seguro que quieres cerrar sesión?';

  // ─── Dashboard ─────────────────────────────────────────────
  static const home        = 'Inicio';
  static const scanSummary = 'Resumen de escaneos';
  static const total       = 'Total';
  static const distribution = 'Distribución';
  static const noScansYet  = 'Sin escaneos aún';
  static const scanMedicine = 'Escanear medicamento';

  // ─── Scanner ───────────────────────────────────────────────
  static const scan             = 'Escanear';
  static const aimAtBarcode     = 'Apunta al código de barras';
  static const aimAtPackageText = 'Apunta al texto del empaque';
  static const analyzing        = 'Analizando...';
  static const scanModeBarcode  = 'Código';
  static const scanModeOcr      = 'Texto';

  // ─── History ───────────────────────────────────────────────
  static const history                 = 'Historial';
  static const loadingHistory          = 'Cargando historial...';
  static const noRecords               = 'Sin registros';
  static const scannedMedicinesHere    = 'Los medicamentos escaneados aparecerán aquí';
  static const deleteRecord            = 'Eliminar registro';
  static const confirmDeleteRecord     = '¿Seguro que quieres eliminar este registro?';
  static const all                     = 'Todos';

  // ─── Medicine detail ───────────────────────────────────────
  static const result              = 'Resultado';
  static const consultingInvima    = 'Consultando INVIMA...';
  static const medicineNotFound    = 'Medicamento no encontrado';
  static const medicineNotFoundDesc = 'No se encontró información en la base de datos del INVIMA.';
  static const sanitaryRecord      = 'Registro sanitario';
  static const code                = 'Código';
  static const status              = 'Estado';
  static const laboratory          = 'Laboratorio';
  static const holder              = 'Titular';
  static const medicineInfo        = 'Información del medicamento';
  static const activeIngredient    = 'Principio activo';
  static const concentration       = 'Concentración';
  static const pharmaceuticalForm  = 'Forma';
  static const unsafeMedicineWarning =
      'Este medicamento no debería comercializarse. Reporta este caso al INVIMA.';

  // ─── Medicine condition labels ─────────────────────────────
  static const conditionValid      = 'Vigente';
  static const conditionExpired    = 'Vencido';
  static const conditionInvalid    = 'Inválido';
  static const conditionSuspicious = 'Sospechoso';
  static const conditionUnknown    = 'Desconocido';

  // ─── History filter labels ─────────────────────────────────
  static const filterValid      = 'Vigentes';
  static const filterExpired    = 'Vencidos';
  static const filterInvalid    = 'Inválidos';
  static const filterSuspicious = 'Sospechosos';

  // ─── Map ───────────────────────────────────────────────────
  static const nearbyPharmacies         = 'Farmacias cercanas';
  static const locationPermissionNeeded = 'Se necesita acceso a tu ubicación';
  static const allowLocation            = 'Permitir ubicación';
  static const gettingLocation          = 'Obteniendo ubicación...';

  // ─── Settings ──────────────────────────────────────────────
  static const settings       = 'Ajustes';
  static const account        = 'Cuenta';
  static const profile        = 'Perfil';
  static const viewEditProfile = 'Ver y editar tu información';
  static const appearance     = 'Apariencia';
  static const language       = 'Idioma';
  static const about          = 'Acerca de';
  static const version        = 'Versión';
  static const themeLabel     = 'Tema';
  static const themeLight     = 'Claro';
  static const themeDark      = 'Oscuro';
  static const themeSystem    = 'Seguir el sistema';
  static const chooseLanguage = 'Elige tu idioma';
  static const spanish        = 'Español';
  static const english        = 'English';

  // ─── Offline ───────────────────────────────────────────────
  static const noInternet = 'Sin conexión a internet';

  // ─── Errors (internos — no muestran al usuario) ────────────
  static const errorLoadingStats    = 'Error al cargar estadísticas';
  static const errorLoadingHistory  = 'Error al cargar el historial';
  static const errorSignIn          = 'Error al iniciar sesión.';
  static const errorSignOut         = 'Error al cerrar sesión.';
  static const errorProcessBarcode  = 'Error al procesar el código';
  static const errorProcessText     = 'Error al procesar el texto';
  static const errorAnalyzeImage    = 'Error al analizar la imagen';
  static const errorGetLocation     = 'Error al obtener ubicación';
  static const errorDeleting        = 'Error al eliminar';

  // ─── SharedPreferences keys ────────────────────────────────
  static const prefThemeKey  = 'app_theme';
  static const prefLocaleKey = 'app_locale';
  static const prefHistoryKey = 'scan_history';
}
