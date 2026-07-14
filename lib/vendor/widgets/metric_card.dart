import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// A single stat tile used in the Dashboard's quick-overview grid and the
/// Analytics metric grid: a muted label above a large number, on a tonal
/// surface container. Shared by both screens rather than each rolling its
/// own card.
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 8),
          ],
          Text(label, style: AppTextStyles.labelSm()),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.statValue()),
        ],
      ),
    );
  }
}
