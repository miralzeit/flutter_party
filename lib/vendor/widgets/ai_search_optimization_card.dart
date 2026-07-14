import 'package:flutter/material.dart';
import '../services/quality_score_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// "AI Search Optimization" — a compact summary of how many AI-matching
/// profile fields (capacity, parking, hours, ...) are filled in and a mocked
/// "you currently appear in N searches" figure. Deliberately just a summary:
/// the checklist above already lists and links each missing field, so this
/// doesn't repeat that list.
class AiSearchOptimizationCard extends StatelessWidget {
  const AiSearchOptimizationCard({super.key, required this.optimization});

  final AiSearchOptimization optimization;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Text('${optimization.percentage}%', style: AppTextStyles.labelMd(color: AppColors.primary)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.travel_explore, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text('AI Search Optimization', style: AppTextStyles.labelMd()),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Appears in ${optimization.searchAppearances} customer '
                  'search${optimization.searchAppearances == 1 ? '' : 'es'}.',
                  style: AppTextStyles.bodyMd(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
