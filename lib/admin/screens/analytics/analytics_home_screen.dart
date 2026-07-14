import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_providers.dart';
import '../../theme/admin_colors.dart';
import '../../theme/admin_text_styles.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_empty_state.dart';
import '../../widgets/vendor_status_chip.dart';
import 'vendor_analytics_screen.dart';

/// Screen — "Analytics" landing. §5.8's Vendor Analytics view is per-vendor
/// and primarily opened from a vendor's record, but the sidebar also lists
/// a standalone "Analytics" destination — this is that entry point: pick a
/// vendor, then view their read-only analytics.
class AnalyticsHomeScreen extends ConsumerStatefulWidget {
  const AnalyticsHomeScreen({super.key});

  @override
  ConsumerState<AnalyticsHomeScreen> createState() => _AnalyticsHomeScreenState();
}

class _AnalyticsHomeScreenState extends ConsumerState<AnalyticsHomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final vendors = ref.watch(vendorsProvider);
    final filtered = vendors.where((v) => v.businessName.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(AdminSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a vendor to view their performance analytics.', style: AdminTextStyles.bodyLg()),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by business name'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const AdminEmptyState(icon: Icons.analytics_outlined, message: 'No vendors match your search.')
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final vendor = filtered[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(AdminRadius.sm),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => VendorAnalyticsScreen(vendorId: vendor.id, vendorName: vendor.businessName)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AdminColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AdminRadius.sm),
                              border: Border.all(color: AdminColors.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(vendor.businessName, style: AdminTextStyles.labelMd()),
                                      const SizedBox(height: 2),
                                      Text(vendor.categoryLabel, style: AdminTextStyles.bodyMd()),
                                    ],
                                  ),
                                ),
                                VendorStatusChip(status: vendor.status),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, color: AdminColors.outline),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
