import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../providers/business_providers.dart';
import '../screens/shell/business_flow.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Bottom sheet listing all of the vendor's businesses with a checkmark on
/// the active one, plus a trailing "Add business" row into onboarding.
/// Opened from the Dashboard's business switcher.
class BusinessSwitcherSheet extends ConsumerWidget {
  const BusinessSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (_) => const BusinessSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);
    final activeId = ref.watch(activeBusinessIdProvider);
    final active = activeBusinessOf(businesses, activeId);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [Text('Your Businesses', style: AppTextStyles.headlineMd())],
            ),
          ),
          for (final business in businesses)
            ListTile(
              leading: Icon(businessCategoryIcon(business.category), color: AppColors.primary),
              title: Text(business.name, style: AppTextStyles.labelMd()),
              subtitle: Text(business.category, style: AppTextStyles.bodyMd()),
              trailing: business.id == active?.id ? const Icon(Icons.check_circle, color: AppColors.tertiary) : null,
              onTap: () {
                ref.read(activeBusinessIdProvider.notifier).state = business.id;
                Navigator.of(context).pop();
              },
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            title: Text('Add Business', style: AppTextStyles.labelMd(color: AppColors.primary)),
            onTap: () {
              Navigator.of(context).pop();
              startAddBusinessFlow(context, ref);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
