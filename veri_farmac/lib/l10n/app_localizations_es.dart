// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  // ── General ────────────────────────────────────────────────
  @override String get home              => 'Inicio';
  @override String get settings          => 'Configuración';
  @override String get cancel            => 'Cancelar';
  @override String get delete            => 'Eliminar';
  @override String get version           => 'Versión 1.0.0';
  @override String get all               => 'Todos';

  // ── Auth ───────────────────────────────────────────────────
  @override String get welcome           => 'Bienvenido a VeriFarmac';
  @override String get signInSubtitle    => 'Verifica medicamentos colombianos de forma rápida y segura';
  @override String get signOut           => 'Cerrar sesión';
  @override String get confirmSignOut    => '¿Deseas cerrar sesión?';

  // ── Dashboard ──────────────────────────────────────────────
  @override String get scanSummary       => 'Resumen de escaneos';
  @override String get total             => 'Total';
  @override String get valid             => 'Vigentes';
  @override String get expired           => 'Vencidos';
  @override String get distribution      => 'Distribución';
  @override String get noScansYet        => 'Sin escaneos aún';
  @override String get scanMedicine      => 'Escanear medicamento';

  // ── Scanner ────────────────────────────────────────────────
  @override String get scan              => 'Escanear';
  @override String get aimAtBarcode      => 'Apunta al código de barras';
  @override String get aimAtPackageText  => 'Apunta al texto del empaque';
  @override String get analyzing         => 'Analizando...';
  @override String get scanModeBarcode   => 'Código de barras';
  @override String get scanModeOcr       => 'Texto OCR';

  // ── Medicine detail ────────────────────────────────────────
  @override String get result            => 'Resultado';
  @override String get consultingInvima  => 'Consultando INVIMA...';
  @override String get medicineNotFound  => 'Medicamento no encontrado';
  @override String get medicineNotFoundDesc => 'No se encontró información en el INVIMA para este código.';
  @override String get sanitaryRecord    => 'Registro sanitario';
  @override String get code              => 'Código';
  @override String get status            => 'Estado';
  @override String get laboratory        => 'Laboratorio';
  @override String get holder            => 'Titular';
  @override String get medicineInfo      => 'Información del medicamento';
  @override String get activeIngredient  => 'Principio activo';
  @override String get concentration     => 'Concentración';
  @override String get pharmaceuticalForm => 'Forma farmacéutica';
  @override String get unsafeMedicineWarning =>
      'Este medicamento no debería comercializarse. Reporta este caso al INVIMA.';

  // ── History ────────────────────────────────────────────────
  @override String get history           => 'Historial';
  @override String get loadingHistory    => 'Cargando historial...';
  @override String get noRecords         => 'Sin registros';
  @override String get scannedMedicinesHere => 'Los medicamentos escaneados aparecerán aquí';
  @override String get deleteRecord      => 'Eliminar registro';
  @override String get confirmDeleteRecord => '¿Eliminar este registro del historial?';
  @override String get filterValid       => 'Vigente';
  @override String get filterExpired     => 'Vencido';
  @override String get filterInvalid     => 'Inválido';
  @override String get filterSuspicious  => 'Sospechoso';

  // ── Settings ───────────────────────────────────────────────
  @override String get account           => 'Cuenta';
  @override String get profile           => 'Perfil';
  @override String get viewEditProfile   => 'Ver y editar perfil';
  @override String get appearance        => 'Apariencia';
  @override String get themeLabel        => 'Tema';
  @override String get themeLight        => 'Claro';
  @override String get themeDark         => 'Oscuro';
  @override String get themeSystem       => 'Sistema';
  @override String get language          => 'Idioma';
  @override String get chooseLanguage    => 'Elige tu idioma';
  @override String get spanish           => 'Español';
  @override String get english           => 'English';
  @override String get about             => 'Acerca de';

  // ── Map ────────────────────────────────────────────────────
  @override String get nearbyPharmacies       => 'Farmacias cercanas';
  @override String get gettingLocation        => 'Obteniendo ubicación...';
  @override String get locationPermissionNeeded => 'Se necesita permiso de ubicación para mostrar farmacias cercanas';
  @override String get allowLocation          => 'Permitir ubicación';
}
