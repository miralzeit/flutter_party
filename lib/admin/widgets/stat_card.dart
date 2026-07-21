import 'package:flutter/material.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';
import '../theme/admin_theme.dart';

/// One stat tile on the Overview dashboard. [flagLabel]/[flagColor] render a
/// small "ACTION REQ" / "URGENT" badge for the two queue-backed cards, and
/// [onTap] deep-links into the relevant queue.
class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.flagLabel,
    this.flagColor,
    this.onTap,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final String? flagLabel;
  final Color? flagColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final flagged = flagLabel != null;
    final accent = flagColor ?? AdminColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminRadius.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AdminRadius.md),
          border: Border.all(color: flagged ? accent.withValues(alpha: 0.4) : AdminColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AdminRadius.sm)),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const Spacer(),
                if (flagged)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(AdminRadius.full)),
                      child: Text(
                        flagLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AdminTextStyles.labelSm(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(value, style: AdminTextStyles.statValue()),
            const SizedBox(height: 4),
            Text(label, style: AdminTextStyles.labelMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(subtitle, style: AdminTextStyles.bodyMd(), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
