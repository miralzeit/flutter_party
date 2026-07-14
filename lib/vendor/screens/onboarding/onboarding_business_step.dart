import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/business_form_fields.dart';
import '../../widgets/wizard_bottom_bar.dart';

/// Step 2 — "Your Business". Field-for-field the same [BusinessFormFields]
/// used to edit a business later from the Dashboard, just embedded in the
/// wizard's own chrome instead of its own screen + Save button.
class OnboardingBusinessStep extends ConsumerStatefulWidget {
  const OnboardingBusinessStep({super.key});

  @override
  ConsumerState<OnboardingBusinessStep> createState() => _OnboardingBusinessStepState();
}

class _OnboardingBusinessStepState extends ConsumerState<OnboardingBusinessStep> {
  final _fieldsKey = GlobalKey<BusinessFormFieldsState>();

  void _next() {
    final state = ref.read(onboardingProvider);
    if (_fieldsKey.currentState!.validateAndApply(state.business)) {
      final notifier = ref.read(onboardingProvider.notifier);
      notifier.touch();
      notifier.next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: BusinessFormFields(
              key: _fieldsKey,
              initial: state.business,
              defaultWhatsapp: state.vendor.whatsapp,
            ),
          ),
        ),
        WizardBottomBar(primaryLabel: 'Next', onPrimary: _next),
      ],
    );
  }
}
