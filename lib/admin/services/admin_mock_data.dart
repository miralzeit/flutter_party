import 'dart:math';
import '../models/admin_category.dart';
import '../models/admin_review.dart';
import '../models/admin_user.dart';
import '../models/admin_vendor.dart';
import '../models/vendor_analytics.dart';
import '../models/vendor_application.dart';

/// Seed data for the Admin Panel demo, matching the spec's §8 mock dataset
/// as closely as a small illustrative sample can. [totalUsers] has no
/// backing list in this data model (no end-customer "User" entity is
/// specified) so it stays a fixed mock figure; every other Overview stat is
/// computed live from the lists below (see `dashboard_stats_provider`).
class AdminMockData {
  AdminMockData._();

  static const int totalUsers = 8420;

  static AdminUser admin() => AdminUser(id: 'admin_001', name: 'Jamie Rivera', email: 'jamie.rivera@eventpro.com');

  static List<AdminCategory> categories() => [
        AdminCategory(id: 'cat_venue', name: 'Venues', description: 'Wedding halls, banquet spaces, and event venues.', icon: 'apartment', displayOrder: 1),
        AdminCategory(id: 'cat_catering', name: 'Catering', description: 'Full-service catering, buffets, and food stations.', icon: 'restaurant', displayOrder: 2),
        AdminCategory(id: 'cat_photo', name: 'Photography', description: 'Event photography and videography services.', icon: 'camera', displayOrder: 3),
        AdminCategory(id: 'cat_entertainment', name: 'Entertainment', description: 'DJs, live bands, and performers.', icon: 'celebration', displayOrder: 4),
        AdminCategory(id: 'cat_decor', name: 'Decor', description: 'Styling, decor, and floral design.', icon: 'brush', displayOrder: 5),
        AdminCategory(id: 'cat_flowers', name: 'Flowers', description: 'Bouquets, centerpieces, and floral installations.', icon: 'redeem', displayOrder: 6),
        AdminCategory(id: 'cat_bakery', name: 'Bakery', description: 'Cakes, desserts, and sweet tables.', icon: 'cake', displayOrder: 7),
        AdminCategory(id: 'cat_transport', name: 'Transport', description: 'Guest shuttles and luxury transport.', icon: 'sync', displayOrder: 8, isActive: false),
        AdminCategory(id: 'cat_apparel', name: 'Apparel', description: 'Formalwear and bridal attire.', icon: 'sort', displayOrder: 9),
        AdminCategory(id: 'cat_other', name: 'Other', description: 'Miscellaneous event services.', icon: 'info', displayOrder: 10),
      ];

  static List<AdminVendor> vendors() => [
        AdminVendor(
          id: 'v_001',
          businessName: 'Elite Palate Catering',
          category: 'Catering',
          subcategory: 'Catering',
          city: 'Portland',
          state: 'OR',
          status: VendorStatus.active,
          ratingAvg: 4.8,
          ratingCount: 132,
        ),
        AdminVendor(
          id: 'v_002',
          businessName: 'Midnight Soundscapes',
          category: 'Entertainment',
          subcategory: 'DJ',
          city: 'Seattle',
          state: 'WA',
          status: VendorStatus.active,
          ratingAvg: 4.6,
          ratingCount: 87,
        ),
        AdminVendor(
          id: 'v_003',
          businessName: 'Sonic Horizon Audio',
          category: 'Entertainment',
          subcategory: 'DJ',
          city: 'Seattle',
          state: 'WA',
          status: VendorStatus.suspended,
          ratingAvg: 3.9,
          ratingCount: 41,
        ),
        AdminVendor(
          id: 'v_004',
          businessName: 'Vivid Frame Media',
          category: 'Photography',
          subcategory: 'Videography',
          city: 'Portland',
          state: 'OR',
          status: VendorStatus.active,
          ratingAvg: 4.9,
          ratingCount: 204,
        ),
      ];

