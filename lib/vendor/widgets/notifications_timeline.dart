import 'package:flutter/material.dart';
import '../services/mock_business_stats.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_format.dart';

class _NotificationRow {
  _NotificationRow(this.icon, this.text, this.timestamp);

  final IconData icon;
  final String text;
  final DateTime timestamp;
}

/// "Today / Yesterday" timeline of recent review, favorite, trending-package
/// and milestone events — built entirely from already-generated
/// [BusinessStats], no separate backing data needed.
class NotificationsTimeline extends StatelessWidget {
  const NotificationsTimeline({super.key, required this.stats});

  final BusinessStats stats;

  List<_NotificationRow> _buildRows() {
    final rows = <_NotificationRow>[];

    if (stats.reviews.isNotEmpty) {
      final latest = stats.reviews.first;
      rows.add(_NotificationRow(Icons.star, '${latest.customerName} left a ${latest.rating}-star review', latest.date));
    }
    if (stats.favorites.today > 0) {
      rows.add(_NotificationRow(
        Icons.favorite,
        '${stats.favorites.today} ${stats.favorites.today == 1 ? 'person' : 'people'} added you to Favorites',
        DateTime.now().subtract(const Duration(hours: 2)),
      ));
    }
    if (stats.popular.isNotEmpty) {
      rows.add(_NotificationRow(
        Icons.inventory_2_outlined,
        '${stats.popular.first.name} is trending',
        DateTime.now().subtract(const Duration(days: 1)),
      ));
    }
    rows.add(_NotificationRow(
      Icons.visibility,
      'Your profile reached ${(stats.totalProfileViews ~/ 100) * 100} views',
      DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ));

    rows.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return rows;
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return formatLongDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    final groups = <String, List<_NotificationRow>>{};
    for (final row in rows) {
      groups.putIfAbsent(_dayLabel(row.timestamp), () => []).add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(entry.key, style: AppTextStyles.labelSm(color: AppColors.outline)),
          ),
          for (final row in entry.value) _row(row),
        ],
      ],
    );
  }

  Widget _row(_NotificationRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(row.icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.text, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Text(relativeTime(row.timestamp), style: AppTextStyles.labelSm()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
