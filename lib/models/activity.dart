import 'package:flutter/material.dart';

/// One row in a business's Dashboard "Recent Activity" feed.
class ActivityEvent {
  ActivityEvent({required this.icon, required this.description, required this.timestamp});

  final IconData icon;
  final String description;
  final DateTime timestamp;
}

/// Formats a past [DateTime] as a short relative label ("2h ago", "3d ago").
String relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
