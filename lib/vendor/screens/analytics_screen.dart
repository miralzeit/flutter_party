import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../providers/business_providers.dart';
import '../services/mock_business_stats.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../widgets/metric_card.dart';
import '../widgets/views_trend_card.dart';
import 'report_review_screen.dart';

/// Tab 3 — "Analytics". A professional vendor dashboard: profile views
/// (total + recent trend + month-over-month chart), call/WhatsApp click and
/// favorite counters, a popular services/packages ranking, and the full
/// reviews list with a report-review action. All numbers are mocked (see
/// mock_business_stats.dart) since there's no backend for bookings/views/
/// reviews yet.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final _reportedReviews = <int>{};

  Future<void> _reportReview(int index, Review review) async {
    final reported = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReportReviewScreen(review: review)),
    );
    if (reported == true) setState(() => _reportedReviews.add(index));
  }

  @override
  Widget build(BuildContext context) {
    final businesses = ref.watch(businessesProvider);
    final activeId = ref.watch(activeBusinessIdProvider);
    final business = activeBusinessOf(businesses, activeId);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: business == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Add a business first to see its analytics.', textAlign: TextAlign.center, style: AppTextStyles.bodyMd()),
                    ),
                  )
                : _content(business),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: AppTextStyles.labelMd());

  Widget _content(Business business) {
    final stats = generateBusinessStats(business);
    final popular = stats.popular.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _sectionTitle('Profile Views'),
        const SizedBox(height: 4),
        Text('${stats.totalProfileViews}', style: AppTextStyles.headlineLgMobile()),
        Text('Total profile views', style: AppTextStyles.bodyMd()),
        const SizedBox(height: 16),
        ViewsTrendCard(stats: stats),
        const SizedBox(height: 16),
        _MonthlyViewsChart(monthly: stats.monthlyViews),
        const SizedBox(height: 28),
        _sectionTitle('Calls'),
        const SizedBox(height: 12),
        MetricCard(label: 'Total calls', value: '${stats.calls}', icon: Icons.call_outlined),
        const SizedBox(height: 28),
        _sectionTitle('WhatsApp Clicks'),
        const SizedBox(height: 12),
        _EngagementGrid(counter: stats.whatsappClicks),
        const SizedBox(height: 28),
        _sectionTitle('Favorite Count'),
        const SizedBox(height: 12),
        _EngagementGrid(counter: stats.favorites),
        const SizedBox(height: 28),
        _sectionTitle('Popular Services & Packages'),
        const SizedBox(height: 12),
        if (popular.isEmpty)
          Text('Add services or packages to see what customers view most.', style: AppTextStyles.bodyMd())
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                for (var i = 0; i < popular.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Text('${i + 1}', style: AppTextStyles.labelMd(color: AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(popular[i].name, style: AppTextStyles.bodyMd(color: AppColors.onSurface))),
                        Text('${popular[i].views} views', style: AppTextStyles.labelSm()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        _sectionTitle('Reviews'),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.tertiary, size: 18),
            const SizedBox(width: 6),
            Text(stats.reviewsCount == 0 ? '—' : stats.avgRating.toStringAsFixed(1), style: AppTextStyles.labelMd()),
            const SizedBox(width: 6),
            Text('${stats.reviewsCount} review${stats.reviewsCount == 1 ? '' : 's'}', style: AppTextStyles.bodyMd()),
          ],
        ),
        const SizedBox(height: 12),
        if (stats.reviews.isEmpty)
          Text('No reviews yet.', style: AppTextStyles.bodyMd())
        else
          for (var i = 0; i < stats.reviews.length; i++) ...[
            _ReviewCard(
              review: stats.reviews[i],
              reported: _reportedReviews.contains(i),
              onReport: () => _reportReview(i, stats.reviews[i]),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MonthlyViewsChart extends StatelessWidget {
  const _MonthlyViewsChart({required this.monthly});

  final List<MonthlyPoint> monthly;

  @override
  Widget build(BuildContext context) {
    final maxValue = monthly.fold(0, (max, point) => point.value > max ? point.value : max);
    final rawInterval = (maxValue / 4).ceilToDouble();
    final interval = rawInterval < 1 ? 1.0 : rawInterval;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.outlineVariant, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= monthly.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(monthly[index].month, style: AppTextStyles.labelSm()),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: interval,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: AppTextStyles.labelSm()),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => [
                for (final spot in spots) LineTooltipItem('${spot.y.toInt()}', AppTextStyles.labelSm(color: AppColors.onPrimary)),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < monthly.length; i++) FlSpot(i.toDouble(), monthly[i].value.toDouble())],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppColors.primaryContainer.withValues(alpha: 0.15)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngagementGrid extends StatelessWidget {
  const _EngagementGrid({required this.counter});

  final EngagementCounter counter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: MetricCard(label: 'Today', value: '${counter.today}', icon: Icons.today_outlined)),
            const SizedBox(width: 12),
            Expanded(child: MetricCard(label: 'This Week', value: '${counter.thisWeek}', icon: Icons.calendar_view_week_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: MetricCard(label: 'This Month', value: '${counter.thisMonth}', icon: Icons.calendar_month_outlined)),
            const SizedBox(width: 12),
            Expanded(child: MetricCard(label: 'Total', value: '${counter.total}', icon: Icons.functions)),
          ],
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.reported, required this.onReport});

  final Review review;
  final bool reported;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                child: Text(review.initials, style: AppTextStyles.labelMd(color: AppColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customerName, style: AppTextStyles.labelMd()),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(i < review.rating ? Icons.star : Icons.star_border, color: AppColors.tertiary, size: 14),
                        const SizedBox(width: 6),
                        Text(formatLongDate(review.date), style: AppTextStyles.labelSm()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.text, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: reported ? null : onReport,
              icon: Icon(reported ? Icons.flag : Icons.flag_outlined, size: 16),
              label: Text(reported ? 'Reported' : 'Report Review'),
              style: TextButton.styleFrom(foregroundColor: reported ? AppColors.outline : AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
