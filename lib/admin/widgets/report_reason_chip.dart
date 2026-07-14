import 'package:flutter/material.dart';
import '../models/admin_review.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';
import '../theme/admin_theme.dart';

class ReportReasonChip extends StatelessWidget {
  const ReportReasonChip({super.key, required this.reason});

  final ReportReason reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AdminColors.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AdminRadius.full),
      ),
      child: Text(reason.label, style: AdminTextStyles.labelSm(color: AdminColors.error)),
    );
  }
}
