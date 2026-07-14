import 'package:flutter/material.dart';
import '../services/quality_score_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// The single highest-value "customers are searching for X but can't find
/// you" spotlight card — makes the AI feel useful by naming an actual
/// blocked search rather than a generic completion nag.
class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.insight, required this.onCompleteNow});

  final AiInsight insight;
  final VoidCallback onCompleteNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: AppColors.onPrimary, size: 20),
              const SizedBox(width: 8),
              Text('AI Insights', style: AppTextStyles.labelMd(color: AppColors.onPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Customers searching for', style: AppTextStyles.bodyMd(color: AppColors.onPrimary)),
          const SizedBox(height: 4),
          Text('"${insight.searchPhrase}"', style: AppTextStyles.headlineMd(color: AppColors.onPrimary)),
          const SizedBox(height: 8),
          Text(
            "can't find your business because your ${insight.missingLabel.toLowerCase()} isn't filled in.",
            style: AppTextStyles.bodyMd(color: AppColors.onPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${insight.searchCount} searches like this in the past week.',
            style: AppTextStyles.labelSm(color: AppColors.onPrimary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCompleteNow,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.onPrimary, foregroundColor: AppColors.primary),
            child: const Text('Complete Now'),
          ),
        ],
      ),
    );
  }
}
