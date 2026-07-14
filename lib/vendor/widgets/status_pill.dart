import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Small colored pill reflecting [Business.status] — never a hardcoded
/// "Active" label, always derived from the business it's given.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final BusinessStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BusinessStatus.active => ('Active', AppColors.tertiary),
      BusinessStatus.underReview => ('Under Review', AppColors.outline),
      BusinessStatus.paused => ('Paused', AppColors.outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.dflt),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelSm(color: color)),
        ],
      ),
    );
  }
}
