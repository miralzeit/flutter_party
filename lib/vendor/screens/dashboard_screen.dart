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
import '../widgets/ai_insight_card.dart';
import '../widgets/ai_search_optimization_card.dart';
import '../widgets/business_switcher_sheet.dart';
import '../widgets/metric_card.dart';
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

/// Tab 1 — "Dashboard". Leads with the Business Quality Score and AI search
/// insights (the strongest incentive for a vendor to keep their profile
/// complete), then the usual glanceable stats: headline profile-views,
/// quick-overview metric grid, competitor comparison, and quick actions.
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

  /// Your business plus a few mock nearby competitors, ranked by rating.
  List<({String name, double avgRating, int reviewsCount, bool isYou})> _rankedCompetitors(
    Business business,
    BusinessStats stats,
  ) {
    final rows = [
      (name: business.name, avgRating: stats.avgRating, reviewsCount: stats.reviewsCount, isYou: true),
      for (final competitor in generateCompetitors(business))
        (name: competitor.name, avgRating: competitor.avgRating, reviewsCount: competitor.reviewsCount, isYou: false),
    ];
    rows.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    return rows;
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: business == null || stats == null
                ? _noBusiness(context, ref)
                : _content(context, ref, vendor, business, stats),
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
    final aiSearch = computeAiSearchOptimization(business, quality);
    final aiInsight = computeAiInsight(business, quality);
    final suggestions = computeSuggestions(business, quality);
    final nameParts = (vendor?.fullName ?? '').trim().split(' ');
    final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty ? nameParts.first : 'there';

    void completeItem(ChecklistItem item) => _performAction(context, ref, business, item.action);

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
        const SizedBox(height: 28),
        QualityScoreHeaderCard(result: quality),
        const SizedBox(height: 20),
        Text('Complete Your Profile', style: AppTextStyles.labelMd()),
        const SizedBox(height: 12),
        QualityChecklist(result: quality, onComplete: completeItem),
        const SizedBox(height: 12),
        AiSearchOptimizationCard(optimization: aiSearch),
        if (aiInsight != null) ...[
          const SizedBox(height: 16),
          AiInsightCard(insight: aiInsight, onCompleteNow: () => _performAction(context, ref, business, aiInsight.action)),
        ],
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text('Smart Suggestions', style: AppTextStyles.labelMd()),
          const SizedBox(height: 12),
          SuggestionsSection(
            suggestions: suggestions,
            onTap: (suggestion) => _performAction(context, ref, business, suggestion.action),
          ),
        ],
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility, size: 32, color: AppColors.onPrimaryContainer),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${stats.totalProfileViews}', style: AppTextStyles.headlineLg(color: AppColors.onPrimaryContainer)),
                  Text('Profile views (last 90 days)', style: AppTextStyles.bodyMd(color: AppColors.onPrimaryContainer)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
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
            Expanded(child: MetricCard(label: 'Reviews', value: '${stats.reviewsCount}', icon: Icons.star_outline)),
            const SizedBox(width: 12),
            Expanded(child: MetricCard(label: 'Calls', value: '${stats.calls}', icon: Icons.call_outlined)),
          ],
        ),
        const SizedBox(height: 28),
        Text('Competitor Comparison', style: AppTextStyles.labelMd()),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              for (final row in _rankedCompetitors(business, stats))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.isYou ? 'You (${business.name})' : row.name,
                          style: AppTextStyles.bodyMd(color: row.isYou ? AppColors.primary : AppColors.onSurface),
                        ),
                      ),
                      const Icon(Icons.star, size: 16, color: AppColors.tertiary),
                      const SizedBox(width: 4),
                      Text(row.avgRating.toStringAsFixed(1), style: AppTextStyles.labelMd()),
                      const SizedBox(width: 6),
                      Text('(${row.reviewsCount})', style: AppTextStyles.labelSm()),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Quick Actions', style: AppTextStyles.labelMd()),
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
}
