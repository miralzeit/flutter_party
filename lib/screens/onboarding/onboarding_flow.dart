import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/business_providers.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'onboarding_business_step.dart';
import 'onboarding_package_step.dart';
import 'onboarding_profile_step.dart';
import 'onboarding_review_step.dart';
import 'onboarding_services_step.dart';

const List<String> _stepTitles = [
  'Your Profile',
  'Your Business',
  'Add Services',
  'Create a Package',
  'Review & Finish',
];

/// The 5-step vendor onboarding wizard: Profile -> Business -> Services ->
/// Package (optional) -> Review. All 5 steps share one [onboardingProvider]
/// draft, so nothing is written to the real [vendorProvider] /
/// [businessesProvider] until step 5 is confirmed — a vendor can go back and
/// change an earlier answer without losing later steps.
///
/// Pass [isAdditionalBusiness] when re-entering this flow later (Settings ->
/// Manage Businesses -> "+ Add business"): the profile step is skipped
/// since the vendor already has one, and "Finish setup" adds the new
/// business to the existing vendor instead of creating a fresh one.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key, this.isAdditionalBusiness = false});

  final bool isAdditionalBusiness;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Riverpod forbids modifying a provider while the widget tree is still
    // mounting (which initState runs during) — defer to right after the
    // first frame, matching Riverpod's own recommended workaround. `_ready`
    // keeps that one frame from flashing the wrong starting step.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(onboardingProvider.notifier).start(
            isAdditionalBusiness: widget.isAdditionalBusiness,
            existingVendor: widget.isAdditionalBusiness ? ref.read(vendorProvider) : null,
          );
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: SizedBox.shrink());

    final step = ref.watch(onboardingProvider).step;
    final firstStep = widget.isAdditionalBusiness ? obBusinessStep : obProfileStep;
    final canGoBack = step > firstStep;

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitles[step]),
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => ref.read(onboardingProvider.notifier).back(),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(step: step),
            Expanded(child: _stepBody(step)),
          ],
        ),
      ),
    );
  }

  Widget _stepBody(int step) {
    switch (step) {
      case obProfileStep:
        return const OnboardingProfileStep();
      case obBusinessStep:
        return const OnboardingBusinessStep();
      case obServicesStep:
        return const OnboardingServicesStep();
      case obPackageStep:
        return const OnboardingPackageStep();
      case obReviewStep:
      default:
        return const OnboardingReviewStep();
    }
  }
}

/// Thin segmented bar — "how many steps are left" at a glance, not a
/// percentage number.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < obStepCount; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step ? AppColors.primary : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text('Step ${step + 1} of $obStepCount', style: AppTextStyles.labelSm()),
        ],
      ),
    );
  }
}
