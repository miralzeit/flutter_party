import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Read-only, customer-facing rendering of a single [Package]. Standalone so
/// it can be reused both as a vendor-side preview and inside a future
/// customer browsing flow.
class PackageCardCustomerView extends StatelessWidget {
  const PackageCardCustomerView({super.key, required this.package, this.onCta, this.ctaLabel = 'Contact'});

  final Package package;
  final VoidCallback? onCta;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    final savings = package.savings;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 180,
                color: AppColors.primaryContainer.withValues(alpha: 0.12),
                child: const Icon(Icons.card_giftcard_outlined, color: AppColors.primary, size: 48),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text('BUNDLE & SAVE', style: AppTextStyles.labelSm(color: AppColors.onPrimary)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package.name, style: AppTextStyles.headlineMd()),
                const SizedBox(height: 6),
                if (package.price == null)
                  Text('Price on request', style: AppTextStyles.labelMd(color: AppColors.primary))
                else if (savings != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${package.originalPrice.toStringAsFixed(0)} ILS',
                        style: AppTextStyles.bodyMd(color: AppColors.outline).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(width: 8),
                      Text('${package.price!.toStringAsFixed(0)} ILS', style: AppTextStyles.headlineMd(color: AppColors.primary)),
                    ],
                  ),
                ] else
                  Text('${package.price!.toStringAsFixed(0)} ILS', style: AppTextStyles.labelMd(color: AppColors.primary)),
                if (package.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(package.description, style: AppTextStyles.bodyMd()),
                ],
                if (package.includedServices.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Includes', style: AppTextStyles.labelMd()),
                  const SizedBox(height: 8),
                  for (final service in package.includedServices)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.tertiary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(service.name, style: AppTextStyles.bodyMd(color: AppColors.onSurface))),
                        ],
                      ),
                    ),
                ],
                if (savings != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.dflt),
                      border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.savings_outlined, size: 16, color: AppColors.tertiary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'You Save ${savings.toStringAsFixed(0)} ILS',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelMd(color: AppColors.tertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onCta,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                    child: Text(ctaLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
