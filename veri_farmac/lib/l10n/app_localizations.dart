import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  // ── General ────────────────────────────────────────────────
  String get home;
  String get settings;
  String get cancel;
  String get delete;
  String get version;
  String get all;

  // ── Auth ───────────────────────────────────────────────────
  String get welcome;
  String get signInSubtitle;
  String get signOut;
  String get confirmSignOut;

  // ── Dashboard ──────────────────────────────────────────────
  String get scanSummary;
  String get total;
  String get valid;
  String get expired;
  String get distribution;
  String get noScansYet;
  String get scanMedicine;

  // ── Scanner ────────────────────────────────────────────────
  String get scan;
  String get aimAtBarcode;
  String get aimAtPackageText;
  String get analyzing;
  String get scanModeBarcode;
  String get scanModeOcr;

  // ── Medicine detail ────────────────────────────────────────
  String get result;
  String get consultingInvima;
  String get medicineNotFound;
  String get medicineNotFoundDesc;
  String get sanitaryRecord;
  String get code;
  String get status;
  String get laboratory;
  String get holder;
  String get medicineInfo;
  String get activeIngredient;
  String get concentration;
  String get pharmaceuticalForm;
  String get unsafeMedicineWarning;

  // ── History ────────────────────────────────────────────────
  String get history;
  String get loadingHistory;
  String get noRecords;
  String get scannedMedicinesHere;
  String get deleteRecord;
  String get confirmDeleteRecord;
  String get filterValid;
  String get filterExpired;
  String get filterInvalid;
  String get filterSuspicious;

  // ── Settings ───────────────────────────────────────────────
  String get account;
  String get profile;
  String get viewEditProfile;
  String get appearance;
  String get themeLabel;
  String get themeLight;
  String get themeDark;
  String get themeSystem;
  String get language;
  String get chooseLanguage;
  String get spanish;
  String get english;
  String get about;

  // ── Map ────────────────────────────────────────────────────
  String get nearbyPharmacies;
  String get gettingLocation;
  String get locationPermissionNeeded;
  String get allowLocation;
}

// Atajo: context.l10n en lugar de AppLocalizations.of(context)!
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }
  throw FlutterError('Unsupported locale: $locale');
}
