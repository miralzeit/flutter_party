import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/checklist_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/event_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/user_profile_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../screens/login_register_screen.dart';
import 'chat_screen.dart';
import 'checklist_screen.dart';
import 'edit_profile_screen.dart';
import 'event_flow_home_screen.dart';
import 'help_center_screen.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(activeEventProvider);
    final profile = ref.watch(userProfileProvider);
    final tasks = ref.watch(checklistTasksProvider);
    final activeEvents = activeEvent == null ? 0 : 1;
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    final totalEvents = activeEvents;

    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _ProfileHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      _ProfileSummaryCard(
                        activeEvents: activeEvents,
                        profile: profile,
                      ),
                      const SizedBox(height: 16),
                      _QuickSnapshotCard(
                        totalEvents: totalEvents,
                        pendingTasks: pendingTasks,
                        eventName: activeEvent?.eventName ?? 'Evergreen Events',
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel(context.tr('profile.account_settings')),
                      const SizedBox(height: 10),
                      _SettingsCard(
                        rows: [
                          _SettingsRowData(
                            icon: Icons.person_rounded,
                            title: context.tr('profile.edit_profile'),
                            subtitle: context.tr(
                              'profile.edit_profile_subtitle',
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          _SettingsRowData(
                            icon: Icons.notifications_rounded,
                            title: context.tr('profile.notifications'),
                            subtitle: context.tr(
                              'profile.notifications_subtitle',
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          _SettingsRowData(
                            icon: Icons.lock_rounded,
                            title: context.tr('profile.security_password'),
                            subtitle: context.tr('profile.security_subtitle'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SecuritySettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _SectionLabel(context.tr('profile.preferences')),
                      const SizedBox(height: 10),
                      _PreferencesCard(),
                      const SizedBox(height: 22),
                      const _MyEventsHeader(),
                      const SizedBox(height: 10),
                      _MyEventsCard(activeEvent: activeEvent),
                      const SizedBox(height: 22),
                      _SectionLabel(context.tr('profile.support')),
                      const SizedBox(height: 10),
                      const _SupportCard(),
                      const SizedBox(height: 18),
                      const _LogoutButton(),
                      const SizedBox(height: 20),
                      const _FooterText(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _ProfileBottomNav(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
          Expanded(
            child: Text(
              'Evergreen Events',
              style: AppTextStyles.headlineMd(
                color: AppColors.eventBlack,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.eventDarkIcon,
          ),
          const SizedBox(width: 4),
          const _UserAvatar(size: 38),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.activeEvents,
    required this.profile,
  });

  final int activeEvents;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 102,
                height: 102,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.eventMapGreen,
                  shape: BoxShape.circle,
                ),
                child: const _UserAvatar(size: 94),
              ),
              Positioned(
                right: -1,
                bottom: 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.eventPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.onPrimary,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
          const SizedBox(height: 5),
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(
              color: AppColors.eventMutedForeground,
            ).copyWith(fontSize: 14, letterSpacing: 0),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.eventPrimary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.onPrimary,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  '$activeEvents Active Events',
                  style: AppTextStyles.labelMd(
                    color: AppColors.onPrimary,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSnapshotCard extends StatelessWidget {
  const _QuickSnapshotCard({
    required this.totalEvents,
    required this.pendingTasks,
    required this.eventName,
  });

  final int totalEvents;
  final int pendingTasks;
  final String eventName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.eventMutedBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.eventBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(context.tr('profile.quick_snapshot')),
          const SizedBox(height: 13),
          _StatRow(
            label: context.tr('profile.total_events'),
            value: '$totalEvents',
          ),
          const SizedBox(height: 10),
          _StatRow(
            label: context.tr('profile.tasks_pending'),
            value: '$pendingTasks',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChecklistScreen(eventName: eventName),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.eventPrimary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                'View Checklist',
                style: AppTextStyles.labelMd(
                  color: AppColors.onPrimary,
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMd(
              color: AppColors.eventMutedForeground,
            ).copyWith(fontSize: 14, letterSpacing: 0),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMd(
            color: AppColors.eventBlack,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSm(
        color: AppColors.eventMutedForeground,
      ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.1),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.rows});

  final List<_SettingsRowData> rows;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _SettingsRow(data: rows[index]),
            if (index != rows.length - 1)
              const Divider(height: 1, color: AppColors.eventBorder),
          ],
        ],
      ),
    );
  }
}

class _SettingsRowData {
  const _SettingsRowData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.data});

  final _SettingsRowData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.eventMutedBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, color: AppColors.eventPrimary, size: 20),
            ),
            const SizedBox(width: 12),
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
                  if (data.subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      data.subtitle!,
                      style: AppTextStyles.labelSm(
                        color: AppColors.eventMutedForeground,
                      ).copyWith(letterSpacing: 0),
                    ),
                  ],
                ],
              ),
            ),
            if (data.trailing != null)
              data.trailing!
            else if (data.showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.eventMutedForeground,
              ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final languageLabel = locale.languageCode == 'ar'
        ? context.tr('profile.arabic')
        : context.tr('profile.english');
    final currencyCode = ref.watch(currencyProvider);

    return _WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsRow(
            data: _SettingsRowData(
              icon: Icons.language_rounded,
              title: context.tr('profile.language'),
              trailing: _PreferenceTrailing(label: languageLabel),
              showChevron: false,
              onTap: () => _showLanguageSelector(context, ref),
            ),
          ),
          const Divider(height: 1, color: AppColors.eventBorder),
          _SettingsRow(
            data: _SettingsRowData(
              icon: Icons.credit_card_rounded,
              title: context.tr('profile.currency'),
              trailing: _PreferenceTrailing(label: currencyCode),
              showChevron: false,
              onTap: () => _showCurrencySelector(context, ref),
            ),
          ),
          const Divider(height: 1, color: AppColors.eventBorder),
          _SettingsRow(
            data: _SettingsRowData(
              icon: Icons.dark_mode_rounded,
              title: context.tr('profile.theme'),
              trailing: const _ThemeToggle(),
              showChevron: false,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(appLocaleProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.eventBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PreferenceOption(
                  label: context.tr('profile.english'),
                  selected: currentLocale.languageCode == 'en',
                  onTap: () =>
                      _selectLanguage(context, ref, const Locale('en')),
                ),
                const SizedBox(height: 10),
                _PreferenceOption(
                  label: context.tr('profile.arabic'),
                  selected: currentLocale.languageCode == 'ar',
                  onTap: () =>
                      _selectLanguage(context, ref, const Locale('ar')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCurrencySelector(BuildContext context, WidgetRef ref) {
    final currentCurrency = ref.read(currencyProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.eventBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final currencyCode in supportedCurrencyCodes) ...[
                  _PreferenceOption(
                    label: currencyCode,
                    selected: currentCurrency == currencyCode,
                    onTap: () => _selectCurrency(context, ref, currencyCode),
                  ),
                  if (currencyCode != supportedCurrencyCodes.last)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectCurrency(
    BuildContext context,
    WidgetRef ref,
    String currencyCode,
  ) async {
    try {
      await ref.read(currencyProvider.notifier).setCurrency(currencyCode);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _selectLanguage(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
  ) async {
    await ref.read(appLocaleProvider.notifier).setLocale(locale);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _PreferenceOption extends StatelessWidget {
  const _PreferenceOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.eventSelectedBackground
              : AppColors.eventMutedBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.eventPrimary : AppColors.eventBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMd(
                  color: AppColors.eventBlack,
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.eventPrimary,
              ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceTrailing extends StatelessWidget {
  const _PreferenceTrailing({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd(
            color: AppColors.eventMutedForeground,
          ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.eventMutedForeground,
        ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.eventMutedBackground,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.eventSelectedBackground,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'Light',
              style: AppTextStyles.labelSm(
                color: AppColors.eventPrimary,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text(
              'Dark',
              style: AppTextStyles.labelSm(
                color: AppColors.eventMutedForeground,
              ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyEventsHeader extends StatelessWidget {
  const _MyEventsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionLabel(context.tr('profile.my_events'))),
        Text(
          context.tr('profile.see_all'),
          style: AppTextStyles.labelSm(
            color: AppColors.eventMutedForeground,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
        ),
      ],
    );
  }
}

class _MyEventsCard extends StatelessWidget {
  const _MyEventsCard({required this.activeEvent});

  final ActiveEvent? activeEvent;

  @override
  Widget build(BuildContext context) {
    final rows = [
      if (activeEvent != null)
        _EventRowData(
          date: activeEvent!.eventDate,
          name: activeEvent!.eventName,
          details: '${activeEvent!.location} • 12:00 PM',
        )
      else
        _EventRowData(
          date: DateTime(2024, 10, 24),
          name: 'Miller-Smith Wedding',
          details: 'The Glass House • 12:00 PM',
        ),
      _EventRowData(
        date: DateTime(2024, 11, 12),
        name: 'Tech Summit 2024',
        details: 'Convention Center • 09:00 AM',
      ),
    ];

    return _WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _EventRow(data: rows[index]),
            if (index != rows.length - 1)
              const Divider(height: 1, color: AppColors.eventBorder),
          ],
        ],
      ),
    );
  }
}

class _EventRowData {
  const _EventRowData({
    required this.date,
    required this.name,
    required this.details,
  });

  final DateTime date;
  final String name;
  final String details;
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.data});

  final _EventRowData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _DateBadge(date: data.date),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: AppTextStyles.labelMd(
                    color: AppColors.eventBlack,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
                const SizedBox(height: 3),
                Text(
                  data.details,
                  style: AppTextStyles.labelSm(
                    color: AppColors.eventMutedForeground,
                  ).copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.eventSelectedBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(
            _month(date),
            style: AppTextStyles.labelSm(
              color: AppColors.eventPrimary,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.7),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}',
            style: AppTextStyles.labelMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      rows: [
        _SettingsRowData(
          icon: Icons.help_outline_rounded,
          title: context.tr('profile.help_center'),
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
          },
        ),
        _SettingsRowData(
          icon: Icons.description_rounded,
          title: context.tr('profile.terms'),
        ),
        _SettingsRowData(
          icon: Icons.shield_rounded,
          title: context.tr('profile.privacy'),
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(context.tr('profile.logout')),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFFECEC),
          foregroundColor: const Color(0xFFD34B4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTextStyles.labelMd(
            color: const Color(0xFFD34B4B),
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
        ),
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  const _FooterText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.tr('profile.version'),
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSm(
            color: AppColors.eventMutedForeground,
          ).copyWith(letterSpacing: 0),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('profile.copyright'),
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSm(
            color: AppColors.eventMutedForeground,
          ).copyWith(fontSize: 10, letterSpacing: 0),
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFBFD8D1), Color(0xFF577C75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.onPrimary,
        size: size * 0.58,
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.eventBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileBottomNav extends ConsumerWidget {
  const _ProfileBottomNav();

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
                      eventName: activeEvent?.eventName ?? 'Evergreen Events',
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

String _month(DateTime date) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return months[date.month - 1];
}
