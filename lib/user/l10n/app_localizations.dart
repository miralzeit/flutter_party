import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  const AppLocalizations._({
    required this.locale,
    required Map<String, dynamic> translations,
    required Map<String, dynamic> fallbackTranslations,
  }) : _translations = translations,
       _fallbackTranslations = fallbackTranslations;

  final Locale locale;
  final Map<String, dynamic> _translations;
  final Map<String, dynamic> _fallbackTranslations;

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations was not found.');
    return localizations!;
  }

  static bool isRtl(Locale locale) {
    return const {'ar', 'fa', 'he', 'ur'}.contains(locale.languageCode);
  }

  TextDirection get textDirection =>
      isRtl(locale) ? TextDirection.rtl : TextDirection.ltr;

  String t(String key, [Map<String, Object?> params = const {}]) {
    final value =
        _lookup(_translations, key) ?? _lookup(_fallbackTranslations, key);
    if (value is! String) return key;
    return _interpolate(value, params);
  }

  Object? _lookup(Map<String, dynamic> source, String key) {
    Object? current = source;
    for (final part in key.split('.')) {
      if (current is! Map<String, dynamic>) return null;
      current = current[part];
    }
    return current;
  }

  String _interpolate(String value, Map<String, Object?> params) {
    var result = value;
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value.toString());
    }
    return result;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final languageCode = _supportedLanguageCode(locale.languageCode);
    final fallbackTranslations = await _loadJson('en');
    final translations = languageCode == 'en'
        ? fallbackTranslations
        : await _loadJson(languageCode);
    return AppLocalizations._(
      locale: Locale(languageCode),
      translations: translations,
      fallbackTranslations: fallbackTranslations,
    );
  }

  static String _supportedLanguageCode(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode)
        ? languageCode
        : 'en';
  }

  static Future<Map<String, dynamic>> _loadJson(String languageCode) async {
    final jsonText = await rootBundle.loadString(
      'assets/locales/$languageCode.json',
    );
    return Map<String, dynamic>.from(jsonDecode(jsonText) as Map);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String tr(String key, [Map<String, Object?> params = const {}]) {
    return l10n.t(key, params);
  }
}
