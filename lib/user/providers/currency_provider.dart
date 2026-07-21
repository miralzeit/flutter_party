import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/currency_settings_api_service.dart';

const _currencyPreferenceKey = 'eventflow.currency';
const supportedCurrencyCodes = ['USD', 'ILS', 'EUR'];

final currencySettingsApiServiceProvider = Provider<CurrencySettingsApiService>(
  (ref) => CurrencySettingsApiService(),
);

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier(ref)..loadSavedCurrency();
});

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier(this._ref) : super(_deviceCurrencyOrFallback());

  final Ref _ref;

  Future<void> loadSavedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString(_currencyPreferenceKey);
    if (savedCurrency == null || savedCurrency.isEmpty) return;
    state = _supportedCurrency(savedCurrency);
  }

  Future<void> setCurrency(
    String currencyCode, {
    bool syncBackend = true,
  }) async {
    final nextCurrency = _supportedCurrency(currencyCode);
    state = nextCurrency;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyPreferenceKey, nextCurrency);

    if (!syncBackend) return;
    await _ref
        .read(currencySettingsApiServiceProvider)
        .updateCurrency(nextCurrency);
  }
}

String _deviceCurrencyOrFallback() {
  final countryCode = ui.PlatformDispatcher.instance.locale.countryCode;
  if (countryCode == 'IL' || countryCode == 'PS') return 'ILS';
  return 'USD';
}

String _supportedCurrency(String currencyCode) {
  final normalized = currencyCode.trim().toUpperCase();
  return supportedCurrencyCodes.contains(normalized) ? normalized : 'USD';
}
