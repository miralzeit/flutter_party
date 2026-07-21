import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_providers.dart';
import '../../theme/admin_colors.dart';
import '../../theme/admin_text_styles.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/stat_card.dart';

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Screen — Vendor Analytics (admin read-only view). The same performance
/// snapshot a vendor sees on their own Analytics tab, opened here purely so
/// support staff can diagnose "why isn't my listing getting views" tickets
/// without leaving the admin panel — every metric is computed, nothing here
/// is editable.
class VendorAnalyticsScreen extends ConsumerWidget {
  const VendorAnalyticsScreen({super.key, required this.vendorId, required this.vendorName});

  final String vendorId;
  final String vendorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(vendorAnalyticsProvider(vendorId));
    final isWide = MediaQuery.of(context).size.width >= 720;
    final maxCount = analytics.weeklyEngagement.fold(0, (max, p) => p.count > max ? p.count : max);

    return Scaffold(
      appBar: AppBar(title: Text('Analytics · $vendorName')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AdminColors.primaryContainer.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AdminRadius.sm)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility_outlined, size: 16, color: AdminColors.primary),
                  const SizedBox(width: 8),
                  Text('Read-only admin view — support/reference only', style: AdminTextStyles.labelSm(color: AdminColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Performance Overview', style: AdminTextStyles.headlineMd()),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AdminSpacing.gutter,
              mainAxisSpacing: AdminSpacing.gutter,
              childAspectRatio: isWide ? 1.3 : 0.95,
              children: [
                AdminStatCard(label: 'Total Views', value: '${analytics.totalViews}', subtitle: 'All time', icon: Icons.visibility_outlined),
                AdminStatCard(label: 'WhatsApp Taps', value: '${analytics.whatsappTaps}', subtitle: 'All time', icon: Icons.chat_outlined),
                AdminStatCard(label: 'Times Saved', value: '${analytics.timesSaved}', subtitle: 'Bookmarked by guests', icon: Icons.bookmark_outline),
                AdminStatCard(label: 'Avg Rating', value: analytics.avgRating.toStringAsFixed(1), subtitle: 'Customer rating', icon: Icons.star_outline),
              ],
            ),
            const SizedBox(height: 28),
            Text('Profile Completion', style: AdminTextStyles.headlineMd()),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AdminColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(AdminRadius.md), border: Border.all(color: AdminColors.outlineVariant)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${analytics.profileCompletionPct}%', style: AdminTextStyles.statValue(color: AdminColors.primary)),
                      const Spacer(),
                      if (analytics.profileCompletionPct < 100)
                        Text(
                          analytics.profileCompletionPct < 60 ? 'Add Photos Now' : 'Boost Your Visibility',
                          style: AdminTextStyles.labelMd(color: AdminColors.warning),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AdminRadius.full),
                    child: LinearProgressIndicator(
                      value: analytics.profileCompletionPct / 100,
                      minHeight: 8,
                      backgroundColor: AdminColors.surfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation(AdminColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Top Performing Service', style: AdminTextStyles.headlineMd()),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AdminColors.tertiaryContainer.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AdminRadius.md)),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: AdminColors.tertiary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(analytics.topServiceName, style: AdminTextStyles.bodyLg())),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AdminColors.tertiary, borderRadius: BorderRadius.circular(AdminRadius.full)),
                    child: Text('Hot Service', style: AdminTextStyles.labelSm(color: AdminColors.tertiaryContainer)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Weekly Engagement', style: AdminTextStyles.headlineMd()),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: (maxCount * 1.2).ceilToDouble(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= analytics.weeklyEngagement.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_weekdayLabels[analytics.weeklyEngagement[index].date.weekday - 1], style: AdminTextStyles.labelSm()),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < analytics.weeklyEngagement.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: analytics.weeklyEngagement[i].count.toDouble(),
                            color: AdminColors.primary,
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
