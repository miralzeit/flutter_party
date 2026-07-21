import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultCreateEventEndpoint = String.fromEnvironment(
  'CREATE_EVENT_ENDPOINT',
  defaultValue: '/post create event',
);

class CreateEventRequest {
  const CreateEventRequest({
    required this.eventType,
    required this.eventName,
    required this.eventDate,
    required this.location,
  });

  final String eventType;
  final String eventName;
  final DateTime eventDate;
  final String location;

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'location': location,
    };
  }
}

class EventApiException implements Exception {
  const EventApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EventApiService {
  EventApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.createEventEndpoint = defaultCreateEventEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String createEventEndpoint;
  final http.Client _httpClient;

  Future<void> createEvent(CreateEventRequest event) async {
    final uri = _buildUri();

    try {
      final response = await _httpClient
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(event.toJson()),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw EventApiException(
          'Create event failed with status ${response.statusCode}.',
        );
      }
    } on TimeoutException {
      throw const EventApiException('Create event request timed out.');
    } on http.ClientException {
      throw const EventApiException('Could not connect to the event backend.');
    }
  }

  Uri _buildUri() {
    final base = Uri.parse(baseUrl);
    final endpoint = createEventEndpoint.startsWith('/')
        ? createEventEndpoint
        : '/$createEventEndpoint';
    final path = '${_trimTrailingSlash(base.path)}$endpoint';

    return base.replace(path: path, queryParameters: base.queryParameters);
  }
}

String _trimTrailingSlash(String value) {
  if (value.endsWith('/')) return value.substring(0, value.length - 1);
  return value;
}
