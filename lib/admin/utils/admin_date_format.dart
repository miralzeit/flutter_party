/// Formats a past [DateTime] as a short relative label ("2h ago", "3d ago")
/// — used as the "submission recency indicator" on Pending Vendor cards.
String relativeAdminTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return '${(diff.inDays / 30).floor()}mo ago';
}
