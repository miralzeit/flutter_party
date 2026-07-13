import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'add_edit_service_screen.dart';

/// Screen 7 — "Add Services". Lists the services already added to
/// [business] and lets the vendor add or edit more before finishing.
class AddServicesScreen extends StatefulWidget {
  const AddServicesScreen({super.key, required this.business, required this.onFinish});

  final Business business;
  final VoidCallback onFinish;

  @override
  State<AddServicesScreen> createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends State<AddServicesScreen> {
  void _addService() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          onSubmit: (service) {
            setState(() => widget.business.services.add(service));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _editService(Service service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          initial: service,
          onSubmit: (updated) {
            setState(() {
              final index = widget.business.services.indexOf(service);
              widget.business.services[index] = updated;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.business.services;
    return Scaffold(
      appBar: AppBar(title: Text(widget.business.name.isEmpty ? 'Services' : widget.business.name)),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text('Services', style: AppTextStyles.headlineMd()),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: services.isEmpty
                      ? Center(
                          child: Text(
                            'No services added yet.',
                            style: AppTextStyles.bodyMd(),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: services.length,
                          separatorBuilder: (_, _) => const Divider(height: 24),
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return InkWell(
                              onTap: () => _editService(service),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(service.name, style: AppTextStyles.labelMd()),
                                        const SizedBox(height: 4),
                                        Text(
                                          service.price != null ? '${service.price!.toStringAsFixed(0)} ILS' : 'No price set',
                                          style: AppTextStyles.bodyMd(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text('Edit', style: AppTextStyles.labelMd(color: AppColors.primary)),
                                      const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextButton.icon(
                        onPressed: _addService,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Service'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: widget.onFinish,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                        child: const Text('Finish'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
