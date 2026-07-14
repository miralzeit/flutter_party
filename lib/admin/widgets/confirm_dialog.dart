import 'package:flutter/material.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// Confirmation modal required before any destructive/high-impact action
/// (Block vendor, Delete review, Deactivate category, ...). When
/// [collectReason] is true, an optional free-text reason field is shown and
/// its value returned instead of a plain `true`.
Future<bool> showAdminConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title, style: AdminTextStyles.headlineMd()),
      content: Text(message, style: AdminTextStyles.bodyLg()),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: destructive ? AdminColors.error : AdminColors.primary),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Same as [showAdminConfirmDialog] but collects an optional reason string
/// (used for suspend/block/reject actions feeding the audit log). Returns
/// null if cancelled, otherwise the (possibly empty) reason text.
Future<String?> showAdminReasonDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = true,
  bool reasonRequired = false,
}) async {
  final controller = TextEditingController();
  String? error;

  return showDialog<String?>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text(title, style: AdminTextStyles.headlineMd()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: AdminTextStyles.bodyLg()),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: reasonRequired ? 'Reason (required)' : 'Reason (optional, for the audit log)',
                errorText: error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(null), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: destructive ? AdminColors.error : AdminColors.primary),
            onPressed: () {
              if (reasonRequired && controller.text.trim().isEmpty) {
                setState(() => error = 'Please provide a reason.');
                return;
              }
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    ),
  );
}
