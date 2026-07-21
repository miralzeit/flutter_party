import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultChatMessageEndpoint = String.fromEnvironment(
  'CHAT_MESSAGE_ENDPOINT',
  defaultValue: '/api/chat/messages',
);

class ChatReply {
  const ChatReply({required this.message});

  final String message;

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    final message = _stringValue(json, [
      'message',
      'reply',
      'content',
      'text',
    ], fallback: 'I can help with that.');
    return ChatReply(message: message);
  }
}

class ChatApiException implements Exception {
  const ChatApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChatApiService {
  ChatApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.messageEndpoint = defaultChatMessageEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String messageEndpoint;
  final http.Client _httpClient;

  Future<ChatReply> sendMessage(String message) async {
    final response = await _postJson(_buildUri(messageEndpoint), {
      'message': message,
    });
    final decoded = _decodeObject(response.body);
    final replyJson = decoded['assistant'] is Map
        ? Map<String, dynamic>.from(decoded['assistant'] as Map)
        : decoded['reply'] is Map
        ? Map<String, dynamic>.from(decoded['reply'] as Map)
        : decoded;
    return ChatReply.fromJson(replyJson);
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
          .timeout(const Duration(seconds: 18));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ChatApiException(
          'Chat request failed with status ${response.statusCode}.',
        );
      }
      return response;
    } on TimeoutException {
      throw const ChatApiException('Chat request timed out.');
    } on FormatException {
      throw const ChatApiException('Chat response was not valid JSON.');
    } on http.ClientException {
      throw const ChatApiException('Could not connect to the chat backend.');
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
