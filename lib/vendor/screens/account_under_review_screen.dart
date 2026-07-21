import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'onboarding/onboarding_flow.dart';

/// Shown right after a vendor completes registration, while their business
/// information is pending manual verification. Communicates the current
/// status with a short verification timeline and a clear next step (the
/// vendor can keep building their profile while review is pending).
class AccountUnderReviewScreen extends StatelessWidget {
  const AccountUnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HeroBadge(),
                  const SizedBox(height: 28),
                  Text(
                    'Account Under Review',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLgMobile(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your vendor account has been created and is now pending verification by our team.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  const _ReviewTimeline(),
                  const SizedBox(height: 16),
                  const _InfoNote(
                    icon: Icons.schedule_rounded,
                    text: 'Verification usually takes 24–48 hours. We\'ll notify you as soon as your profile is approved.',
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const OnboardingFlow()),
                      ),
                      child: const Text('Continue Setting Up'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can keep building your profile while we review.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
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

/// Branded gradient badge with a soft glow — the screen's focal point.
class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(Icons.verified_user_outlined, color: AppColors.onPrimary, size: 46),
      ),
    );
  }
}

/// A three-step verification timeline: Created (done) → Under review
/// (current) → Profile live (upcoming).
class _ReviewTimeline extends StatelessWidget {
  const _ReviewTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: const Column(
        children: [
          _StepRow(
            state: _StepState.done,
            title: 'Account created',
            subtitle: 'Your registration was submitted successfully.',
            showConnector: true,
          ),
          _StepRow(
            state: _StepState.current,
            title: 'Under review',
            subtitle: 'Our team is verifying your business details.',
            showConnector: true,
          ),
          _StepRow(
            state: _StepState.upcoming,
            title: 'Profile goes live',
            subtitle: 'Customers can discover and contact you.',
            showConnector: false,
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.state,
    required this.title,
    required this.subtitle,
    required this.showConnector,
  });

  final _StepState state;
  final String title;
  final String subtitle;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = state == _StepState.upcoming;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _StepMarker(state: state),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showConnector ? 20 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMd(
                      color: isUpcoming ? AppColors.onSurfaceVariant : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepMarker extends StatelessWidget {
  const _StepMarker({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _StepState.done:
        return const _MarkerCircle(
          color: AppColors.tertiary,
          child: Icon(Icons.check, size: 15, color: AppColors.onPrimary),
        );
      case _StepState.current:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
            ),
          ),
        );
      case _StepState.upcoming:
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant, width: 2),
          ),
        );
    }
  }
}

class _MarkerCircle extends StatelessWidget {
  const _MarkerCircle({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(child: child),
    );
  }
}

/// Soft-tinted information row (timeframe / notification note).
class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
