import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/mock_business_stats.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// A compact "profile views" trend card for the Dashboard: a sparkline over
/// the trailing [rangeDays] plus the percentage change vs. the equivalent
/// prior period, so a vendor can tell at a glance whether visibility is
/// climbing or falling without opening the full Analytics tab.
class ViewsTrendCard extends StatelessWidget {
  const ViewsTrendCard({super.key, required this.stats, this.rangeDays = 14});

  final BusinessStats stats;
  final int rangeDays;

  @override
  Widget build(BuildContext context) {
    final trend = stats.trendForRange(rangeDays);
    final total = trend.fold(0, (sum, point) => sum + point.value);
    final hasPriorPeriod = stats.trend.length >= rangeDays * 2;
    final previousTotal = hasPriorPeriod
        ? stats.trend.skip(stats.trend.length - rangeDays * 2).take(rangeDays).fold(0, (sum, point) => sum + point.value)
        : null;
    final change = previousTotal == null || previousTotal == 0 ? null : (total - previousTotal) / previousTotal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: .65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Views, last $rangeDays days', style: AppTextStyles.labelSm()),
                    const SizedBox(height: 2),
                    Text('$total', style: AppTextStyles.statValue(color: AppColors.primary)),
                  ],
                ),
              ),
              if (change != null) _ChangeChip(change: change),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: 44, child: _Sparkline(trend: trend)),
        ],
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.change});

  final double change;

  @override
  Widget build(BuildContext context) {
    final positive = change >= 0;
    final color = positive ? AppColors.tertiary : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(positive ? Icons.trending_up : Icons.trending_down, size: 14, color: color),
          const SizedBox(width: 4),
          Text('${positive ? '+' : ''}${(change * 100).toStringAsFixed(0)}%', style: AppTextStyles.labelSm(color: color)),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.trend});

  final List<TrendPoint> trend;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
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
    );
  }
}
