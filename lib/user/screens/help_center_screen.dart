import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../providers/event_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'checklist_screen.dart';
import 'event_flow_home_screen.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _HelpHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: _HelpCard(
                        onContactSupport: () async {
                          final uri = Uri(scheme: 'tel', path: '+15550123456');
                          final opened = await launchUrl(uri);
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.tr('common.could_not_start_phone'),
                                ),
                              ),
                            );
                          }
                        },
                        onLiveChat: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ChatScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _HelpBottomNav(),
    );
  }
}

class _HelpHeader extends StatelessWidget {
  const _HelpHeader();

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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.eventBlack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 38, height: 38),
          ),
          const SizedBox(width: 4),
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
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.eventDarkIcon,
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onContactSupport, required this.onLiveChat});

  final Future<void> Function() onContactSupport;
  final VoidCallback onLiveChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.eventMutedBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.eventBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr('help.need_help'),
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('help.subtitle'),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(
              color: AppColors.eventMutedForeground,
            ).copyWith(fontSize: 14, letterSpacing: 0),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onContactSupport,
              icon: const Icon(Icons.headset_mic_rounded, size: 20),
              label: Text(context.tr('help.contact')),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.eventPrimary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                textStyle: AppTextStyles.labelMd(
                  color: AppColors.onPrimary,
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onLiveChat,
              icon: const Icon(Icons.chat_bubble_rounded, size: 19),
              label: Text(context.tr('help.live_chat')),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.eventBackground,
                foregroundColor: AppColors.eventPrimary,
                side: const BorderSide(color: AppColors.eventBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                textStyle: AppTextStyles.labelMd(
                  color: AppColors.eventPrimary,
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpBottomNav extends ConsumerWidget {
  const _HelpBottomNav();

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
