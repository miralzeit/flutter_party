import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin_vendor.dart';
import '../../providers/admin_providers.dart';
import '../../theme/admin_colors.dart';
import '../../theme/admin_text_styles.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/vendor_status_chip.dart';
import '../analytics/vendor_analytics_screen.dart';

/// Screen — Vendor Detail (for an already-live [AdminVendor], as opposed to
/// [VendorApplicationDetailScreen] which is for an application still in the
/// approval pipeline). Lets an admin suspend/reinstate/block the vendor and
/// jump into their read-only Analytics view for support purposes.
class VendorDetailScreen extends ConsumerWidget {
  const VendorDetailScreen({super.key, required this.vendorId});

  final String vendorId;

  Future<void> _suspend(BuildContext context, WidgetRef ref, AdminVendor vendor) async {
    final reason = await showAdminReasonDialog(
      context,
      title: 'Suspend Vendor',
      message: '${vendor.businessName} will be hidden from the public directory until reinstated.',
      confirmLabel: 'Suspend',
    );
    if (reason == null) return;
    ref.read(vendorsProvider.notifier).setStatus(vendor.id, VendorStatus.suspended, reason: reason.isEmpty ? null : reason);
  }

  Future<void> _reinstate(BuildContext context, WidgetRef ref, AdminVendor vendor) async {
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'Reinstate Vendor',
      message: '${vendor.businessName} will become visible in the public directory again.',
      confirmLabel: 'Reinstate',
      destructive: false,
    );
    if (confirmed) ref.read(vendorsProvider.notifier).setStatus(vendor.id, VendorStatus.active);
  }

  Future<void> _block(BuildContext context, WidgetRef ref, AdminVendor vendor) async {
    final reason = await showAdminReasonDialog(
      context,
      title: 'Block Vendor',
      message: '${vendor.businessName} will be permanently removed from the platform. This cannot be undone from this screen.',
      confirmLabel: 'Block Permanently',
      reasonRequired: true,
    );
    if (reason == null) return;
    ref.read(vendorsProvider.notifier).setStatus(vendor.id, VendorStatus.blocked, reason: reason);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendors = ref.watch(vendorsProvider);
    AdminVendor? vendor;
    for (final v in vendors) {
      if (v.id == vendorId) vendor = v;
    }

    if (vendor == null) {
      return const Scaffold(body: Center(child: Text('This vendor no longer exists.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(vendor.businessName)),
      body: ListView(
        padding: const EdgeInsets.all(AdminSpacing.margin),
        children: [
          Row(
            children: [
              Expanded(child: Text(vendor.businessName, style: AdminTextStyles.headlineMd())),
              VendorStatusChip(status: vendor.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(vendor.categoryLabel, style: AdminTextStyles.bodyMd()),
          const SizedBox(height: 20),
          Container(
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
                _row('Location', vendor.location),
                _row('Rating', '${vendor.ratingAvg.toStringAsFixed(1)} ★ (${vendor.ratingCount} reviews)'),
                _row('Joined', _formatDate(vendor.createdAt)),
                _row('Last Updated', _formatDate(vendor.updatedAt)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => VendorAnalyticsScreen(vendorId: vendor!.id, vendorName: vendor.businessName)),
              ),
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('View Analytics'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (vendor.status == VendorStatus.suspended)
                Expanded(
                  child: OutlinedButton(onPressed: () => _reinstate(context, ref, vendor!), child: const Text('Reinstate')),
                )
              else if (vendor.status == VendorStatus.active)
                Expanded(
                  child: OutlinedButton(onPressed: () => _suspend(context, ref, vendor!), child: const Text('Suspend')),
                ),
              if (vendor.status != VendorStatus.blocked) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AdminColors.error, side: const BorderSide(color: AdminColors.error)),
                    onPressed: () => _block(context, ref, vendor!),
                    child: const Text('Block'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(label, style: AdminTextStyles.labelSm())),
            Expanded(child: Text(value, style: AdminTextStyles.bodyLg())),
          ],
        ),
      );

  String _formatDate(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
