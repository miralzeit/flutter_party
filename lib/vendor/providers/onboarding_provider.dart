import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../models/vendor.dart';

/// Step indices for [OnboardingFlow]. "Additional business" runs start at
/// [business] and never show [profile].
const int obProfileStep = 0;
const int obBusinessStep = 1;
const int obServicesStep = 2;
const int obPackageStep = 3;
const int obReviewStep = 4;
const int obStepCount = 5;

class OnboardingState {
  OnboardingState({
    required this.vendor,
    required this.business,
    required this.step,
    required this.isAdditionalBusiness,
  });

  /// Draft vendor profile. Nothing here is written to [vendorProvider] until
  /// [OnboardingNotifier.commit] runs on the Review step's "Finish setup".
  final Vendor vendor;

  /// Draft business — services/packages accumulate directly on this object
  /// (the same existing Add Service / Create Package screens mutate it in
  /// place), and it's only added to [businessesProvider] on commit.
  final Business business;
  final int step;
  final bool isAdditionalBusiness;

  OnboardingState copyWith({int? step}) => OnboardingState(
        vendor: vendor,
        business: business,
        step: step ?? this.step,
        isAdditionalBusiness: isAdditionalBusiness,
      );
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => OnboardingState(
        vendor: Vendor(fullName: ''),
        business: Business(name: '', category: businessCategories.first),
        step: obProfileStep,
        isAdditionalBusiness: false,
      );

  /// Resets the draft. [isAdditionalBusiness] runs skip the profile step
  /// entirely and reuse [existingVendor] rather than a blank draft.
  void start({bool isAdditionalBusiness = false, Vendor? existingVendor}) {
    state = OnboardingState(
      vendor: existingVendor ?? Vendor(fullName: ''),
      business: Business(name: '', category: businessCategories.first),
      step: isAdditionalBusiness ? obBusinessStep : obProfileStep,
      isAdditionalBusiness: isAdditionalBusiness,
    );
  }

  void goToStep(int step) => state = state.copyWith(step: step);

  void next() => goToStep(state.step + 1);

  void back() => goToStep(state.step - 1);

  /// [state.vendor] / [state.business] are mutated in place by the step
  /// screens (same pattern as [BusinessesNotifier.touch]) — call this after
  /// such a mutation so watchers (the Review step's summary, in particular)
  /// pick it up.
  void touch() => state = state.copyWith();
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);
