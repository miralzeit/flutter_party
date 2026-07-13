import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/photo_upload.dart';

class _DetailRow {
  _DetailRow({String label = '', String value = ''})
      : labelCtrl = TextEditingController(text: label),
        valueCtrl = TextEditingController(text: value);

  final TextEditingController labelCtrl;
  final TextEditingController valueCtrl;

  void dispose() {
    labelCtrl.dispose();
    valueCtrl.dispose();
  }
}

/// Screen 8 — "Add / Edit Service". The single most-reused screen in the
/// vendor flow: the same name/description/price/details form works whether
/// the business is a wedding hall (Capacity, Garden, Swimming Pool) or a
/// salon (Duration, Products, Home Service) — only the label text differs,
/// and vendors type that themselves via the free-form detail rows.
class AddEditServiceScreen extends StatefulWidget {
  const AddEditServiceScreen({super.key, this.initial, required this.onSubmit});

  final Service? initial;
  final ValueChanged<Service> onSubmit;

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  late final _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
  late final _priceCtrl = TextEditingController(text: widget.initial?.price?.toString() ?? '');
  late int _photoCount = widget.initial == null ? 0 : 1;

  late final List<_DetailRow> _details = widget.initial != null && widget.initial!.details.isNotEmpty
      ? [for (final d in widget.initial!.details) _DetailRow(label: d.label, value: d.value)]
      : [_DetailRow(label: 'Capacity'), _DetailRow(label: 'Garden'), _DetailRow(label: 'Swimming Pool')];

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    for (final detail in _details) {
      detail.dispose();
    }
    super.dispose();
  }

  void _addDetailRow() => setState(() => _details.add(_DetailRow()));

  void _removeDetailRow(_DetailRow row) => setState(() {
        _details.remove(row);
        row.dispose();
      });

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a service name.')),
      );
      return;
    }
    final service = Service(
      name: _nameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()),
      details: [
        for (final row in _details)
          if (row.labelCtrl.text.trim().isNotEmpty || row.valueCtrl.text.trim().isNotEmpty)
            ServiceDetail(label: row.labelCtrl.text.trim(), value: row.valueCtrl.text.trim()),
      ],
    );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label('Service Name'),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(hintText: 'Example: Bridal Makeup'),
                  ),
                  const SizedBox(height: 20),
                  _label('Description'),
                  TextField(
                    controller: _descriptionCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: 'Describe your service'),
                  ),
                  const SizedBox(height: 20),
                  _label('Price'),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: '120 ILS'),
                  ),
                  const SizedBox(height: 20),
                  UploadPhotosBox(
                    label: 'Service Photos',
                    count: _photoCount,
                    onUpload: () => setState(() => _photoCount += 1),
                  ),
                  const SizedBox(height: 20),
                  _label('Additional Details'),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        for (final detail in _details) _detailRow(detail),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _addDetailRow,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Another Detail'),
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
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(text, style: AppTextStyles.labelMd()),
      );

  Widget _detailRow(_DetailRow detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: TextField(
              controller: detail.labelCtrl,
              style: AppTextStyles.labelMd(),
              decoration: const InputDecoration(
                hintText: 'Label',
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('|', style: AppTextStyles.bodyMd(color: AppColors.outlineVariant)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: detail.valueCtrl,
              style: AppTextStyles.bodyMd(color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'Value',
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeDetailRow(detail),
            icon: const Icon(Icons.close, size: 18, color: AppColors.outline),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
