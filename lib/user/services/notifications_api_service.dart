import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultNotificationsEndpoint = String.fromEnvironment(
  'NOTIFICATIONS_ENDPOINT',
  defaultValue: '/api/notifications',
);
const String defaultReadAllNotificationsEndpoint = String.fromEnvironment(
  'READ_ALL_NOTIFICATIONS_ENDPOINT',
  defaultValue: '/api/notifications/read-all',
);

const bool skipNotificationsBackend = bool.fromEnvironment(
  'SKIP_NOTIFICATIONS_BACKEND',
  defaultValue: false,
);
const bool skipCreateEventBackendForNotifications = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.targetRoute,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? targetRoute;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final timestamp = _stringValue(json, [
      'createdAt',
      'timestamp',
      'time',
      'date',
    ]);
    return AppNotification(
      id: _stringValue(json, ['id', '_id', 'notificationId']),
      type: NotificationType.fromValue(
        _stringValue(json, ['type', 'category', 'kind']),
      ),
      title: _stringValue(json, ['title'], fallback: 'Notification'),
      body: _stringValue(json, ['body', 'message', 'description']),
      createdAt: DateTime.tryParse(timestamp)?.toLocal() ?? DateTime.now(),
      isRead: _boolValue(json, ['isRead', 'read', 'seen'], fallback: false),
      targetRoute: _stringValue(json, ['targetRoute', 'route', 'screen']),
    );
  }
}

enum NotificationType {
  eventReminder,
  vendorUpdate,
  checklistAlert,
  systemUpdate;

  static NotificationType fromValue(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return switch (normalized) {
      'eventreminder' || 'event' || 'reminder' => eventReminder,
      'vendorupdate' || 'vendor' || 'quote' => vendorUpdate,
      'checklistalert' || 'checklist' || 'task' => checklistAlert,
      'systemupdate' || 'system' || 'platform' => systemUpdate,
      _ => systemUpdate,
    };
  }
}

class NotificationsApiException implements Exception {
  const NotificationsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NotificationsApiService {
  NotificationsApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.notificationsEndpoint = defaultNotificationsEndpoint,
    this.readAllEndpoint = defaultReadAllNotificationsEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String notificationsEndpoint;
  final String readAllEndpoint;
  final http.Client _httpClient;

  Future<List<AppNotification>> getNotifications() async {
    if (skipNotificationsBackend || skipCreateEventBackendForNotifications) {
      return demoNotifications;
    }

    final response = await _request(
      () => _httpClient.get(
        _buildUri(notificationsEndpoint),
        headers: const {'Accept': 'application/json'},
      ),
      'Notifications request',
    );
    final decoded = _decode(response.body);
    final items = decoded is List
        ? decoded
        : decoded is Map && decoded['notifications'] is List
        ? decoded['notifications'] as List
        : decoded is Map && decoded['data'] is List
        ? decoded['data'] as List
        : const [];
    return items
        .whereType<Map>()
        .map(
          (item) => AppNotification.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<void> markAllAsRead() async {
    if (skipNotificationsBackend || skipCreateEventBackendForNotifications) {
      return;
    }
    await _request(
      () => _httpClient.put(
        _buildUri(readAllEndpoint),
        headers: const {'Accept': 'application/json'},
      ),
      'Mark all notifications as read',
    );
  }

  Future<void> markAsRead(String notificationId) async {
    if (skipNotificationsBackend || skipCreateEventBackendForNotifications) {
      return;
    }
    final endpoint =
        '${_trimTrailingSlash(notificationsEndpoint)}/$notificationId/read';
    await _request(
      () => _httpClient.put(
        _buildUri(endpoint),
        headers: const {'Accept': 'application/json'},
      ),
      'Mark notification as read',
    );
  }

  Future<http.Response> _request(
    Future<http.Response> Function() request,
    String label,
  ) async {
    try {
      final response = await request().timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NotificationsApiException(
          '$label failed with status ${response.statusCode}.',
        );
      }
      return response;
    } on TimeoutException {
      throw NotificationsApiException('$label timed out.');
    } on FormatException {
      throw const NotificationsApiException(
        'Notifications response was not valid JSON.',
      );
    } on http.ClientException {
      throw const NotificationsApiException(
        'Could not connect to the notifications backend.',
      );
    }
  }

  Object? _decode(String body) {
    if (body.trim().isEmpty) return const [];
    return jsonDecode(body);
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

final demoNotifications = [
  AppNotification(
    id: 'demo-event-reminder',
    type: NotificationType.eventReminder,
    title: 'Event Reminder',
    body: 'Your event in Nissan Hall is in 3 days.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
    targetRoute: '/home',
  ),
  AppNotification(
    id: 'demo-vendor-update',
    type: NotificationType.vendorUpdate,
    title: 'Vendor Update',
    body: 'Artisan Bites has added a new catering quote.',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: false,
    targetRoute: '/home',
  ),
  AppNotification(
    id: 'demo-checklist-alert',
    type: NotificationType.checklistAlert,
    title: 'Checklist Alert',
    body: "3 tasks for 'Smith Wedding' are overdue.",
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    isRead: true,
    targetRoute: '/checklist',
  ),
  AppNotification(
    id: 'demo-system-update',
    type: NotificationType.systemUpdate,
    title: 'System Update',
    body: 'New feature: You can now use our AI budget tracking.',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
    targetRoute: '/profile',
  ),
];

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

bool _boolValue(
  Map<String, dynamic> json,
  List<String> keys, {
  required bool fallback,
}) {
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
