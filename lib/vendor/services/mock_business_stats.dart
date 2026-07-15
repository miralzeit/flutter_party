import 'dart:math';
import '../models/business.dart';

/// One day's worth of a trend line (e.g. profile views).
class TrendPoint {
  TrendPoint(this.date, this.value);

  final DateTime date;
  final int value;
}

/// One month's total for a month-over-month comparison chart.
class MonthlyPoint {
  MonthlyPoint(this.month, this.value);

  /// Short month label, e.g. "Jan".
  final String month;
  final int value;
}

/// A single row in a "Popular services/packages" ranked list.
class PopularItem {
  PopularItem(this.name, this.views);

  final String name;
  final int views;
}

/// A single row in the Dashboard's "Competitor Comparison" — another
/// business in the same category, with its rating, review count, starting
/// price and what it offers (services + amenities), so a vendor can see not
/// just where they rank but what a competitor actually has that they don't.
class CompetitorStat {
  CompetitorStat({
    required this.name,
    required this.avgRating,
    required this.reviewsCount,
    required this.startingPrice,
    required this.topServices,
    required this.features,
  });

  final String name;
  final double avgRating;
  final int reviewsCount;
  final double startingPrice;
  final List<String> topServices;
  final List<String> features;
}

/// Today / this-week / this-month / all-time totals for a single engagement
/// metric (WhatsApp clicks, favorites, ...) — the four numbers Analytics
/// shows side by side as stat cards.
class EngagementCounter {
  EngagementCounter({required this.today, required this.thisWeek, required this.thisMonth, required this.total});

  final int today;
  final int thisWeek;
  final int thisMonth;
  final int total;
}

/// A single customer review left on a business.
class Review {
  Review({required this.customerName, required this.rating, required this.date, required this.text});

  final String customerName;
  final int rating;
  final DateTime date;
  final String text;

