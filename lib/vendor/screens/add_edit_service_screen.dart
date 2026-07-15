import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/field_label.dart';
import '../widgets/photo_upload.dart';

/// Screen 8 — "Add / Edit Service". The single most-reused screen in the
/// vendor flow: the same name/category/description/price/details form
/// works for any business type — vendors add their own free-form detail
/// rows (Capacity, Duration, Home Service, ...) via the "Add Detail" sheet.
class AddEditServiceScreen extends StatefulWidget {
  const AddEditServiceScreen({super.key, this.initial, required this.onSubmit});

  final Service? initial;
  final ValueChanged<Service> onSubmit;

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
  late final _priceCtrl = TextEditingController(text: widget.initial?.price?.toString() ?? '');
  late String _category = widget.initial?.category.isNotEmpty == true ? widget.initial!.category : serviceCategories.first;
  late int _photoCount = widget.initial?.photoCount ?? 0;
  late final List<ServiceDetail> _details = [
    for (final d in widget.initial?.details ?? const <ServiceDetail>[]) ServiceDetail(label: d.label, value: d.value),
  ];

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _addDetail() async {
    final detail = await showModalBottomSheet<ServiceDetail>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddDetailSheet(),
    );
    if (detail != null) setState(() => _details.add(detail));
  }

  void _removeDetail(ServiceDetail detail) => setState(() => _details.remove(detail));

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final service = widget.initial ?? Service(name: '');
    service
      ..name = _nameCtrl.text.trim()
      ..category = _category
      ..description = _descriptionCtrl.text.trim()
      ..price = double.tryParse(_priceCtrl.text.trim())
      ..photoCount = _photoCount
      ..details = List.of(_details);
    widget.onSubmit(service);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Service' : 'Add Service')),
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
                    const FieldLabel('Service Name'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(hintText: 'Example: Bridal Makeup'),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a service name.' : null,
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Category'),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: [
                        for (final category in serviceCategories) DropdownMenuItem(value: category, child: Text(category)),
                      ],
                      onChanged: (value) => setState(() => _category = value ?? _category),
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Description'),
                    TextFormField(
                      controller: _descriptionCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(hintText: 'Describe your service'),
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Base Price (Optional)'),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(prefixText: 'ILS ', hintText: '120'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return double.tryParse(value.trim()) == null ? 'Enter a valid number.' : null;
                      },
                    ),
                    const SizedBox(height: 20),
                    PhotoGridPicker(
                      label: 'Service Photos',
                      count: _photoCount,
                      onAdd: () => setState(() => _photoCount += 1),
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Additional Details'),
                    if (_details.isEmpty)
                      Text('No details added yet.', style: AppTextStyles.bodyMd(color: AppColors.outline).copyWith(fontStyle: FontStyle.italic))
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: [
                            for (final detail in _details)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: '${detail.label}: ', style: AppTextStyles.labelMd()),
                                            TextSpan(text: detail.value, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeDetail(detail),
                                      icon: const Icon(Icons.close, size: 18, color: AppColors.outline),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _addDetail,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Detail'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                      child: const Text('Save Service'),
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

/// Modal bottom sheet for adding one custom label/value [ServiceDetail] row
/// (e.g. "Max guests" / "300 people") to the parent form's detail list.
class _AddDetailSheet extends StatefulWidget {
  const _AddDetailSheet();

  @override
  State<_AddDetailSheet> createState() => _AddDetailSheetState();
}

class _AddDetailSheetState extends State<_AddDetailSheet> {
  final _labelCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _add() {
    if (_labelCtrl.text.trim().isEmpty || _valueCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop(ServiceDetail(label: _labelCtrl.text.trim(), value: _valueCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Detail', style: AppTextStyles.headlineMd()),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _labelCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. Max guests, Duration...'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _valueCtrl,
                  decoration: const InputDecoration(hintText: 'e.g. 300 people...'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _add,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
