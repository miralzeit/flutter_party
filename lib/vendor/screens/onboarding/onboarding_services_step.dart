import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/business.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/wizard_bottom_bar.dart';
import '../add_edit_service_screen.dart';

/// Step 3 — "Add Services". Frames onboarding as building a catalog, not
/// filling out a form: a running list of what's been added, plus a button
/// that pushes the existing Add Service screen and returns here on save.
/// At least one service is required before "Next" proceeds.
class OnboardingServicesStep extends ConsumerStatefulWidget {
  const OnboardingServicesStep({super.key});

  @override
  ConsumerState<OnboardingServicesStep> createState() => _OnboardingServicesStepState();
}

class _OnboardingServicesStepState extends ConsumerState<OnboardingServicesStep> {
  bool _showEmptyHint = false;

  void _addService(Business business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          onSubmit: (service) {
            business.services.add(service);
            ref.read(onboardingProvider.notifier).touch();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _editService(Business business, Service service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          initial: service,
          onSubmit: (_) {
            ref.read(onboardingProvider.notifier).touch();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _removeService(Business business, Service service) {
    business.services.remove(service);
    ref.read(onboardingProvider.notifier).touch();
  }

  void _next(Business business) {
    if (business.services.isEmpty) {
      setState(() => _showEmptyHint = true);
      return;
    }
    ref.read(onboardingProvider.notifier).next();
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(onboardingProvider).business;
    final services = business.services;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text('What do you offer?', style: AppTextStyles.headlineMd()),
              const SizedBox(height: 4),
              Text('Add the services this business offers — you can add as many as you like.', style: AppTextStyles.bodyMd()),
              const SizedBox(height: 20),
              if (services.isEmpty)
                Text('No services added yet.', style: AppTextStyles.bodyMd())
              else
                for (final service in services) ...[
                  _ServiceRow(
                    service: service,
                    onEdit: () => _editService(business, service),
                    onRemove: () => _removeService(business, service),
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _addService(business),
                icon: const Icon(Icons.add),
                label: const Text('Add a Service'),
              ),
              if (_showEmptyHint && services.isEmpty) ...[
                const SizedBox(height: 12),
                Text('Add at least one service to continue.', style: AppTextStyles.labelSm(color: AppColors.error)),
              ],
            ],
          ),
        ),
        WizardBottomBar(primaryLabel: 'Next', onPrimary: () => _next(business)),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service, required this.onEdit, required this.onRemove});

  final Service service;
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
          Expanded(child: Text(service.name, style: AppTextStyles.labelMd())),
          if (service.price != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text('${service.price!.toStringAsFixed(0)} ILS', style: AppTextStyles.labelSm()),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: 'Edit service',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            tooltip: 'Remove service',
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
