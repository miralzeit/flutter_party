import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../models/business.dart';
import '../models/vendor.dart';
import '../providers/business_providers.dart';
import '../services/mock_business_stats.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/business_switcher_sheet.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_pill.dart';
import 'add_business_screen.dart';
import 'add_edit_service_screen.dart';
import 'manage_features_screen.dart';
import 'manage_photos_screen.dart';
import 'shell/business_flow.dart';

/// Tab 1 — "Dashboard". A glanceable summary, not a form: greeting, business
/// switcher + status, a quick-overview metric grid, recent activity, and
/// quick actions into the flows that already exist elsewhere.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _refresh(WidgetRef ref) => ref.read(businessesProvider.notifier).touch();

  void _addService(BuildContext context, WidgetRef ref, Business business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          onSubmit: (service) {
            business.services.add(service);
            _refresh(ref);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _addPhotos(BuildContext context, WidgetRef ref, Business business) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManagePhotosScreen(business: business))).then((_) => _refresh(ref));
  }

  void _editProfile(BuildContext context, WidgetRef ref, Business business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBusinessScreen(
          initial: business,
          onSubmit: (_) {
            _refresh(ref);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _manageFeatures(BuildContext context, WidgetRef ref, Business business) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManageFeaturesScreen(business: business))).then((_) => _refresh(ref));
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorProvider);
    final businesses = ref.watch(businessesProvider);
    final activeId = ref.watch(activeBusinessIdProvider);
    final business = activeBusinessOf(businesses, activeId);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: business == null
                ? _noBusiness(context, ref)
                : _content(context, ref, vendor, business),
          ),
        ),
      ),
    );
  }

  Widget _noBusiness(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add your first business to see your dashboard.', textAlign: TextAlign.center, style: AppTextStyles.bodyLg()),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => startAddBusinessFlow(context, ref),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
              icon: const Icon(Icons.add),
              label: const Text('Add Business'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, Vendor? vendor, Business business) {
    final stats = generateBusinessStats(business);
    final nameParts = (vendor?.fullName ?? '').trim().split(' ');
    final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty ? nameParts.first : 'there';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('${_greeting()}, $firstName', style: AppTextStyles.headlineLgMobile()),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => BusinessSwitcherSheet.show(context),
          borderRadius: BorderRadius.circular(AppRadius.dflt),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: Text(business.name, style: AppTextStyles.headlineMd())),
                const Icon(Icons.expand_more, color: AppColors.outline),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        StatusPill(status: business.status),
        const SizedBox(height: 24),
        Text('Quick Overview', style: AppTextStyles.labelMd()),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: MetricCard(label: 'Services', value: '${business.services.length}', icon: Icons.room_service_outlined)),
            const SizedBox(width: 12),
            Expanded(child: MetricCard(label: 'Photos', value: '${business.photoCount}', icon: Icons.photo_library_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: MetricCard(label: 'Profile Views', value: '${stats.totalProfileViews}', icon: Icons.visibility_outlined)),
            const SizedBox(width: 12),
            Expanded(child: MetricCard(label: 'Reviews', value: '${stats.reviewsCount}', icon: Icons.star_outline)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Recent Activity', style: AppTextStyles.labelMd()),
        const SizedBox(height: 12),
        if (stats.activity.isEmpty)
          Text('No activity yet — your recent updates will show up here.', style: AppTextStyles.bodyMd())
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                for (final event in stats.activity.take(8))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Icon(event.icon, size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(child: Text(event.description, style: AppTextStyles.bodyMd(color: AppColors.onSurface))),
                        Text(relativeTime(event.timestamp), style: AppTextStyles.labelSm()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('Quick Actions', style: AppTextStyles.labelMd()),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.add, size: 18, color: AppColors.primary),
              label: const Text('Add Service'),
              onPressed: () => _addService(context, ref, business),
            ),
            ActionChip(
              avatar: const Icon(Icons.add_photo_alternate_outlined, size: 18, color: AppColors.primary),
              label: const Text('Add Photos'),
              onPressed: () => _addPhotos(context, ref, business),
            ),
            ActionChip(
              avatar: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
              label: const Text('Edit Profile'),
              onPressed: () => _editProfile(context, ref, business),
            ),
            ActionChip(
              avatar: const Icon(Icons.checklist_outlined, size: 18, color: AppColors.primary),
              label: const Text('Manage Features'),
              onPressed: () => _manageFeatures(context, ref, business),
            ),
          ],
        ),
      ],
    );
  }
}
