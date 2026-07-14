import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// One tappable card in a [QuickActionGrid].
class QuickAction {
  QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Dashboard "Quick Actions" as a grid of large cards rather than a row of
/// chips — matches the size/weight of the rest of the dashboard's cards.
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: AppColors.primary, size: 24),
                const SizedBox(height: 8),
                Text(action.label, style: AppTextStyles.labelMd()),
              ],
            ),
          ),
        );
      },
    );
  }
}
