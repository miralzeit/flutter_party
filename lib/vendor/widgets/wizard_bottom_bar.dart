import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-width primary action pinned to the bottom of an onboarding step,
/// with an optional secondary ghost action above it (e.g. "Skip for now").
/// Each step owns its own bar so button enablement can depend on that
/// step's own validation state.
class WizardBottomBar extends StatelessWidget {
  const WizardBottomBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (secondaryLabel != null) ...[
            TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: onPrimary,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}
