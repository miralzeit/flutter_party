import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultCurrencySettingsEndpoint = String.fromEnvironment(
  'CURRENCY_SETTINGS_ENDPOINT',
  defaultValue: '/api/user/profile',
);

const bool skipCurrencyBackend = bool.fromEnvironment(
  'SKIP_CURRENCY_BACKEND',
  defaultValue: false,
);
const bool skipProfileBackendForCurrency = bool.fromEnvironment(
  'SKIP_PROFILE_BACKEND',
  defaultValue: false,
);
const bool skipCreateEventBackendForCurrency = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class CurrencySettingsApiException implements Exception {
  const CurrencySettingsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CurrencySettingsApiService {
  CurrencySettingsApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.currencySettingsEndpoint = defaultCurrencySettingsEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String currencySettingsEndpoint;
  final http.Client _httpClient;

  Future<void> updateCurrency(String currencyCode) async {
    if (skipCurrencyBackend ||
        skipProfileBackendForCurrency ||
        skipCreateEventBackendForCurrency) {
      return;
    }

    try {
      final response = await _httpClient
          .put(
            _buildUri(currencySettingsEndpoint),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'currency': currencyCode}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CurrencySettingsApiException(
          'Currency update failed with status ${response.statusCode}.',
        );
      }
    } on TimeoutException {
      throw const CurrencySettingsApiException('Currency update timed out.');
    } on http.ClientException {
      throw const CurrencySettingsApiException(
        'Could not connect to the currency settings backend.',
      );
    }
  }

  Uri _buildUri(String endpoint) {
    final base = Uri.parse(baseUrl);
    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final path = '${_trimTrailingSlash(base.path)}$normalizedEndpoint';
    return base.replace(path: path, queryParameters: base.queryParameters);
  }
}

String _trimTrailingSlash(String value) {
  if (value.endsWith('/')) return value.substring(0, value.length - 1);
  return value;
}
