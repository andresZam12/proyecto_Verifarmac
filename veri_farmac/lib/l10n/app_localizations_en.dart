// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  // ── General ────────────────────────────────────────────────
  @override String get home              => 'Home';
  @override String get settings          => 'Settings';
  @override String get cancel            => 'Cancel';
  @override String get delete            => 'Delete';
  @override String get version           => 'Version 1.0.0';
  @override String get all               => 'All';

  // ── Auth ───────────────────────────────────────────────────
  @override String get welcome           => 'Welcome to VeriFarmac';
  @override String get signInSubtitle    => 'Verify Colombian medicines quickly and safely';
  @override String get signOut           => 'Sign out';
  @override String get confirmSignOut    => 'Do you want to sign out?';

  // ── Dashboard ──────────────────────────────────────────────
  @override String get scanSummary       => 'Scan summary';
  @override String get total             => 'Total';
  @override String get valid             => 'Valid';
  @override String get expired           => 'Expired';
  @override String get distribution      => 'Distribution';
  @override String get noScansYet        => 'No scans yet';
  @override String get scanMedicine      => 'Scan medicine';

  // ── Scanner ────────────────────────────────────────────────
  @override String get scan              => 'Scan';
  @override String get aimAtBarcode      => 'Aim at the barcode';
  @override String get aimAtPackageText  => 'Aim at the package text';
  @override String get analyzing         => 'Analyzing...';
  @override String get scanModeBarcode   => 'Barcode';
  @override String get scanModeOcr       => 'OCR text';

  // ── Medicine detail ────────────────────────────────────────
  @override String get result            => 'Result';
  @override String get consultingInvima  => 'Consulting INVIMA...';
  @override String get medicineNotFound  => 'Medicine not found';
  @override String get medicineNotFoundDesc => 'No INVIMA information was found for this code.';
  @override String get sanitaryRecord    => 'Sanitary record';
  @override String get code              => 'Code';
  @override String get status            => 'Status';
  @override String get laboratory        => 'Laboratory';
  @override String get holder            => 'Holder';
  @override String get medicineInfo      => 'Medicine information';
  @override String get activeIngredient  => 'Active ingredient';
  @override String get concentration     => 'Concentration';
  @override String get pharmaceuticalForm => 'Pharmaceutical form';
  @override String get unsafeMedicineWarning =>
      'This medicine should not be sold. Please report this case to INVIMA.';

  // ── History ────────────────────────────────────────────────
  @override String get history           => 'History';
  @override String get loadingHistory    => 'Loading history...';
  @override String get noRecords         => 'No records';
  @override String get scannedMedicinesHere => 'Scanned medicines will appear here';
  @override String get deleteRecord      => 'Delete record';
  @override String get confirmDeleteRecord => 'Delete this record from history?';
  @override String get filterValid       => 'Valid';
  @override String get filterExpired     => 'Expired';
  @override String get filterInvalid     => 'Invalid';
  @override String get filterSuspicious  => 'Suspicious';

  // ── Settings ───────────────────────────────────────────────
  @override String get account           => 'Account';
  @override String get profile           => 'Profile';
  @override String get viewEditProfile   => 'View and edit profile';
  @override String get appearance        => 'Appearance';
  @override String get themeLabel        => 'Theme';
  @override String get themeLight        => 'Light';
  @override String get themeDark         => 'Dark';
  @override String get themeSystem       => 'System';
  @override String get language          => 'Language';
  @override String get chooseLanguage    => 'Choose your language';
  @override String get spanish           => 'Español';
  @override String get english           => 'English';
  @override String get about             => 'About';

  // ── Map ────────────────────────────────────────────────────
  @override String get nearbyPharmacies       => 'Nearby pharmacies';
  @override String get gettingLocation        => 'Getting location...';
  @override String get locationPermissionNeeded => 'Location permission is needed to show nearby pharmacies';
  @override String get allowLocation          => 'Allow location';
}
