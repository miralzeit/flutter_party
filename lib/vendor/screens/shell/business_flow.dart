import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../onboarding/onboarding_flow.dart';

/// Launches the same 5-step onboarding wizard used at first signup, starting
/// at "Your Business" (the vendor already has a profile). Shared by the
/// business switcher's "Add business" row, the Dashboard's empty state, and
/// Manage Businesses — anywhere a vendor can start a new business.
void startAddBusinessFlow(BuildContext context, WidgetRef ref) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const OnboardingFlow(isAdditionalBusiness: true)),
  );
}
