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
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 180,
            color: AppColors.primaryContainer.withValues(alpha: 0.12),
            child: const Icon(Icons.card_giftcard_outlined, color: AppColors.primary, size: 48),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package.name, style: AppTextStyles.headlineMd()),
                const SizedBox(height: 4),
                Text(
                  package.price != null ? '${package.price!.toStringAsFixed(0)} ILS' : 'Price on request',
                  style: AppTextStyles.labelMd(color: AppColors.primary),
                ),
                if (package.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(package.description, style: AppTextStyles.bodyMd()),
                ],
                if (package.includedServices.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Included', style: AppTextStyles.labelMd()),
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