  static List<VendorApplication> applications() => [
        VendorApplication(
          id: 'app_101',
          vendorId: 'pending_v_101',
          businessName: 'Aura Floral Design',
          category: 'Flowers',
          city: 'Bethlehem',
          neighborhood: 'Heritage Mile',
          stage: ApplicationStage.systemVerified,
          submittedAt: DateTime.utc(2024, 5, 10, 9, 15),
          businessDescription:
              'Boutique floral studio specializing in modern, seasonal wedding arrangements and large-scale installations.',
          businessLicenseId: 'BL-2024-88213',
          address: '45 Heritage Mile, Bethlehem, PA 18015',
          contactName: 'Sarah Jenkins',
          contactEmail: 'sarah@aurafloral.com',
          contactPhone: '+1 (610) 555-0148',
          systemVerificationStatus: VerificationStatus.verified,
          timeline: [
            ApplicationTimelineEvent(label: 'Submitted', actor: 'Vendor', timestamp: DateTime.utc(2024, 5, 10, 9, 15)),
            ApplicationTimelineEvent(
              label: 'System Verified',
              actor: 'System',
              note: 'Verified by System',
              timestamp: DateTime.utc(2024, 5, 10, 9, 16),
            ),
          ],
        ),
        _basicApplication(
          id: 'app_102',
          vendorId: 'pending_v_102',
          businessName: 'Grand Hall Bethlehem',
          category: 'Venues',
          city: 'Bethlehem',
          neighborhood: 'Heritage Mile',
          stage: ApplicationStage.submitted,
          submittedAt: DateTime.utc(2024, 5, 11, 14, 2),
        ),
        _basicApplication(
          id: 'app_103',
          vendorId: 'pending_v_103',
          businessName: 'Modern Beats DJ',
          category: 'Entertainment',
          city: 'New York',
          neighborhood: 'Brooklyn Heights',
          stage: ApplicationStage.submitted,
          submittedAt: DateTime.utc(2024, 5, 12, 11, 47),
        ),
        _basicApplication(
          id: 'app_104',
          vendorId: 'pending_v_104',
          businessName: 'Premium Event Venue',
          category: 'Venues',
          city: 'London',
          neighborhood: 'Chelsea District',
          stage: ApplicationStage.systemVerified,
          submittedAt: DateTime.utc(2024, 5, 12, 16, 30),
        ),
        _basicApplication(
          id: 'app_105',
          vendorId: 'pending_v_105',
          businessName: 'Skyline Terrace Events',
          category: 'Venues',
          city: 'San Francisco',
          neighborhood: 'SoMa',
          stage: ApplicationStage.submitted,
          submittedAt: DateTime.utc(2024, 5, 13, 8, 5),
        ),
      ];

  static VendorApplication _basicApplication({
    required String id,
    required String vendorId,
    required String businessName,
    required String category,
    required String city,
    required String neighborhood,
    required ApplicationStage stage,
    required DateTime submittedAt,
  }) {
    final timeline = [ApplicationTimelineEvent(label: 'Submitted', actor: 'Vendor', timestamp: submittedAt)];
    if (stage == ApplicationStage.systemVerified) {
      timeline.add(ApplicationTimelineEvent(
        label: 'System Verified',
        actor: 'System',
        note: 'Verified by System',
        timestamp: submittedAt.add(const Duration(minutes: 1)),
      ));
    }
    return VendorApplication(
      id: id,
      vendorId: vendorId,
      businessName: businessName,
      category: category,
      city: city,
      neighborhood: neighborhood,
      stage: stage,
      submittedAt: submittedAt,
      systemVerificationStatus: stage == ApplicationStage.systemVerified ? VerificationStatus.verified : VerificationStatus.unverified,
      timeline: timeline,
    );
  }

