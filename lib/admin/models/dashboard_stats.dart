/// Platform-health counts for the Overview screen — computed on the fly
/// from the underlying vendor/application/review lists (never stored),
/// except [totalUsers] which has no backing entity in this mock dataset.
class DashboardStats {
  DashboardStats({
    required this.totalUsers,
    required this.activeVendors,
    required this.pendingApprovals,
    required this.reportedReviews,
  });

  final int totalUsers;
  final int activeVendors;
  final int pendingApprovals;
  final int reportedReviews;
}
