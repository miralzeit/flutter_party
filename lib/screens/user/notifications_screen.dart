import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/notifications_provider.dart';
import '../../services/notifications_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'event_flow_home_screen.dart';
import 'profile_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _NotificationsHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: notificationsState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.eventPrimary,
                      ),
                    ),
                    error: (error, _) => _NotificationsError(
                      message: error.toString(),
                      onRetry: () => ref
                          .read(notificationsProvider.notifier)
                          .loadNotifications(),
                    ),
                    data: (notifications) =>
                        _NotificationsList(notifications: notifications),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _NotificationsBottomNav(),
    );
  }
}

class _NotificationsHeader extends ConsumerWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      decoration: const BoxDecoration(
        color: AppColors.eventBackground,
        border: Border(bottom: BorderSide(color: AppColors.eventBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.eventBlack,
          ),
          Expanded(
            child: Text(
              'Notifications',
              style: AppTextStyles.headlineMd(
                color: AppColors.eventBlack,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
          ),
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: () async {
              try {
                await ref.read(notificationsProvider.notifier).markAllAsRead();
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.toString())));
              }
            },
            icon: const Icon(Icons.done_all_rounded),
            color: AppColors.eventPrimary,
          ),
        ],
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({required this.notifications});

  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context) {
    final groups = _groupNotifications(notifications);

    return RefreshIndicator(
      color: AppColors.eventPrimary,
      onRefresh: () async {
        // RefreshIndicator requires the caller to rebuild through provider access.
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          if (notifications.isEmpty)
            const _EmptyNotificationsCard()
          else
            for (final group in groups.entries) ...[
              _DateGroupLabel(group.key),
              const SizedBox(height: 10),
              for (final notification in group.value) ...[
                _NotificationCard(notification: notification),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
            ],
          const _PromoBanner(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DateGroupLabel extends StatelessWidget {
  const _DateGroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSm(
        color: AppColors.eventMutedForeground,
      ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.6),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = _typeMeta(notification.type);

    return InkWell(
      onTap: () async {
        if (!notification.isRead) {
          try {
            await ref
                .read(notificationsProvider.notifier)
                .markAsRead(notification.id);
          } catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.toString())));
            }
          }
        }
        if (!context.mounted) return;
        _navigateForNotification(context, notification);
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.eventBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: notification.isRead
                ? AppColors.eventBorder
                : AppColors.eventPrimary.withValues(alpha: 0.18),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.eventShadow,
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: meta.background,
                shape: BoxShape.circle,
              ),
              child: Icon(meta.icon, color: meta.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTextStyles.labelMd(
                                color: AppColors.eventBlack,
                              ).copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _relativeTime(context, notification.createdAt),
                            style: AppTextStyles.labelSm(
                              color: AppColors.eventMutedForeground,
                            ).copyWith(letterSpacing: 0),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.eventAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMd(
                      color: AppColors.eventMutedForeground,
                    ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upgrade screen coming soon.')),
        );
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.eventPrimary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [
            BoxShadow(
              color: AppColors.eventShadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Master your planning',
                    style: AppTextStyles.headlineMd(
                      color: AppColors.onPrimary,
                    ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upgrade to Pro for advanced budget tracking.',
                    style: AppTextStyles.labelMd(
                      color: AppColors.eventSoftText,
                    ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.onPrimary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off_rounded,
            color: AppColors.eventMutedForeground,
            size: 46,
          ),
          const SizedBox(height: 12),
          Text(
            'Could not load notifications',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd(
              color: AppColors.eventMutedForeground,
            ).copyWith(letterSpacing: 0),
          ),
          const SizedBox(height: 14),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyNotificationsCard extends StatelessWidget {
  const _EmptyNotificationsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.eventBorder),
      ),
      child: Text(
        'No notifications yet.',
        textAlign: TextAlign.center,
        style: AppTextStyles.labelMd(color: AppColors.eventMutedForeground),
      ),
    );
  }
}

class _NotificationsBottomNav extends ConsumerWidget {
  const _NotificationsBottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 10),
        decoration: const BoxDecoration(
          color: AppColors.eventBackground,
          border: Border(top: BorderSide(color: AppColors.eventBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const EventFlowHomeScreen()),
              ),
            ),
            _BottomNavItem(
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.eventMutedForeground, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm(
                color: AppColors.eventMutedForeground,
              ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTypeMeta {
  const _NotificationTypeMeta({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
}

_NotificationTypeMeta _typeMeta(NotificationType type) {
  return switch (type) {
    NotificationType.eventReminder => const _NotificationTypeMeta(
      icon: Icons.event_note_rounded,
      background: AppColors.eventMutedBackground,
      iconColor: AppColors.eventPrimary,
    ),
    NotificationType.vendorUpdate => const _NotificationTypeMeta(
      icon: Icons.restaurant_rounded,
      background: AppColors.eventPrimary,
      iconColor: AppColors.onPrimary,
    ),
    NotificationType.checklistAlert => const _NotificationTypeMeta(
      icon: Icons.assignment_late_rounded,
      background: Color(0xFFFFECEF),
      iconColor: Color(0xFFD34B5F),
    ),
    NotificationType.systemUpdate => const _NotificationTypeMeta(
      icon: Icons.campaign_rounded,
      background: AppColors.eventPrimary,
      iconColor: AppColors.onPrimary,
    ),
  };
}

Map<String, List<AppNotification>> _groupNotifications(
  List<AppNotification> notifications,
) {
  final groups = <String, List<AppNotification>>{};
  for (final notification in notifications) {
    final label = _groupLabel(notification.createdAt);
    groups.putIfAbsent(label, () => []).add(notification);
  }
  return groups;
}

String _groupLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  final target = DateUtils.dateOnly(date);
  final daysAgo = today.difference(target).inDays;
  if (daysAgo == 0) return 'Today';
  if (daysAgo == 1) return 'Yesterday';
  if (daysAgo <= 7) return 'Earlier this week';
  return DateFormat.yMMMM().format(date);
}

String _relativeTime(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) {
    return DateFormat.E(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }
  return DateFormat.MMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

void _navigateForNotification(
  BuildContext context,
  AppNotification notification,
) {
  final route = notification.targetRoute;
  if (route != null && route.isNotEmpty) {
    Navigator.of(context).pushNamed(route);
    return;
  }

  switch (notification.type) {
    case NotificationType.checklistAlert:
      Navigator.of(context).pushNamed('/checklist');
    case NotificationType.vendorUpdate:
    case NotificationType.eventReminder:
      Navigator.of(context).pushNamed('/home');
    case NotificationType.systemUpdate:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feature page coming soon.')),
      );
  }
}
