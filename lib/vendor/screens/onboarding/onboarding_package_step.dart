import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/business.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wizard_bottom_bar.dart';
import '../create_package_screen.dart';

/// Step 4 — "Create a Package" (optional). Bundles the services just added
/// in step 3. Both "Skip for now" and "Next" move on regardless of whether
/// a package was created — this step never blocks onboarding.
class OnboardingPackageStep extends ConsumerStatefulWidget {
  const OnboardingPackageStep({super.key});

  @override
  ConsumerState<OnboardingPackageStep> createState() => _OnboardingPackageStepState();
}

class _OnboardingPackageStepState extends ConsumerState<OnboardingPackageStep> {
  void _addPackage(Business business) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CreatePackageScreen(business: business)))
        .then((_) => ref.read(onboardingProvider.notifier).touch());
  }

  void _editPackage(Business business, Package package) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CreatePackageScreen(business: business, initial: package)))
        .then((_) => ref.read(onboardingProvider.notifier).touch());
  }

  void _removePackage(Business business, Package package) {
    business.packages.remove(package);
    ref.read(onboardingProvider.notifier).touch();
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(onboardingProvider).business;
    final packages = business.packages;
    final notifier = ref.read(onboardingProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text('Bundle your services', style: AppTextStyles.headlineMd()),
              const SizedBox(height: 4),
              Text(
                'Bundle your services into a package for a better deal — you can always add this later.',
                style: AppTextStyles.bodyMd(),
              ),
              const SizedBox(height: 20),
              if (packages.isEmpty)
                Text('No packages added yet.', style: AppTextStyles.bodyMd())
              else
                for (final package in packages) ...[
                  _PackageRow(
                    package: package,
                    onEdit: () => _editPackage(business, package),
                    onRemove: () => _removePackage(business, package),
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: business.services.isEmpty ? null : () => _addPackage(business),
                icon: const Icon(Icons.add),
                label: const Text('Create a Package'),
              ),
            ],
          ),
        ),
        WizardBottomBar(
          primaryLabel: 'Next',
          onPrimary: notifier.next,
          secondaryLabel: 'Skip for now',
          onSecondary: notifier.next,
        ),
      ],
    );
  }
}

class _PackageRow extends StatelessWidget {
  const _PackageRow({required this.package, required this.onEdit, required this.onRemove});

  final Package package;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(child: Text(package.name, style: AppTextStyles.labelMd())),
          if (package.price != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text('${package.price!.toStringAsFixed(0)} ILS', style: AppTextStyles.labelSm()),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: 'Edit package',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            tooltip: 'Remove package',
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 18, color: AppColors.error),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
