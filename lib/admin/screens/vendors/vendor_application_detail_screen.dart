import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vendor_application.dart';
import '../../providers/admin_providers.dart';
import '../../theme/admin_colors.dart';
import '../../theme/admin_text_styles.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/confirm_dialog.dart';

/// Screen — "Vendor Application Detail". Full review for a single
/// application: business info, contact, system verification, timeline, and
/// the Approve / Reject / Request more info decision actions.
class VendorApplicationDetailScreen extends ConsumerWidget {
  const VendorApplicationDetailScreen({super.key, required this.applicationId});

  final String applicationId;

  Future<void> _approve(BuildContext context, WidgetRef ref, VendorApplication application) async {
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'Approve Application',
      message: '${application.businessName} will go live in the vendor directory immediately.',
      confirmLabel: 'Approve',
      destructive: false,
    );
    if (!confirmed) return;
    ref.read(applicationsProvider.notifier).approve(application.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${application.businessName} approved.')));
      Navigator.of(context).pop();
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, VendorApplication application) async {
    final reason = await showAdminReasonDialog(
      context,
      title: 'Reject Application',
      message: 'Let ${application.businessName} know why this application was rejected.',
      confirmLabel: 'Reject',
      reasonRequired: true,
    );
    if (reason == null) return;
    ref.read(applicationsProvider.notifier).reject(application.id, reason: reason);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${application.businessName} rejected.')));
      Navigator.of(context).pop();
    }
  }

  Future<void> _requestInfo(BuildContext context, WidgetRef ref, VendorApplication application) async {
    final message = await showAdminReasonDialog(
      context,
      title: 'Request More Info',
      message: 'What do you need from ${application.businessName} before this can be reviewed?',
      confirmLabel: 'Send Request',
      destructive: false,
      reasonRequired: true,
    );
    if (message == null) return;
    ref.read(applicationsProvider.notifier).requestMoreInfo(application.id, message: message);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent to vendor.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationsProvider);
    VendorApplication? application;
    for (final a in applications) {
      if (a.id == applicationId) application = a;
    }

    if (application == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This application no longer exists.')),
      );
    }
    final app = application;
    final isOpen = app.stage.isOpen;

    return Scaffold(
      appBar: AppBar(title: Text(app.businessName)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AdminSpacing.margin),
              children: [
                Row(
                  children: [
                    Expanded(child: Text(app.businessName, style: AdminTextStyles.headlineMd())),
                    _StageChip(stage: app.stage),
                  ],
                ),
                const SizedBox(height: 4),
                Text(app.category, style: AdminTextStyles.bodyMd()),
                const SizedBox(height: 24),
                _Section(
                  title: 'Business Information',
                  children: [
                    _Field('Business Description', app.businessDescription.isEmpty ? '—' : app.businessDescription),
                    _Field('Business ID / License', app.businessLicenseId.isEmpty ? '—' : app.businessLicenseId),
                    _Field('Address', app.address.isEmpty ? app.location : app.address),
                  ],
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'Contact Person',
                  children: [
                    _Field('Name', app.contactName.isEmpty ? '—' : app.contactName),
                    _Field('Email', app.contactEmail.isEmpty ? '—' : app.contactEmail),
                    _Field('Phone', app.contactPhone.isEmpty ? '—' : app.contactPhone),
                  ],
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'Verification',
                  children: [
                    Row(
                      children: [
                        Icon(
                          app.systemVerificationStatus == VerificationStatus.verified ? Icons.check_circle : Icons.error_outline,
                          size: 18,
                          color: app.systemVerificationStatus == VerificationStatus.verified ? AdminColors.tertiary : AdminColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(app.systemVerificationStatus.label, style: AdminTextStyles.bodyLg()),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Application Timeline', style: AdminTextStyles.labelMd()),
                const SizedBox(height: 12),
                for (final event in app.timeline) _TimelineRow(event: event),
                if (app.rejectionReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.errorContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AdminRadius.sm),
                    ),
                    child: Text('Rejection reason: ${app.rejectionReason}', style: AdminTextStyles.bodyMd(color: AdminColors.error)),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (isOpen)
            Container(
              padding: const EdgeInsets.all(AdminSpacing.gutter),
              decoration: const BoxDecoration(
                color: AdminColors.surfaceContainerLowest,
                border: Border(top: BorderSide(color: AdminColors.outlineVariant)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _requestInfo(context, ref, app),
                      child: const Text('Request Info'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AdminColors.error, side: const BorderSide(color: AdminColors.error)),
                      onPressed: () => _reject(context, ref, app),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _approve(context, ref, app),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AdminRadius.md),
        border: Border.all(color: AdminColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AdminTextStyles.labelMd()),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AdminTextStyles.labelSm()),
          const SizedBox(height: 2),
          Text(value, style: AdminTextStyles.bodyLg()),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({required this.stage});

  final ApplicationStage stage;

  Color get _color {
    switch (stage) {
      case ApplicationStage.approved:
        return AdminColors.tertiary;
      case ApplicationStage.rejected:
        return AdminColors.error;
      case ApplicationStage.infoRequested:
        return AdminColors.warning;
      case ApplicationStage.submitted:
      case ApplicationStage.systemVerified:
      case ApplicationStage.adminReview:
        return AdminColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AdminRadius.full)),
      child: Text(stage.label, style: AdminTextStyles.labelSm(color: _color)),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event});

  final ApplicationTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 8, color: AdminColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${event.label} · ${event.actor}', style: AdminTextStyles.labelMd()),
                if (event.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(event.note, style: AdminTextStyles.bodyMd()),
                ],
                const SizedBox(height: 2),
                Text(_formatTimestamp(event.timestamp), style: AdminTextStyles.labelSm()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}
