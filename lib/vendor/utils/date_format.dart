const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Formats a [DateTime] as "March 20, 2026" without pulling in `intl`.
String formatLongDate(DateTime date) => '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

/// Formats a past [DateTime] as a short relative label ("2h ago", "3d ago").
String relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
