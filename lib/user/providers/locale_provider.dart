import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

const _localePreferenceKey = 'eventflow.locale';

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>((
  ref,
) {
  return AppLocaleNotifier()..loadSavedLocale();
});

class AppLocaleNotifier extends StateNotifier<Locale> {
  AppLocaleNotifier() : super(_deviceOrFallbackLocale());

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_localePreferenceKey);
    if (savedLanguageCode == null || savedLanguageCode.isEmpty) return;
    state = _supportedLocale(savedLanguageCode);
  }

  Future<void> setLocale(Locale locale) async {
    final nextLocale = _supportedLocale(locale.languageCode);
    state = nextLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePreferenceKey, nextLocale.languageCode);
  }
}

Locale _deviceOrFallbackLocale() {
  final deviceLocale = ui.PlatformDispatcher.instance.locale;
  return _supportedLocale(deviceLocale.languageCode);
}

Locale _supportedLocale(String languageCode) {
  return AppLocalizations.supportedLocales.firstWhere(
    (locale) => locale.languageCode == languageCode,
    orElse: () => const Locale('en'),
  );
}
