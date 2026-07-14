import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../providers/business_providers.dart';
import '../services/mock_business_stats.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/metric_card.dart';

const int _defaultRangeDays = 30;
const List<int> _rangeOptions = [7, 30, 90];

/// Tab 3 — "Analytics". Time range selector -> metric grid -> chart ->
/// ranked list, the layout pattern the rest of Analytics follows. All
/// numbers are mocked (see mock_business_stats.dart) since there's no
/// backend for bookings/views/reviews yet.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _rangeDays = _defaultRangeDays;

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
            constraints: const BoxConstraints(maxWidth: 420),
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

  Widget _content(Business business) {
    final stats = generateBusinessStats(business);
    final trend = stats.trendForRange(_rangeDays);
    final rangeViews = stats.viewsForRange(_rangeDays);
    final rangeFraction = _rangeDays / 90;
    final whatsappClicks = (stats.whatsappClicks * rangeFraction).round();
    final calls = (stats.calls * rangeFraction).round();
    final popular = stats.popular.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        SegmentedButton<int>(
          segments: [for (final days in _rangeOptions) ButtonSegment(value: days, label: Text('$days days'))],
          selected: {_rangeDays},
          onSelectionChanged: (selection) => setState(() => _rangeDays = selection.first),
        ),
        const SizedBox(height: 24),
        Text('Profile Views', style: AppTextStyles.labelMd()),
        const SizedBox(height: 4),
        Text('$rangeViews', style: AppTextStyles.headlineLgMobile()),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (var i = 0; i < trend.length; i++) FlSpot(i.toDouble(), trend[i].value.toDouble())],
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: AppColors.primaryContainer.withValues(alpha: 0.15)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Customer Interest', style: AppTextStyles.labelMd()),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: MetricCard(label: 'WhatsApp Clicks', value: '$whatsappClicks', icon: Icons.chat_bubble_outline)),
            const SizedBox(width: 12),
            Expanded(child: MetricCard(label: 'Phone Calls', value: '$calls', icon: Icons.call_outlined)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Popular Services & Packages', style: AppTextStyles.labelMd()),
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
        const SizedBox(height: 24),
        Text('Reviews', style: AppTextStyles.labelMd()),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                stats.reviewsCount == 0 ? '—' : stats.avgRating.toStringAsFixed(1),
                style: AppTextStyles.statValue(),
              ),
              const SizedBox(width: 8),
              Text('${stats.reviewsCount} review${stats.reviewsCount == 1 ? '' : 's'}', style: AppTextStyles.bodyMd()),
              const Spacer(),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reviews list coming soon.')),
                ),
                child: const Text('View all reviews'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
