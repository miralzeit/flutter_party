import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultCreateChecklistTaskEndpoint = String.fromEnvironment(
  'CREATE_CHECKLIST_TASK_ENDPOINT',
  defaultValue: '/api/checklist/tasks',
);

class ChecklistTask {
  const ChecklistTask({
    required this.id,
    required this.name,
    required this.dueDate,
    this.isCompleted = false,
  });

  final String id;
  final String name;
  final DateTime dueDate;
  final bool isCompleted;

  ChecklistTask copyWith({
    String? id,
    String? name,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return ChecklistTask(
      id: id ?? this.id,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory ChecklistTask.fromJson(Map<String, dynamic> json) {
    return ChecklistTask(
      id: _stringValue(json, ['id', '_id'], fallback: _localId()),
      name: _stringValue(json, [
        'name',
        'title',
        'task',
      ], fallback: 'Checklist task'),
      dueDate:
          _dateValue(json, ['dueDate', 'due_at', 'date']) ?? DateTime.now(),
      isCompleted: json['isCompleted'] is bool
          ? json['isCompleted'] as bool
          : json['completed'] is bool
          ? json['completed'] as bool
          : false,
    );
  }

  factory ChecklistTask.local({
    required String name,
    required DateTime dueDate,
  }) {
    return ChecklistTask(id: _localId(), name: name, dueDate: dueDate);
  }

  Map<String, dynamic> toJson({String? eventName}) {
    return {
      'id': id,
      'eventName': eventName,
      'name': name,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}

class CreateChecklistTaskRequest {
  const CreateChecklistTaskRequest({
    required this.eventName,
    required this.name,
    required this.dueDate,
  });

  final String eventName;
  final String name;
  final DateTime dueDate;

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'name': name,
      'dueDate': dueDate.toIso8601String(),
    };
  }
}

class ChecklistApiException implements Exception {
  const ChecklistApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChecklistApiService {
  ChecklistApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.createTaskEndpoint = defaultCreateChecklistTaskEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String createTaskEndpoint;
  final http.Client _httpClient;

  Future<ChecklistTask> createTask(CreateChecklistTaskRequest task) async {
    final response = await _postJson(
      _buildUri(createTaskEndpoint),
      task.toJson(),
    );
    final decoded = _decodeObject(response.body);
    final taskJson = decoded['task'] is Map
        ? Map<String, dynamic>.from(decoded['task'] as Map)
        : decoded;
    if (taskJson.isEmpty) {
      return ChecklistTask.local(name: task.name, dueDate: task.dueDate);
    }
    return ChecklistTask.fromJson(taskJson);
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

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ChecklistApiException(
          'Create task failed with status ${response.statusCode}.',
        );
      }
      return response;
    } on TimeoutException {
      throw const ChecklistApiException('Create task request timed out.');
    } on FormatException {
      throw const ChecklistApiException(
        'Checklist response was not valid JSON.',
      );
    } on http.ClientException {
      throw const ChecklistApiException(
        'Could not connect to the checklist backend.',
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

String _localId() => DateTime.now().microsecondsSinceEpoch.toString();

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

DateTime? _dateValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return null;
}
