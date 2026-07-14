import 'package:flutter/material.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// Shared empty-state block for every list/table in the admin panel.
class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AdminColors.outline),
            const SizedBox(height: 12),
            Text(message, style: AdminTextStyles.bodyMd(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
