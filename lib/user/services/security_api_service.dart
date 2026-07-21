import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultSecurityEndpoint = String.fromEnvironment(
  'SECURITY_ENDPOINT',
  defaultValue: '/api/user/security',
);
const String defaultRevokeSessionEndpoint = String.fromEnvironment(
  'REVOKE_SESSION_ENDPOINT',
  defaultValue: '/api/user/sessions/revoke',
);

class SecurityApiException implements Exception {
  const SecurityApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UpdatePasswordRequest {
  const UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class SecurityApiService {
  SecurityApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.securityEndpoint = defaultSecurityEndpoint,
    this.revokeSessionEndpoint = defaultRevokeSessionEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String securityEndpoint;
  final String revokeSessionEndpoint;
  final http.Client _httpClient;

  Future<void> updatePassword(UpdatePasswordRequest request) async {
    await _putJson(_buildUri(securityEndpoint), {
      'type': 'password',
      ...request.toJson(),
    });
  }

  Future<void> updateTwoFactor({
    required bool authenticatorEnabled,
    required bool smsEnabled,
  }) async {
    await _putJson(_buildUri(securityEndpoint), {
      'type': 'twoFactor',
      'authenticatorEnabled': authenticatorEnabled,
      'smsEnabled': smsEnabled,
    });
  }

  Future<void> revokeSessions({String? sessionId}) async {
    await _postJson(
      _buildUri(revokeSessionEndpoint),
      sessionId == null ? {'all': true} : {'sessionId': sessionId},
    );
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
      _throwForStatus(response, 'Security update');
      return response;
    } on TimeoutException {
      throw const SecurityApiException('Security request timed out.');
    } on http.ClientException {
      throw const SecurityApiException(
        'Could not connect to the security backend.',
      );
    }
  }

  Future<http.Response> _postJson(Uri uri, Map<String, dynamic> body) async {
    try {
      final response = await _httpClient
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));
      _throwForStatus(response, 'Session revoke');
      return response;
    } on TimeoutException {
      throw const SecurityApiException('Session revoke request timed out.');
    } on http.ClientException {
      throw const SecurityApiException(
        'Could not connect to the security backend.',
      );
    }
  }

  void _throwForStatus(http.Response response, String label) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SecurityApiException(
        '$label failed with status ${response.statusCode}.',
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
