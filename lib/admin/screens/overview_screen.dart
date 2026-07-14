import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_vendor.dart';
import '../providers/admin_providers.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';
import '../theme/admin_theme.dart';
import '../widgets/stat_card.dart';

/// Screen — "Overview". The superuser landing page: platform-health stat
/// cards, with the two queue-backed cards deep-linking into their queues.
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  void _goToPendingVendors(WidgetRef ref) {
    ref.read(vendorsInitialFilterProvider.notifier).state = VendorStatus.pending;
    ref.read(adminSectionProvider.notifier).state = AdminSection.vendors;
  }

  void _goToReportedReviews(WidgetRef ref) {
    ref.read(reviewsShowReportedOnlyProvider.notifier).state = true;
    ref.read(adminSectionProvider.notifier).state = AdminSection.reviews;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(currentAdminProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard', style: AdminTextStyles.headlineLg()),
            const SizedBox(height: 4),
            Text('Welcome back, ${admin.name} · ${admin.roleLabel}', style: AdminTextStyles.bodyLg(color: AdminColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AdminSpacing.gutter,
              mainAxisSpacing: AdminSpacing.gutter,
              childAspectRatio: isWide ? 1.3 : 0.85,
              children: [
                AdminStatCard(
                  label: 'Total Users',
                  value: '${stats.totalUsers}',
                  subtitle: 'Since last Monday',
                  icon: Icons.people_outline,
                ),
                AdminStatCard(
                  label: 'Active Vendors',
                  value: '${stats.activeVendors}',
                  subtitle: 'Verified listings',
                  icon: Icons.storefront_outlined,
                ),
                AdminStatCard(
                  label: 'Pending Approvals',
                  value: '${stats.pendingApprovals}',
                  subtitle: 'Awaiting manual review',
                  icon: Icons.hourglass_top,
                  flagLabel: 'ACTION REQ',
                  flagColor: AdminColors.warning,
                  onTap: () => _goToPendingVendors(ref),
                ),
                AdminStatCard(
                  label: 'Reported Reviews',
                  value: '${stats.reportedReviews}',
                  subtitle: 'Policy violations',
                  icon: Icons.flag_outlined,
                  flagLabel: 'URGENT',
                  flagColor: AdminColors.error,
                  onTap: () => _goToReportedReviews(ref),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Quick Links', style: AdminTextStyles.headlineMd()),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickLink(
                  icon: Icons.hourglass_top,
                  label: 'Review Pending Vendors',
                  onTap: () => _goToPendingVendors(ref),
                ),
                _QuickLink(
                  icon: Icons.flag_outlined,
                  label: 'Moderate Reported Reviews',
                  onTap: () => _goToReportedReviews(ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AdminColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AdminRadius.sm),
          border: Border.all(color: AdminColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AdminColors.primary),
            const SizedBox(width: 8),
            Text(label, style: AdminTextStyles.labelMd()),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: AdminColors.outline),
          ],
        ),
      ),
    );
  }
}
