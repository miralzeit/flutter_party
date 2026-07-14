import 'dart:math';
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/business.dart';

/// One day's worth of a trend line (e.g. profile views).
class TrendPoint {
  TrendPoint(this.date, this.value);

  final DateTime date;
  final int value;
}

/// A single row in a "Popular services/packages" ranked list.
class PopularItem {
  PopularItem(this.name, this.views);

  final String name;
  final int views;
}

/// Everything the Dashboard and Analytics tabs display that would normally
/// come from a backend (bookings, profile views, reviews, ...). There's no
/// backend yet, so this generates believable numbers deterministically from
/// the business's id, stable across rebuilds within a session.
class BusinessStats {
  BusinessStats({
    required this.trend,
    required this.whatsappClicks,
    required this.calls,
    required this.reviewsCount,
    required this.avgRating,
    required this.activity,
    required this.popular,
  });

  final List<TrendPoint> trend;
  final int whatsappClicks;
  final int calls;
  final int reviewsCount;
  final double avgRating;
  final List<ActivityEvent> activity;
  final List<PopularItem> popular;

  int get totalProfileViews => trend.fold(0, (sum, point) => sum + point.value);

  /// Sums the trailing [days] of [trend] (trend is generated for 90 days).
  int viewsForRange(int days) => trend.skip(trend.length - days).fold(0, (sum, point) => sum + point.value);

  List<TrendPoint> trendForRange(int days) => trend.skip(trend.length - days).toList();
}

const _activityTemplates = [
  (Icons.trending_up, 'Profile views spiked'),
  (Icons.star_outline, 'You received a new review'),
  (Icons.photo_outlined, 'New photos added'),
  (Icons.chat_bubble_outline, 'New booking inquiry received'),
];

BusinessStats generateBusinessStats(Business business) {
  final random = Random(business.id.hashCode);
  const days = 90;
  final trend = [
    for (var i = days - 1; i >= 0; i--)
      TrendPoint(DateTime.now().subtract(Duration(days: i)), 5 + random.nextInt(40)),
  ];

  final reviewsCount = random.nextInt(30);
  final rating = reviewsCount == 0 ? 0.0 : 3.5 + random.nextDouble() * 1.5;

  final items = [
    for (final service in business.services) service.name,
    for (final package in business.packages) package.name,
  ];
  final popular = [for (final name in items) PopularItem(name, random.nextInt(200))]
    ..sort((a, b) => b.views.compareTo(a.views));

  final activityCount = 3 + random.nextInt(6);
  final activity = [
    for (var i = 0; i < activityCount; i++)
      _pickActivityEvent(random),
  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return BusinessStats(
    trend: trend,
    whatsappClicks: 10 + random.nextInt(80),
    calls: 5 + random.nextInt(40),
    reviewsCount: reviewsCount,
    avgRating: double.parse(rating.toStringAsFixed(1)),
    activity: activity,
    popular: popular,
  );
}

ActivityEvent _pickActivityEvent(Random random) {
  final template = _activityTemplates[random.nextInt(_activityTemplates.length)];
  return ActivityEvent(
    icon: template.$1,
    description: template.$2,
    timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(72))),
  );
}