  String get initials {
    final parts = customerName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.length == 1 ? parts.first[0].toUpperCase() : (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

/// Everything the Dashboard and Analytics tabs display that would normally
/// come from a backend (bookings, profile views, reviews, ...). There's no
/// backend yet, so this generates believable numbers deterministically from
/// the business's id, stable across rebuilds within a session.
class BusinessStats {
  BusinessStats({
    required this.trend,
    required this.monthlyViews,
    required this.whatsappClicks,
    required this.calls,
    required this.favorites,
    required this.reviews,
    required this.popular,
  });

  final List<TrendPoint> trend;
  final List<MonthlyPoint> monthlyViews;
  final EngagementCounter whatsappClicks;
  final int calls;
  final EngagementCounter favorites;
  final List<Review> reviews;
  final List<PopularItem> popular;

  int get reviewsCount => reviews.length;

  double get avgRating {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (total, review) => total + review.rating);
    return double.parse((sum / reviews.length).toStringAsFixed(1));
  }

  int get totalProfileViews => trend.fold(0, (sum, point) => sum + point.value);

  /// Sums the trailing [days] of [trend] (trend is generated for 90 days).
  int viewsForRange(int days) => trend.skip(trend.length - days).fold(0, (sum, point) => sum + point.value);

  List<TrendPoint> trendForRange(int days) => trend.skip(trend.length - days).toList();
}

const _monthLabels = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const _reviewerNames = [
  'Sarah Johnson', 'Michael Chen', 'Priya Patel', 'James Wilson',
  'Layla Ahmed', 'Daniel Kim', 'Emma Garcia', 'Noah Cohen',
  'Olivia Brown', 'Yusuf Demir',
];

const _reviewTexts = [
  'The makeup artist arrived late.',
  'Absolutely loved the service, would book again!',
  'Great communication throughout the whole process.',
  'Quality was good but a bit pricier than expected.',
  'Exceeded our expectations for the wedding day.',
  'Professional, punctual, and friendly staff.',
  'Had a small issue with scheduling but it was resolved quickly.',
  'Everyone at the event was impressed with the setup.',
];

BusinessStats generateBusinessStats(Business business) {
  final random = Random(business.id.hashCode);
  const days = 90;
  final trend = [
    for (var i = days - 1; i >= 0; i--)
      TrendPoint(DateTime.now().subtract(Duration(days: i)), 5 + random.nextInt(40)),
  ];

  final items = [
    for (final service in business.services) service.name,
    for (final package in business.packages) package.name,
  ];
  final popular = [for (final name in items) PopularItem(name, random.nextInt(200))]
    ..sort((a, b) => b.views.compareTo(a.views));

  return BusinessStats(
    trend: trend,
    monthlyViews: _generateMonthlyViews(random),
    whatsappClicks: _generateEngagementCounter(random, totalMin: 60, totalMax: 420),
    calls: 5 + random.nextInt(40),
    favorites: _generateEngagementCounter(random, totalMin: 20, totalMax: 220),
    reviews: _generateReviews(random),
    popular: popular,
  );
}

/// Six months of profile-views totals ending this month, trending upward
/// with some noise — mirrors real month-over-month growth rather than
/// slicing the daily trend, since that only covers ~3 months.
List<MonthlyPoint> _generateMonthlyViews(Random random) {
  final now = DateTime.now();
  var value = 80 + random.nextInt(80);
  final points = <MonthlyPoint>[];
  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    points.add(MonthlyPoint(_monthLabels[month.month - 1], value));
    value += 20 + random.nextInt(120);
  }
  return points;
}

/// Builds a today <= thisWeek <= thisMonth <= total counter with a
/// believable distribution (most engagement is older than this month).
EngagementCounter _generateEngagementCounter(Random random, {required int totalMin, required int totalMax}) {
  final total = totalMin + random.nextInt(totalMax - totalMin);
  final thisMonth = (total * (0.15 + random.nextDouble() * 0.15)).round().clamp(0, total);
  final thisWeek = (thisMonth * (0.2 + random.nextDouble() * 0.2)).round().clamp(0, thisMonth);
  final today = (thisWeek * (0.1 + random.nextDouble() * 0.25)).round().clamp(0, thisWeek);
  return EngagementCounter(today: today, thisWeek: thisWeek, thisMonth: thisMonth, total: total);
}

List<Review> _generateReviews(Random random) {
  final count = 4 + random.nextInt(6);
  final reviews = [
    for (var i = 0; i < count; i++)
      Review(
        customerName: _reviewerNames[random.nextInt(_reviewerNames.length)],
        rating: 3 + random.nextInt(3),
        date: DateTime.now().subtract(Duration(days: random.nextInt(180))),
        text: _reviewTexts[random.nextInt(_reviewTexts.length)],
      ),
  ];
  reviews.sort((a, b) => b.date.compareTo(a.date));
  return reviews;
}

const _competitorNamePool = [
  'Grand Venue Co.',
  'Elite Occasions',
  'The Golden Hall',
  'Prime Celebrations',
  'Royal Events',
  'City Favorites',
];

/// What a competitor's headline services tend to look like, by category —
/// falls back to ['Other'] for any category not listed here.
const _competitorServicePool = {
  'Wedding Hall': ['Full Venue Rental', 'In-House Catering', 'Bridal Suite Access', 'Event Coordination'],
  'Salon': ['Bridal Makeup', 'Hair Styling', 'Mani-Pedi Package', 'Skin Treatment'],
  'Catering': ['Buffet Package', 'Plated Dinner Service', 'Dessert Table', 'Live Cooking Station'],
  'Photography': ['Full-Day Coverage', 'Drone Photography', 'Same-Day Editing', 'Photo Booth'],
  'Decoration': ['Full Venue Decor', 'Floral Arrangements', 'Lighting Design', 'Stage Backdrop'],
  'DJ & Music': ['Live Band', 'DJ & Sound System', 'MC Hosting', 'Lighting & Effects'],
  'Other': ['Custom Package', 'Consultation', 'Add-on Services'],
};

/// Amenities/features competitors might advertise — deliberately overlaps
/// with the keywords [computeQualityScore] checks for (parking, outdoor,
/// generator, accessible) so a vendor missing one of those checklist items
/// is likely to see a competitor calling it out.
const _competitorFeaturePool = [
  'Free Parking',
  'Outdoor Garden Area',
  'Backup Generator',
  'Wheelchair Accessible',
  'Free WiFi',
  'Valet Service',
  'Bridal Suite',
  'In-House Catering',
];

/// Nearby businesses in the same category, for the Dashboard's "Competitor
/// Comparison" card. There's no backend/marketplace data yet, so this
/// generates believable ratings, pricing, services and amenities
/// deterministically from the business's id, stable across rebuilds within a
/// session — same convention as [generateBusinessStats].
List<CompetitorStat> generateCompetitors(Business business) {
  final random = Random(business.id.hashCode ^ 0x5bd1e995);
  final names = [..._competitorNamePool]..shuffle(random);
  const count = 3;

  final servicePool = _competitorServicePool[business.category] ?? _competitorServicePool['Other']!;
  final basePrice = business.basePrice ?? (800 + random.nextInt(3200)).toDouble();

  return [
    for (final name in names.take(count))
      CompetitorStat(
        name: name,
        avgRating: double.parse((3.5 + random.nextDouble() * 1.5).toStringAsFixed(1)),
        reviewsCount: 15 + random.nextInt(150),
        startingPrice: (basePrice * (0.75 + random.nextDouble() * 0.6)).roundToDouble(),
        topServices: ([...servicePool]..shuffle(random)).take(2 + random.nextInt(2)).toList(),
        features: ([..._competitorFeaturePool]..shuffle(random)).take(2 + random.nextInt(3)).toList(),
      ),
  ];
}
