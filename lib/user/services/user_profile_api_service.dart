import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultUpdateUserProfileEndpoint = String.fromEnvironment(
  'UPDATE_USER_PROFILE_ENDPOINT',
  defaultValue: '/api/user/profile',
);

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.bio,
  });

  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String bio;

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? bio,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json,
    UserProfile fallback,
  ) {
    return UserProfile(
      fullName: _stringValue(json, [
        'fullName',
        'name',
      ], fallback: fallback.fullName),
      email: _stringValue(json, ['email'], fallback: fallback.email),
      phone: _stringValue(json, [
        'phone',
        'phoneNumber',
      ], fallback: fallback.phone),
      location: _stringValue(json, [
        'location',
        'primaryLocation',
      ], fallback: fallback.location),
      bio: _stringValue(json, [
        'bio',
        'professionalBio',
      ], fallback: fallback.bio),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'bio': bio,
    };
  }
}

class UserProfileApiException implements Exception {
  const UserProfileApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserProfileApiService {
  UserProfileApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.updateProfileEndpoint = defaultUpdateUserProfileEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String updateProfileEndpoint;
  final http.Client _httpClient;

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final response = await _putJson(
      _buildUri(updateProfileEndpoint),
      profile.toJson(),
    );
    final decoded = _decodeObject(response.body);
    final profileJson = decoded['user'] is Map
        ? Map<String, dynamic>.from(decoded['user'] as Map)
        : decoded['profile'] is Map
        ? Map<String, dynamic>.from(decoded['profile'] as Map)
        : decoded;
    if (profileJson.isEmpty) return profile;
    return UserProfile.fromJson(profileJson, profile);
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
        throw UserProfileApiException(
          'Update profile failed with status ${response.statusCode}.',
        );
      }
      return response;
    } on TimeoutException {
      throw const UserProfileApiException('Update profile request timed out.');
    } on FormatException {
      throw const UserProfileApiException(
        'Profile response was not valid JSON.',
      );
    } on http.ClientException {
      throw const UserProfileApiException(
        'Could not connect to the profile backend.',
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

String _stringValue(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}
