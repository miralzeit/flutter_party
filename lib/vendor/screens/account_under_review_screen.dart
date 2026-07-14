import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'onboarding/onboarding_flow.dart';

/// Shown right after a vendor completes registration, while their business
/// information is pending manual verification.
class AccountUnderReviewScreen extends StatelessWidget {
  const AccountUnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hourglass_top, color: AppColors.primary, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Account Under Review',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLgMobile(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thank you for joining Party Planner!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLg(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your vendor account has been successfully created.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Our team will verify your business information before making your profile visible to customers.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You will receive a notification once your account is approved.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const OnboardingFlow()),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
