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
import '../widgets/quick_action_grid.dart';
import '../widgets/status_pill.dart';
import '../widgets/suggestions_section.dart';
import 'add_business_screen.dart';
import 'add_edit_service_screen.dart';
import 'business_details_screen.dart';
import 'create_package_screen.dart';
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
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
                    child: _content(context, ref, vendor, business, stats),
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

  Widget _content(BuildContext context, WidgetRef ref, Vendor? vendor, Business business, BusinessStats stats) {
    final quality = computeQualityScore(business);
    final suggestions = computeSuggestions(business, quality);

    void completeItem(ChecklistItem item) => _performAction(context, ref, business, item.action);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _StatusCard(
          business: business,
          completionPercent: quality.percentage,
          onSwitchBusiness: () => BusinessSwitcherSheet.show(context),
          onNewBookingInquiry: () => _showComingSoon(context, 'Booking inquiries'),
          onUpdateListing: () => _editProfile(context, ref, business),
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
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _DashboardSectionHeader(
            title: 'Smart suggestions',
            subtitle: 'High-impact actions tailored to your profile.',
          ),
          const SizedBox(height: 12),
          SuggestionsSection(
            suggestions: suggestions,
            onTap: (suggestion) => _performAction(context, ref, business, suggestion.action),
          ),
        ],
        const SizedBox(height: 28),
        const _DashboardSectionHeader(
          title: 'Market comparison',
          subtitle: 'See how your offer compares with nearby businesses.',
        ),
        const SizedBox(height: 4),
        Text('See how you stack up against nearby vendors — pricing, services and amenities.', style: AppTextStyles.bodyMd()),
        const SizedBox(height: 12),
        Column(
          children: [
            for (final row in _rankedCompetitors(business, stats)) _competitorCard(row, business),
          ],
        ),
        const SizedBox(height: 28),
        const _DashboardSectionHeader(
          title: 'Manage your business',
          subtitle: 'Keep your catalogue, photos and details current.',
        ),
        const SizedBox(height: 12),
        QuickActionGrid(
          actions: [
            QuickAction(icon: Icons.add, label: 'Add Service', onTap: () => _addService(context, ref, business)),
            QuickAction(icon: Icons.add_photo_alternate_outlined, label: 'Upload Photos', onTap: () => _addPhotos(context, ref, business)),
            QuickAction(icon: Icons.card_giftcard_outlined, label: 'Create Package', onTap: () => _createPackage(context, ref, business)),
            QuickAction(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () => _editProfile(context, ref, business)),
            QuickAction(icon: Icons.schedule_outlined, label: 'Business Hours', onTap: () => _businessDetails(context, ref, business)),
            QuickAction(icon: Icons.checklist_outlined, label: 'Manage Features', onTap: () => _manageFeatures(context, ref, business)),
          ],
        ),
      ],
    );
  }

  /// Your business plus a few mock nearby competitors, ranked by rating —
  /// including what each one charges and offers, so a vendor can see not
  /// just where they rank but what a competitor actually has that they
  /// don't.
  List<
      ({
        String name,
        double avgRating,
        int reviewsCount,
        bool isYou,
        double? startingPrice,
        List<String> topServices,
        List<String> features,
      })> _rankedCompetitors(Business business, BusinessStats stats) {
    final rows = [
      (
        name: business.name,
        avgRating: stats.avgRating,
        reviewsCount: stats.reviewsCount,
        isYou: true,
        startingPrice: business.basePrice,
        topServices: [for (final service in business.services.take(3)) service.name],
        features: business.features,
      ),
      for (final competitor in generateCompetitors(business))
        (
          name: competitor.name,
          avgRating: competitor.avgRating,
          reviewsCount: competitor.reviewsCount,
          isYou: false,
          startingPrice: competitor.startingPrice,
          topServices: competitor.topServices,
          features: competitor.features,
        ),
    ];
    rows.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    return rows;
  }

  /// One row of the Market Comparison list — name/rating/reviews plus
  /// starting price and what it offers. For competitors (not "you"), also
  /// surfaces amenities they advertise that your own business's feature list
  /// doesn't, so the comparison answers "what do they have that I don't"
  /// rather than just "how do we rank".
  Widget _competitorCard(
    ({
      String name,
      double avgRating,
      int reviewsCount,
      bool isYou,
      double? startingPrice,
      List<String> topServices,
      List<String> features,
    }) row,
    Business business,
  ) {
    final extraFeatures = row.isYou
        ? const <String>[]
        : row.features.where((feature) => !business.features.any((mine) => mine.toLowerCase() == feature.toLowerCase())).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: row.isYou ? AppColors.primaryContainer.withValues(alpha: 0.10) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: row.isYou ? Border.all(color: AppColors.primary.withValues(alpha: 0.4)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.isYou ? 'You (${row.name})' : row.name,
                  style: AppTextStyles.labelMd(color: row.isYou ? AppColors.primary : AppColors.onSurface),
                ),
              ),
              const Icon(Icons.star, size: 16, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(row.avgRating.toStringAsFixed(1), style: AppTextStyles.labelMd()),
              const SizedBox(width: 6),
              Text('(${row.reviewsCount})', style: AppTextStyles.labelSm()),
            ],
          ),
          if (row.startingPrice != null) ...[
            const SizedBox(height: 6),
            Text('Starting at ${row.startingPrice!.toStringAsFixed(0)} ILS', style: AppTextStyles.bodyMd()),
          ],
          if (row.topServices.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(row.isYou ? 'Your services' : 'Offers', style: AppTextStyles.labelSm()),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final service in row.topServices)
                  _chip(service, background: AppColors.surfaceContainerLowest, foreground: AppColors.onSurfaceVariant),
              ],
            ),
          ],
          if (extraFeatures.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text('Also offers', style: AppTextStyles.labelSm(color: AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final feature in extraFeatures)
                  _chip(feature, background: AppColors.secondaryContainer.withValues(alpha: 0.35), foreground: AppColors.secondary),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, {required Color background, required Color foreground}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(label, style: AppTextStyles.labelSm(color: foreground)),
    );
  }
}

/// The Dashboard's top "status card" — business name, an Active & Verified
/// badge, a Profile Completion progress bar, and two primary actions.
/// Matches the vendor_dashboard reference's status section exactly (a plain
/// surface card rather than the app's previous gradient hero banner).
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.business,
    required this.completionPercent,
    required this.onSwitchBusiness,
    required this.onNewBookingInquiry,
    required this.onUpdateListing,
  });

  final Business business;
  final int completionPercent;
  final VoidCallback onSwitchBusiness;
  final VoidCallback onNewBookingInquiry;
  final VoidCallback onUpdateListing;

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
          InkWell(
            onTap: onSwitchBusiness,
            borderRadius: BorderRadius.circular(AppRadius.dflt),
            child: Row(
              children: [
                Expanded(child: Text(business.name, style: AppTextStyles.headlineMd(color: AppColors.primary))),
                const Icon(Icons.unfold_more_rounded, color: AppColors.onSurfaceVariant),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (business.status == BusinessStatus.active) const _VerifiedBadge() else StatusPill(status: business.status),
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
          const SizedBox(height: AppSpacing.gutter),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onNewBookingInquiry,
                  child: const Text('New Booking Inquiry'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onUpdateListing,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.onSecondaryContainer,
                    side: BorderSide.none,
                  ),
                  child: const Text('Update Listing'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.onTertiaryContainer.withValues(alpha: .2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 14, color: AppColors.onTertiaryContainer),
          const SizedBox(width: 4),
          Text('Active & Verified', style: AppTextStyles.labelSm(color: AppColors.onTertiaryContainer)),
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
