import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_settings_provider.dart';
import '../../services/notification_settings_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'checklist_screen.dart';
import 'event_flow_home_screen.dart';

const bool _skipNotificationBackend = bool.fromEnvironment(
  'SKIP_NOTIFICATION_BACKEND',
  defaultValue: false,
);
const bool _skipProfileBackend = bool.fromEnvironment(
  'SKIP_PROFILE_BACKEND',
  defaultValue: false,
);
const bool _skipCreateEventBackend = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  late NotificationPreferences _draft;
  var _isSaving = false;

  bool get _useLocalNotificationData =>
      _skipNotificationBackend ||
      _skipProfileBackend ||
      _skipCreateEventBackend;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(notificationPreferencesProvider);
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final saved = _useLocalNotificationData
          ? _draft
          : await ref
                .read(notificationSettingsApiServiceProvider)
                .updatePreferences(_draft);
      ref.read(notificationPreferencesProvider.notifier).state = saved;
      if (!mounted) return;
      setState(() => _draft = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('notifications.saved'))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _discardChanges() {
    setState(() => _draft = ref.read(notificationPreferencesProvider));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('notifications.discarded'))),
    );
  }

  void _updateDraft(NotificationPreferences value) {
    setState(() => _draft = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _NotificationHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(context.tr('common.settings')),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.eventMutedForeground,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('notifications.title'),
                        style:
                            AppTextStyles.headlineLgMobile(
                              color: AppColors.eventBlack,
                            ).copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('notifications.subtitle'),
                        style: AppTextStyles.bodyMd(
                          color: AppColors.eventMutedForeground,
                        ).copyWith(letterSpacing: 0),
                      ),
                      const SizedBox(height: 20),
                      _PreferenceCard(
                        icon: Icons.event_note_rounded,
                        title: context.tr('notifications.event_reminders'),
                        description: context.tr(
                          'notifications.event_reminders_desc',
                        ),
                        rows: [
                          _PreferenceRowData(
                            title: context.tr('notifications.push'),
                            subtitle: context.tr('notifications.push_desc'),
                            selected: _draft.pushNotifications,
                            onTap: () => _updateDraft(
                              _draft.copyWith(
                                pushNotifications: !_draft.pushNotifications,
                              ),
                            ),
                          ),
                          _PreferenceRowData(
                            title: context.tr('notifications.email_summaries'),
                            subtitle: context.tr(
                              'notifications.email_summaries_desc',
                            ),
                            selected: _draft.emailSummaries,
                            onTap: () => _updateDraft(
                              _draft.copyWith(
                                emailSummaries: !_draft.emailSummaries,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _PreferenceCard(
                        icon: Icons.request_quote_rounded,
                        title: context.tr('notifications.vendor_quotes'),
                        description: context.tr(
                          'notifications.vendor_quotes_desc',
                        ),
                        rows: [
                          _PreferenceRowData(
                            title: context.tr('notifications.quote_submission'),
                            subtitle: context.tr(
                              'notifications.quote_submission_desc',
                            ),
                            selected: _draft.quoteSubmission,
                            onTap: () => _updateDraft(
                              _draft.copyWith(
                                quoteSubmission: !_draft.quoteSubmission,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _PreferenceCard(
                        icon: Icons.phone_iphone_rounded,
                        title: context.tr('notifications.platform_updates'),
                        description: context.tr(
                          'notifications.platform_updates_desc',
                        ),
                        rows: [
                          _PreferenceRowData(
                            title: context.tr('notifications.product_features'),
                            subtitle: context.tr(
                              'notifications.product_features_desc',
                            ),
                            selected: _draft.productFeatures,
                            onTap: () => _updateDraft(
                              _draft.copyWith(
                                productFeatures: !_draft.productFeatures,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ActionRow(
                        isSaving: _isSaving,
                        onDiscard: _isSaving ? null : _discardChanges,
                        onSave: _isSaving ? null : _savePreferences,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _NotificationBottomNav(),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.eventBackground,
        border: Border(bottom: BorderSide(color: AppColors.eventBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.eventPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.park_rounded,
              color: AppColors.onPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr('common.app_name'),
              style: AppTextStyles.headlineMd(
                color: AppColors.eventBlack,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
            color: AppColors.eventDarkIcon,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.eventDarkIcon,
          ),
        ],
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<_PreferenceRowData> rows;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.eventMutedBackground,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.eventPrimary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.headlineMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyles.bodyMd(
              color: AppColors.eventMutedForeground,
            ).copyWith(fontSize: 14, letterSpacing: 0),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.eventBorder),
          for (final row in rows) _PreferenceRow(data: row),
        ],
      ),
    );
  }
}

class _PreferenceRowData {
  const _PreferenceRowData({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.data});

  final _PreferenceRowData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.labelMd(
                      color: AppColors.eventBlack,
                    ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: AppTextStyles.labelSm(
                      color: AppColors.eventMutedForeground,
                    ).copyWith(letterSpacing: 0),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _RadioIndicator(selected: data.selected),
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.eventPrimary : AppColors.eventBorder,
          width: selected ? 2 : 1.5,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.eventPrimary : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isSaving,
    required this.onDiscard,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback? onDiscard;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onDiscard,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.eventDarkIcon,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          child: Text(
            context.tr('common.discard_changes'),
            style: AppTextStyles.labelMd(
              color: AppColors.eventDarkIcon,
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.eventPrimary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.onPrimary,
                  ),
                )
              : Text(
                  context.tr('common.save_preferences'),
                  style: AppTextStyles.labelMd(
                    color: AppColors.onPrimary,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
        ),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.eventBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NotificationBottomNav extends ConsumerWidget {
  const _NotificationBottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(activeEventProvider);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
        decoration: const BoxDecoration(
          color: AppColors.eventBackground,
          border: Border(top: BorderSide(color: AppColors.eventBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: context.tr('nav.home'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const EventFlowHomeScreen(),
                  ),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.chat_bubble_rounded,
              label: context.tr('nav.chat'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.fact_check_rounded,
              label: context.tr('nav.checklist'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ChecklistScreen(
                      eventName:
                          activeEvent?.eventName ??
                          context.tr('common.app_name'),
                    ),
                  ),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
              label: context.tr('nav.profile'),
              active: true,
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
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.eventPrimary
        : AppColors.eventMutedForeground;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.eventSelectedBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm(color: color).copyWith(
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
