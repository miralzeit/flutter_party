import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_category.dart';
import '../models/admin_review.dart';
import '../models/admin_user.dart';
import '../models/admin_vendor.dart';
import '../models/audit_log_entry.dart';
import '../models/dashboard_stats.dart';
import '../models/vendor_analytics.dart';
import '../models/vendor_application.dart';
import '../services/admin_mock_data.dart';

/// The 8 sidebar destinations. Checklists/Broadcast/Settings have no
/// detailed spec — they're stubbed placeholder screens so the IA matches
/// the design's nav list.
enum AdminSection { overview, vendors, categories, reviews, analytics, checklists, broadcast, settings }

final adminSectionProvider = StateProvider<AdminSection>((ref) => AdminSection.overview);

/// Set by Overview's stat-card deep links right before switching
/// [adminSectionProvider] to `vendors`, so the Vendors screen opens on the
/// right status tab instead of always defaulting to "All".
final vendorsInitialFilterProvider = StateProvider<VendorStatus?>((ref) => null);

/// Same idea for Reviews — set before switching to `reviews` so it opens
/// straight on the "Reported" tab.
final reviewsShowReportedOnlyProvider = StateProvider<bool>((ref) => false);

final currentAdminProvider = Provider<AdminUser>((ref) => AdminMockData.admin());

/// Every state-changing admin action appends here — actor, timestamp, and
/// what happened — per the audit-logging requirement.
class AuditLogNotifier extends Notifier<List<AuditLogEntry>> {
  @override
  List<AuditLogEntry> build() => [];

  void log(String action, {String targetLabel = '', String? note}) {
    final admin = ref.read(currentAdminProvider);
    state = [
      AuditLogEntry(action: action, actor: admin.name, targetLabel: targetLabel, note: note),
      ...state,
    ];
  }
}

final auditLogProvider = NotifierProvider<AuditLogNotifier, List<AuditLogEntry>>(AuditLogNotifier.new);

class VendorsNotifier extends Notifier<List<AdminVendor>> {
  @override
  List<AdminVendor> build() => AdminMockData.vendors();

  void _touch() => state = [...state];

  void setStatus(String vendorId, VendorStatus status, {String? reason}) {
    final vendor = state.firstWhere((v) => v.id == vendorId);
    vendor.status = status;
    vendor.updatedAt = DateTime.now();
    _touch();
    ref.read(auditLogProvider.notifier).log(
          'vendor.${status.name}',
          targetLabel: vendor.businessName,
          note: reason,
        );
  }
}

final vendorsProvider = NotifierProvider<VendorsNotifier, List<AdminVendor>>(VendorsNotifier.new);

class ApplicationsNotifier extends Notifier<List<VendorApplication>> {
  @override
  List<VendorApplication> build() => AdminMockData.applications();

  void _touch() => state = [...state];

  void _appendTimeline(VendorApplication application, String label, String actor, {String note = ''}) {
    application.timeline = [
      ...application.timeline,
      ApplicationTimelineEvent(label: label, actor: actor, note: note),
    ];
  }

  void approve(String applicationId) {
    final application = state.firstWhere((a) => a.id == applicationId);
    final admin = ref.read(currentAdminProvider);
    application.stage = ApplicationStage.approved;
    application.decidedAt = DateTime.now();
    application.decidedBy = admin.name;
    _appendTimeline(application, 'Approved', admin.name);
    // Promote the application into the live vendor directory.
    ref.read(vendorsProvider.notifier).state = [
      ...ref.read(vendorsProvider),
      AdminVendor(
        id: application.vendorId,
        businessName: application.businessName,
        category: application.category,
        city: application.city,
        neighborhood: application.neighborhood,
        status: VendorStatus.active,
      ),
    ];
    _touch();
    ref.read(auditLogProvider.notifier).log('application.approved', targetLabel: application.businessName);
  }

  void reject(String applicationId, {required String reason}) {
    final application = state.firstWhere((a) => a.id == applicationId);
    final admin = ref.read(currentAdminProvider);
    application.stage = ApplicationStage.rejected;
    application.decidedAt = DateTime.now();
    application.decidedBy = admin.name;
    application.rejectionReason = reason;
    _appendTimeline(application, 'Rejected', admin.name, note: reason);
    _touch();
    ref.read(auditLogProvider.notifier).log('application.rejected', targetLabel: application.businessName, note: reason);
  }

  void requestMoreInfo(String applicationId, {required String message}) {
    final application = state.firstWhere((a) => a.id == applicationId);
    final admin = ref.read(currentAdminProvider);
    application.stage = ApplicationStage.infoRequested;
    _appendTimeline(application, 'Requested More Info', admin.name, note: message);
    _touch();
    ref.read(auditLogProvider.notifier).log('application.info_requested', targetLabel: application.businessName, note: message);
  }
}

final applicationsProvider = NotifierProvider<ApplicationsNotifier, List<VendorApplication>>(ApplicationsNotifier.new);

class CategoriesNotifier extends Notifier<List<AdminCategory>> {
  @override
  List<AdminCategory> build() => AdminMockData.categories();

  void _touch() => state = [...state];

  void upsert(AdminCategory category) {
    final index = state.indexWhere((c) => c.id == category.id);
    if (index == -1) {
      state = [...state, category];
    } else {
      state = [for (final c in state) if (c.id == category.id) category else c];
    }
    ref.read(auditLogProvider.notifier).log(index == -1 ? 'category.created' : 'category.updated', targetLabel: category.name);
  }

  void toggleActive(String categoryId) {
    final category = state.firstWhere((c) => c.id == categoryId);
    category.isActive = !category.isActive;
    _touch();
    ref.read(auditLogProvider.notifier).log(category.isActive ? 'category.activated' : 'category.deactivated', targetLabel: category.name);
  }

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    for (var i = 0; i < list.length; i++) {
      list[i].displayOrder = i + 1;
    }
    state = list;
  }
}

final categoriesProvider = NotifierProvider<CategoriesNotifier, List<AdminCategory>>(CategoriesNotifier.new);

class ReviewsNotifier extends Notifier<List<AdminReview>> {
  @override
  List<AdminReview> build() => AdminMockData.reviews();

  void _touch() => state = [...state];

  void setModerationStatus(String reviewId, ModerationStatus status) {
    final review = state.firstWhere((r) => r.id == reviewId);
    final admin = ref.read(currentAdminProvider);
    review.moderationStatus = status;
    review.moderatedBy = admin.name;
    review.moderatedAt = DateTime.now();
    if (status == ModerationStatus.published) review.reportReasons = [];
    _touch();
    ref.read(auditLogProvider.notifier).log('review.${status.name}', targetLabel: '${review.reviewerName} → ${review.vendorName}');
  }
}

final reviewsProvider = NotifierProvider<ReviewsNotifier, List<AdminReview>>(ReviewsNotifier.new);

/// Overview screen counts. [DashboardStats.totalUsers] has no backing list
/// in this mock data model, so it's the one figure that isn't derived.
final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final vendors = ref.watch(vendorsProvider);
  final applications = ref.watch(applicationsProvider);
  final reviews = ref.watch(reviewsProvider);
  return DashboardStats(
    totalUsers: AdminMockData.totalUsers,
    activeVendors: vendors.where((v) => v.status == VendorStatus.active).length,
    pendingApprovals: applications.where((a) => a.stage.isOpen).length,
    reportedReviews: reviews.where((r) => r.isReported && r.moderationStatus == ModerationStatus.published).length,
  );
});

final vendorAnalyticsProvider = Provider.family<VendorAnalytics, String>((ref, vendorId) => AdminMockData.analyticsFor(vendorId));
