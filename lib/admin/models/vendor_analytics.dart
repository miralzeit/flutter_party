/// One day's worth of a vendor's weekly engagement trend.
class WeeklyEngagementPoint {
  WeeklyEngagementPoint(this.date, this.count);

  final DateTime date;
  final int count;
}

/// The read-only performance snapshot shown on a vendor's own Analytics tab
/// — and, for support purposes, on the admin-side Vendor Analytics view.
class VendorAnalytics {
  VendorAnalytics({
    required this.vendorId,
    required this.totalViews,
    required this.whatsappTaps,
    required this.timesSaved,
    required this.avgRating,
    required this.profileCompletionPct,
    required this.topServiceName,
    required this.weeklyEngagement,
  });

  final String vendorId;
  final int totalViews;
  final int whatsappTaps;
  final int timesSaved;
  final double avgRating;
  final int profileCompletionPct;
  final String topServiceName;
  final List<WeeklyEngagementPoint> weeklyEngagement;
}
