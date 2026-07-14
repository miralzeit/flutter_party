import 'package:flutter/material.dart';
import '../services/quality_score_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// "Smart Suggestions" — the top few things a vendor could do next, each
/// with a mocked expected impact so they read as motivating rather than a
/// plain checklist.
class SuggestionsSection extends StatelessWidget {
  const SuggestionsSection({super.key, required this.suggestions, required this.onTap});

  final List<Suggestion> suggestions;
  final ValueChanged<Suggestion> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final suggestion in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onTap(suggestion),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.tertiary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(suggestion.title, style: AppTextStyles.labelMd()),
                          if (suggestion.pointsLabel != null) ...[
                            const SizedBox(height: 2),
                            Text(suggestion.pointsLabel!, style: AppTextStyles.labelSm(color: AppColors.tertiary)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Expected', style: AppTextStyles.labelSm()),
                        Text(suggestion.expectedImpact, style: AppTextStyles.labelMd(color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