  static List<AdminReview> reviews() => [
        AdminReview(
          id: 'rev_1',
          vendorName: 'Grand Hotel Ballroom',
          reviewerName: 'John Doe',
          reviewerType: ReviewerType.verifiedGuest,
          rating: 5,
          date: DateTime.utc(2024, 5, 15),
          body: 'Everything about the venue was perfect for our reception.',
        ),
        AdminReview(
          id: 'rev_2',
          vendorName: 'Luxe Lighting Co.',
          reviewerName: 'Maria Kim',
          reviewerType: ReviewerType.guest,
          rating: 1,
          date: DateTime.utc(2024, 5, 15),
          body: 'Terrible service, would not recommend to anyone.',
          reportReasons: [ReportReason.fakeReview, ReportReason.newAccount],
        ),
        AdminReview(
          id: 'rev_3',
          vendorName: 'Prestige Catering',
          reviewerName: 'Bob Thompson',
          reviewerType: ReviewerType.verifiedGuest,
          rating: 2,
          date: DateTime.utc(2024, 5, 14),
          body: 'Check out my catering business instead, link in bio!',
          reportReasons: [ReportReason.spam],
        ),
        AdminReview(
          id: 'rev_4',
          vendorName: 'Urban Venue X',
          reviewerName: 'Jordan Smith',
          reviewerType: ReviewerType.guest,
          rating: 1,
          date: DateTime.utc(2024, 5, 14),
          body: 'Reported for offensive language directed at staff.',
          reportReasons: [ReportReason.hateSpeech],
        ),
        AdminReview(
          id: 'rev_5',
          vendorName: 'Skyline Florals',
          reviewerName: 'Alex Rivera',
          reviewerType: ReviewerType.guest,
          rating: 3,
          date: DateTime.utc(2024, 5, 12),
          body: 'Flowers were fine, delivery was a bit late.',
          reportReasons: [ReportReason.onlyReview],
        ),
        AdminReview(
          id: 'rev_6',
          vendorName: 'Party Beats DJ',
          reviewerName: 'Taylor P.',
          reviewerType: ReviewerType.verifiedGuest,
          rating: 5,
          date: DateTime.utc(2024, 5, 12),
          body: 'Kept the whole reception dancing all night!',
        ),
      ];

  /// Deterministic per-vendor analytics — same convention as the vendor
  /// app's own mock stats: seeded from the vendor id so numbers are stable
  /// across rebuilds, with `v_001` matching the spec's worked example
  /// exactly.
  static VendorAnalytics analyticsFor(String vendorId, {String? topServiceHint}) {
    if (vendorId == 'v_001') {
      return VendorAnalytics(
        vendorId: 'v_001',
        totalViews: 4820,
        whatsappTaps: 312,
        timesSaved: 198,
        avgRating: 4.8,
        profileCompletionPct: 72,
        topServiceName: 'Main Ballroom',
        weeklyEngagement: [
          WeeklyEngagementPoint(DateTime.utc(2024, 5, 6), 120),
          WeeklyEngagementPoint(DateTime.utc(2024, 5, 7), 145),
          WeeklyEngagementPoint(DateTime.utc(2024, 5, 8), 98),
          WeeklyEngagementPoint(DateTime.utc(2024, 5, 9), 210),
          WeeklyEngagementPoint(DateTime.utc(2024, 5, 10), 175),
          WeeklyEngagementPoint(DateTime.utc(2024, 5, 11), 260),
          WeeklyEngagementPoint(DateTime.utc(2024, 5, 12), 230),
        ],
      );
    }

    final random = Random(vendorId.hashCode);
    final now = DateTime.now();
    return VendorAnalytics(
      vendorId: vendorId,
      totalViews: 400 + random.nextInt(4000),
      whatsappTaps: 20 + random.nextInt(300),
      timesSaved: 10 + random.nextInt(200),
      avgRating: double.parse((3.5 + random.nextDouble() * 1.5).toStringAsFixed(1)),
      profileCompletionPct: 40 + random.nextInt(60),
      topServiceName: topServiceHint ?? 'Signature Package',
      weeklyEngagement: [
        for (var i = 6; i >= 0; i--) WeeklyEngagementPoint(now.subtract(Duration(days: i)), 20 + random.nextInt(220)),
      ],
    );
  }
}
