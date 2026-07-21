import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../models/vendor.dart';
import '../providers/business_providers.dart';
import '../services/mock_business_stats.dart';
import '../services/quality_score_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/business_switcher_sheet.dart';
import '../widgets/notifications_timeline.dart';
import '../widgets/quality_score_card.dart';
import '../widgets/status_pill.dart';
import 'add_business_screen.dart';
import 'add_edit_service_screen.dart';
import 'business_details_screen.dart';
import 'create_package_screen.dart';
import 'listing_preview_screen.dart';
import 'manage_features_screen.dart';
import 'manage_photos_screen.dart';
import 'shell/business_flow.dart';

/// Tab 1 — "Dashboard". A status card (business name, verification badge,
/// profile completion, primary actions) leads, then the Business Quality
/// Score checklist, smart suggestions, a market/competitor comparison, and
/// quick actions. All performance analysis (views, engagement, ratings,
/// reviews) lives exclusively in the Analytics tab — nothing here
/// duplicates it.
/// Recent-activity notifications live behind the AppBar's bell icon rather
/// than taking up scroll space.
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

  void _createPackage(BuildContext context, WidgetRef ref, Business business) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreatePackageScreen(business: business))).then((_) => _refresh(ref));
  }

  void _businessDetails(BuildContext context, WidgetRef ref, Business business) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessDetailsScreen(business: business))).then((_) => _refresh(ref));
  }

  void _previewListing(BuildContext context, Business business) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ListingPreviewScreen(business: business)));
  }

  void _showNotifications(BuildContext context, BusinessStats stats) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications', style: AppTextStyles.headlineMd()),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: NotificationsTimeline(stats: stats),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performAction(BuildContext context, WidgetRef ref, Business business, QualityAction action) {
    switch (action) {
      case QualityAction.editProfile:
        _editProfile(context, ref, business);
      case QualityAction.addService:
        _addService(context, ref, business);
      case QualityAction.createPackage:
        _createPackage(context, ref, business);
      case QualityAction.uploadPhotos:
        _addPhotos(context, ref, business);
      case QualityAction.manageFeatures:
        _manageFeatures(context, ref, business);
      case QualityAction.businessDetails:
        _businessDetails(context, ref, business);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(vendorProvider);
    final businesses = ref.watch(businessesProvider);
    final activeId = ref.watch(activeBusinessIdProvider);
    final business = activeBusinessOf(businesses, activeId);
    final stats = business == null ? null : generateBusinessStats(business);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (stats != null)
            IconButton(
              icon: const Badge(smallSize: 8, backgroundColor: AppColors.error, child: Icon(Icons.notifications_outlined)),
              tooltip: 'Notifications',
              color: AppColors.primary,
              onPressed: () => _showNotifications(context, stats),
            ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Business',
            color: AppColors.primary,
            onPressed: () => startAddBusinessFlow(context, ref),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: business == null || stats == null
                ? _noBusiness(context, ref)
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => _refresh(ref),
                    child: _content(context, ref, vendor, business),
                  ),
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
    final quality = computeQualityScore(business);

    void completeItem(ChecklistItem item) => _performAction(context, ref, business, item.action);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _StatusCard(
          business: business,
          completionPercent: quality.percentage,
          onSwitchBusiness: () => BusinessSwitcherSheet.show(context),
          onEditInfo: () => _editProfile(context, ref, business),
          onPreview: () => _previewListing(context, business),
        ),
        const SizedBox(height: 28),
        const _DashboardSectionHeader(
          title: 'Profile health',
          subtitle: 'A stronger profile helps more customers discover and trust you.',
        ),
        const SizedBox(height: 12),
        QualityScoreHeaderCard(result: quality),
        const SizedBox(height: 16),
        Text('Recommended next steps', style: AppTextStyles.labelMd()),
        const SizedBox(height: 12),
        QualityChecklist(result: quality, onComplete: completeItem),
        const SizedBox(height: 24),
        // Prominent "Add Features" call-to-action
        _AddFeaturesCTA(onTap: () => _manageFeatures(context, ref, business)),
      ],
    );
  }
}

/// The Dashboard's top "status card" — business name, an Active & Verified
/// badge, a Profile Completion progress bar, and a compact edit action.
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.business,
    required this.completionPercent,
    required this.onSwitchBusiness,
    required this.onEditInfo,
    required this.onPreview,
  });

  final Business business;
  final int completionPercent;
  final VoidCallback onSwitchBusiness;
  final VoidCallback onEditInfo;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.margin),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .3)),
        boxShadow: [
          BoxShadow(color: AppColors.onSurface.withValues(alpha: .04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onSwitchBusiness,
                  borderRadius: BorderRadius.circular(AppRadius.dflt),
                  child: Row(
                    children: [
                      Flexible(child: Text(business.name, style: AppTextStyles.headlineMd(color: AppColors.primary))),
                      const SizedBox(width: 4),
                      const Icon(Icons.unfold_more_rounded, size: 20, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CompactIconButton(icon: Icons.visibility_outlined, tooltip: 'Preview listing', onPressed: onPreview),
              const SizedBox(width: 8),
              _CompactEditButton(onPressed: onEditInfo),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusPill(status: business.status),
              const SizedBox(width: 8),
              if (business.status == BusinessStatus.active) const _PendingBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.gutter),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile Completion', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
              Text('$completionPercent%', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: completionPercent / 100,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact "Edit Your Information" button placed inline in the status card.
class _CompactEditButton extends StatelessWidget {
  const _CompactEditButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppRadius.dflt),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.dflt),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Edit Info', style: AppTextStyles.labelSm(color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact square icon-only button used in the status card header (e.g.
/// Preview), styled to match [_CompactEditButton].
class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppRadius.dflt),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.dflt),
        child: Tooltip(
          message: tooltip,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_top, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text('Pending Verification', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Prominent "Add Features" call-to-action card encouraging vendors to
/// add more details for better search visibility.
class _AddFeaturesCTA extends StatelessWidget {
  const _AddFeaturesCTA({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryContainer.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Features',
                      style: AppTextStyles.headlineMd(color: AppColors.onPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stand out from the competition',
                      style: AppTextStyles.labelSm(color: AppColors.onPrimary.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Businesses with complete profiles and detailed features appear higher in searches and get more customer inquiries. Add your unique offerings to improve visibility.',
            style: AppTextStyles.bodyMd(color: AppColors.onPrimary.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: Text('Manage Features', style: AppTextStyles.labelMd(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  const _DashboardSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineMd()),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodyMd()),
        ],
      );
}
