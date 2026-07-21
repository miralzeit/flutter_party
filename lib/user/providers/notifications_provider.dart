import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notifications_api_service.dart';

final notificationsApiServiceProvider = Provider<NotificationsApiService>((
  ref,
) {
  return NotificationsApiService();
});

final notificationsProvider =
    StateNotifierProvider<
      NotificationsNotifier,
      AsyncValue<List<AppNotification>>
    >((ref) => NotificationsNotifier(ref)..loadNotifications());

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsNotifier(this._ref) : super(const AsyncValue.loading());

  final Ref _ref;

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _ref
          .read(notificationsApiServiceProvider)
          .getNotifications();
      state = AsyncValue.data(_sorted(notifications));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    final previous = state.valueOrNull ?? const <AppNotification>[];
    state = AsyncValue.data(
      previous.map((item) => item.copyWith(isRead: true)).toList(),
    );
    try {
      await _ref.read(notificationsApiServiceProvider).markAllAsRead();
    } catch (_) {
      state = AsyncValue.data(previous);
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final previous = state.valueOrNull ?? const <AppNotification>[];
    state = AsyncValue.data(
      previous
          .map(
            (item) =>
                item.id == notificationId ? item.copyWith(isRead: true) : item,
          )
          .toList(),
    );
    try {
      await _ref
          .read(notificationsApiServiceProvider)
          .markAsRead(notificationId);
    } catch (_) {
      state = AsyncValue.data(previous);
      rethrow;
    }
  }
}

List<AppNotification> _sorted(List<AppNotification> notifications) {
  final items = [...notifications];
  items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return items;
}
