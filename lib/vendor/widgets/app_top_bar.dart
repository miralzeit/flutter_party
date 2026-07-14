import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared "EventPro" branded top bar used across the auth screens.
/// Mirrors the sticky header in the Stitch exports: logo icon + wordmark,
/// with optional trailing actions for wider layouts.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.showActions = false,
  });

  final bool showActions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          Text('EventPro', style: AppTextStyles.headlineLgMobile(color: AppColors.primary)),
          const Spacer(),
          if (showActions) ...[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
