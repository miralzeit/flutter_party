import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Read-only, customer-facing rendering of a single [Service]. Standalone so
/// it can be reused both as a vendor-side preview and inside a future
/// customer browsing flow.
class ServiceCardCustomerView extends StatelessWidget {
  const ServiceCardCustomerView({super.key, required this.service, this.onCta, this.ctaLabel = 'Contact'});

  final Service service;
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
            child: const Icon(Icons.room_service_outlined, color: AppColors.primary, size: 48),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.dflt),
                    ),
                    child: Text(service.category, style: AppTextStyles.labelSm(color: AppColors.primary)),
                  ),
                const SizedBox(height: 8),
                Text(service.name, style: AppTextStyles.headlineMd()),
                const SizedBox(height: 4),
                Text(
                  service.price != null ? '${service.price!.toStringAsFixed(0)} ILS' : 'Price on request',
                  style: AppTextStyles.labelMd(color: AppColors.primary),
                ),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(service.description, style: AppTextStyles.bodyMd()),
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
