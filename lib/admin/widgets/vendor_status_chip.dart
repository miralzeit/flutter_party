import 'package:flutter/material.dart';
import '../models/admin_vendor.dart';
import '../theme/admin_text_styles.dart';
import '../theme/admin_theme.dart';

/// Status is never conveyed by color alone — icon + text every time.
class VendorStatusChip extends StatelessWidget {
  const VendorStatusChip({super.key, required this.status});

  final VendorStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AdminRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 6),
          Text(status.label, style: AdminTextStyles.labelSm(color: status.textColor)),
        ],
      ),
    );
  }
}
