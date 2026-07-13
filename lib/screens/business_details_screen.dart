import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'add_business_screen.dart';
import 'add_services_screen.dart';

/// Screen 9 — "Business Details" / vendor's per-business dashboard, reached
/// after finishing the Add Business + Add Services steps, or by tapping a
/// business from [MyBusinessesScreen].
class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key, required this.business, required this.onDelete});

  final Business business;
  final VoidCallback onDelete;

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  Business get _business => widget.business;

  void _editBusiness() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBusinessScreen(
          initial: _business,
          onSubmit: (_) {
            setState(() {});
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _manageServices() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AddServicesScreen(
              business: _business,
              onFinish: () => Navigator.of(context).pop(),
            ),
          ),
        )
        .then((_) => setState(() {}));
  }

  void _addMorePhotos() => setState(() => _business.photoCount += 1);

  Future<void> _deleteBusiness() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Business'),
        content: Text('Are you sure you want to delete "${_business.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onDelete();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_business.name)),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(businessCategoryIcon(_business.category), color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${_business.photoCount} Photo${_business.photoCount == 1 ? '' : 's'}',
                        style: AppTextStyles.bodyMd(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Description', style: AppTextStyles.labelMd()),
                  const SizedBox(height: 6),
                  Text(
                    _business.description.isEmpty ? 'No description yet.' : _business.description,
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 20),
                  Text('Base Price', style: AppTextStyles.labelMd()),
                  const SizedBox(height: 6),
                  Text(
                    _business.basePrice != null ? '${_business.basePrice!.toStringAsFixed(0)} ILS' : 'Not set',
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 24),
                  Text('Services (${_business.services.length})', style: AppTextStyles.labelMd()),
                  const SizedBox(height: 8),
                  if (_business.services.isEmpty)
                    Text('No services added yet.', style: AppTextStyles.bodyMd())
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        children: [
                          for (final service in _business.services)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(child: Text(service.name, style: AppTextStyles.bodyMd(color: AppColors.onSurface))),
                                  if (service.price != null)
                                    Text('${service.price!.toStringAsFixed(0)} ILS', style: AppTextStyles.labelSm()),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _editBusiness,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Business'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _manageServices,
                    icon: const Icon(Icons.design_services_outlined, size: 18),
                    label: const Text('Manage Services'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _addMorePhotos,
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                    label: const Text('Add More Photos'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _deleteBusiness,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete Business'),
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
