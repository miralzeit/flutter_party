import 'package:flutter/material.dart';
import '../services/quality_score_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Headline "Business Quality Score" card: score/100, star tier, a "more
/// complete than N% of vendors" line, and a progress bar.
class QualityScoreHeaderCard extends StatelessWidget {
  const QualityScoreHeaderCard({super.key, required this.result});

  final QualityScoreResult result;

  @override
  Widget build(BuildContext context) {
    final percentage = result.percentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: .22), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.onPrimary, size: 18),
              const SizedBox(width: 8),
              Text('Business Quality Score', style: AppTextStyles.labelMd(color: AppColors.onPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$percentage', style: AppTextStyles.displayLg(color: AppColors.onPrimary)),
              Text(' / 100', style: AppTextStyles.headlineMd(color: AppColors.onPrimary.withValues(alpha: .7))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Icon(i < result.starCount ? Icons.star : Icons.star_border, color: const Color(0xFFFFD166), size: 16),
              const SizedBox(width: 8),
              Text(result.tierLabel, style: AppTextStyles.labelMd(color: AppColors.onPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'More complete than ${result.percentileBeatsVendors}% of vendors.',
            style: AppTextStyles.bodyMd(color: AppColors.onPrimary.withValues(alpha: .85)),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: .2),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD166)),
            ),
          ),
        ],
      ),
    );
  }
}

/// The profile-completeness checklist. Only missing items are shown by
/// default — each explains why it matters and how many points completing it
/// is worth — with a collapsed "N completed" row that expands to reveal the
/// rest, so the list stays short and focused on what to actually do next.
class QualityChecklist extends StatelessWidget {
  const QualityChecklist({super.key, required this.result, required this.onComplete});

  final QualityScoreResult result;
  final ValueChanged<ChecklistItem> onComplete;

  @override
  Widget build(BuildContext context) {
    final missing = result.missing;
    final done = result.done;

    if (missing.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.tertiaryContainer.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.tertiary, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('Your profile is fully complete!', style: AppTextStyles.labelMd(color: AppColors.tertiary))),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final item in missing) _missingRow(item),
        if (done.isNotEmpty) _completedSummary(done),
      ],
    );
  }

  Widget _missingRow(ChecklistItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(left: BorderSide(color: Colors.amber.shade600, width: 3)),
      ),
      child: InkWell(
        onTap: () => onComplete(item),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.label, style: AppTextStyles.labelMd())),
                        Text('+${item.points}', style: AppTextStyles.labelSm(color: AppColors.tertiary)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(item.whyItMatters, style: AppTextStyles.labelSm()),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completedSummary(List<ChecklistItem> done) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        iconColor: AppColors.tertiary,
        collapsedIconColor: AppColors.tertiary,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.tertiary, size: 16),
            const SizedBox(width: 8),
            Text('${done.length} completed', style: AppTextStyles.labelMd(color: AppColors.tertiary)),
          ],
        ),
        children: [
          for (final item in done)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: AppColors.tertiary),
                  const SizedBox(width: 8),
                  Text(item.label, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
