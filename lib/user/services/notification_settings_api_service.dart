import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultNotificationSettingsEndpoint = String.fromEnvironment(
  'NOTIFICATION_SETTINGS_ENDPOINT',
  defaultValue: '/api/user/notifications',
);

class NotificationPreferences {
  const NotificationPreferences({
    required this.pushNotifications,
    required this.emailSummaries,
    required this.quoteSubmission,
    required this.productFeatures,
  });

  final bool pushNotifications;
  final bool emailSummaries;
  final bool quoteSubmission;
  final bool productFeatures;

  NotificationPreferences copyWith({
    bool? pushNotifications,
    bool? emailSummaries,
    bool? quoteSubmission,
    bool? productFeatures,
  }) {
    return NotificationPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailSummaries: emailSummaries ?? this.emailSummaries,
      quoteSubmission: quoteSubmission ?? this.quoteSubmission,
      productFeatures: productFeatures ?? this.productFeatures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'emailSummaries': emailSummaries,
      'quoteSubmission': quoteSubmission,
      'productFeatures': productFeatures,
    };
  }

  factory NotificationPreferences.fromJson(
    Map<String, dynamic> json,
    NotificationPreferences fallback,
  ) {
    return NotificationPreferences(
      pushNotifications: _boolValue(json, [
        'pushNotifications',
        'push',
        'mobileAlerts',
      ], fallback.pushNotifications),
      emailSummaries: _boolValue(json, [
        'emailSummaries',
        'email',
        'dailySummaries',
      ], fallback.emailSummaries),
      quoteSubmission: _boolValue(json, [
        'quoteSubmission',
        'vendorQuotes',
        'quoteAlerts',
      ], fallback.quoteSubmission),
      productFeatures: _boolValue(json, [
        'productFeatures',
        'platformUpdates',
        'featureUpdates',
      ], fallback.productFeatures),
    );
  }
}

class NotificationSettingsApiException implements Exception {
  const NotificationSettingsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NotificationSettingsApiService {
  NotificationSettingsApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.notificationSettingsEndpoint = defaultNotificationSettingsEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String notificationSettingsEndpoint;
  final http.Client _httpClient;

  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    final response = await _putJson(
      _buildUri(notificationSettingsEndpoint),
      preferences.toJson(),
    );
    final decoded = _decodeObject(response.body);
    final settingsJson = decoded['notifications'] is Map
        ? Map<String, dynamic>.from(decoded['notifications'] as Map)
        : decoded['preferences'] is Map
        ? Map<String, dynamic>.from(decoded['preferences'] as Map)
        : decoded;
    if (settingsJson.isEmpty) return preferences;
    return NotificationPreferences.fromJson(settingsJson, preferences);
  }

  Future<http.Response> _putJson(Uri uri, Map<String, dynamic> body) async {
    try {
      final response = await _httpClient
          .put(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NotificationSettingsApiException(
          'Notification settings update failed with status ${response.statusCode}.',
        );
      }
      return response;
    } on TimeoutException {
      throw const NotificationSettingsApiException(
        'Notification settings request timed out.',
      );
    } on FormatException {
      throw const NotificationSettingsApiException(
        'Notification settings response was not valid JSON.',
      );
    } on http.ClientException {
      throw const NotificationSettingsApiException(
        'Could not connect to the notification settings backend.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const FormatException('Expected JSON object');
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

bool _boolValue(Map<String, dynamic> json, List<String> keys, bool fallback) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
  }
  return fallback;
}
