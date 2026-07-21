import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_settings_api_service.dart';

const defaultNotificationPreferences = NotificationPreferences(
  pushNotifications: true,
  emailSummaries: false,
  quoteSubmission: true,
  productFeatures: false,
);

final notificationSettingsApiServiceProvider =
    Provider<NotificationSettingsApiService>((ref) {
      return NotificationSettingsApiService();
    });

final notificationPreferencesProvider = StateProvider<NotificationPreferences>((
  ref,
) {
  return defaultNotificationPreferences;
});
