import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/field_label.dart';

/// Screen — "Create / Edit Package". Bundles a business's existing
/// [Service]s together under one name and price via a multi-select list.
class CreatePackageScreen extends StatefulWidget {
  const CreatePackageScreen({super.key, required this.business, this.initial});

  final Business business;
  final Package? initial;

  @override
  State<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends State<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
  late final _priceCtrl = TextEditingController(text: widget.initial?.price?.toString() ?? '');
  late final Set<Service> _selected = {...?widget.initial?.includedServices};

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _toggle(Service service) => setState(() {
        if (_selected.contains(service)) {
          _selected.remove(service);
        } else {
          _selected.add(service);
        }
      });

  double get _originalPrice => _selected.fold(0.0, (sum, service) => sum + (service.price ?? 0));

  double? get _savings {
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null) return null;
    final diff = _originalPrice - price;
    return diff > 0 ? diff : null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final package = widget.initial ?? Package(name: '');
    package
      ..name = _nameCtrl.text.trim()
      ..description = _descriptionCtrl.text.trim()
      ..price = double.tryParse(_priceCtrl.text.trim())
      ..includedServices = widget.business.services.where(_selected.contains).toList();
    if (!_isEditing) widget.business.packages.add(package);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.business.services;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Package' : 'Create Package')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Package Name'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(hintText: 'Example: Silver Wedding Package'),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a package name.' : null,
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Price (Optional)'),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(prefixText: 'ILS ', hintText: '4000'),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return double.tryParse(value.trim()) == null ? 'Enter a valid number.' : null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Description'),
                    TextFormField(
                      controller: _descriptionCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(hintText: 'Describe what this package includes'),
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Included Services'),
                    if (services.isEmpty)
                      Text(
                        'Add services to this business first before creating a package.',
                        style: AppTextStyles.bodyMd(color: AppColors.outline).copyWith(fontStyle: FontStyle.italic),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: [
                            for (final service in services)
                              InkWell(
                                onTap: () => _toggle(service),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _selected.contains(service) ? Icons.check_circle : Icons.circle_outlined,
                                        color: _selected.contains(service) ? AppColors.tertiary : AppColors.outline,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(service.name, style: AppTextStyles.bodyMd(color: AppColors.onSurface))),
                                      if (service.price != null)
                                        Text('${service.price!.toStringAsFixed(0)} ILS', style: AppTextStyles.labelSm()),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (_selected.isNotEmpty && _originalPrice > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Original Price', style: AppTextStyles.bodyMd()),
                                const Spacer(),
                                Text('${_originalPrice.toStringAsFixed(0)} ILS', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                              ],
                            ),
                            if (_savings != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.tertiaryContainer.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.dflt),
                                  border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  '🎉 Customers save ${_savings!.toStringAsFixed(0)} ILS',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.labelMd(color: AppColors.tertiary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                      child: Text(_isEditing ? 'Save Package' : 'Create Package'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
