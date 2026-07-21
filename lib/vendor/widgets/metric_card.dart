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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .65)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: .05), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
          ],
          Text(value, style: AppTextStyles.statValue(color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSm()),
        ],
      ),
    );
  }
}
