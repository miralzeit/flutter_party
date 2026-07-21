import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/business.dart';
import '../../models/vendor.dart';
import '../../providers/business_providers.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/package_card_customer_view.dart';
import '../../widgets/service_card_customer_view.dart';
import '../../widgets/wizard_bottom_bar.dart';
import '../shell/main_shell_screen.dart';

/// Step 5 — "Review & Finish". Read-only preview of everything the draft
/// holds, each section jumping back to its step to edit without losing
/// progress elsewhere. "Finish setup" is the only place any of this is
/// written to the real vendor/businesses providers.
class OnboardingReviewStep extends ConsumerWidget {
  const OnboardingReviewStep({super.key});

  void _finish(BuildContext context, WidgetRef ref) {
    final state = ref.read(onboardingProvider);
    if (!state.isAdditionalBusiness) {
      ref.read(vendorProvider.notifier).state = state.vendor;
    }
    ref.read(businessesProvider.notifier).add(state.business);
    ref.read(activeBusinessIdProvider.notifier).state = state.business.id;

    if (state.isAdditionalBusiness) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final business = state.business;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (!state.isAdditionalBusiness) ...[
                _sectionHeader('Profile', () => notifier.goToStep(obProfileStep)),
                const SizedBox(height: 8),
                _profileCard(state.vendor),
                const SizedBox(height: 24),
              ],
              _sectionHeader('Business', () => notifier.goToStep(obBusinessStep)),
              const SizedBox(height: 8),
              _businessCard(business),
              const SizedBox(height: 24),
              _sectionHeader('${business.services.length} Service${business.services.length == 1 ? '' : 's'}', () => notifier.goToStep(obServicesStep)),
              const SizedBox(height: 8),
              if (business.services.isEmpty)
                Text('No services added.', style: AppTextStyles.bodyMd())
              else
                for (final service in business.services) ...[
                  ServiceCardCustomerView(service: service),
                  const SizedBox(height: 12),
                ],
              const SizedBox(height: 12),
              _sectionHeader('${business.packages.length} Package${business.packages.length == 1 ? '' : 's'}', () => notifier.goToStep(obPackageStep)),
              const SizedBox(height: 8),
              if (business.packages.isEmpty)
                Text('No packages added.', style: AppTextStyles.bodyMd())
              else
                for (final package in business.packages) ...[
                  PackageCardCustomerView(package: package),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
        WizardBottomBar(primaryLabel: 'Finish Setup', onPrimary: () => _finish(context, ref)),
      ],
    );
  }

  Widget _sectionHeader(String label, VoidCallback onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.labelMd()),
        TextButton(onPressed: onEdit, child: const Text('Edit')),
      ],
    );
  }

  Widget _profileCard(Vendor vendor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.surfaceContainerLowest, shape: BoxShape.circle),
            child: Icon(vendor.hasPhoto ? Icons.check_circle : Icons.person, color: AppColors.outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vendor.fullName.isEmpty ? 'Your Name' : vendor.fullName, style: AppTextStyles.labelMd()),
                const SizedBox(height: 2),
                Text(
                  [vendor.phone, if (vendor.email.isNotEmpty) vendor.email].where((s) => s.isNotEmpty).join(' · '),
                  style: AppTextStyles.bodyMd(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _businessCard(Business business) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.dflt),
            ),
            child: Icon(businessCategoryIcon(business.category), color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business.name.isEmpty ? 'Your Business' : business.name, style: AppTextStyles.labelMd()),
                const SizedBox(height: 2),
                Text(business.category, style: AppTextStyles.bodyMd()),
                if (business.location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(business.location, style: AppTextStyles.labelSm()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
