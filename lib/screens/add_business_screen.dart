import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/photo_upload.dart';

/// Screen 6 — "Add Business". Every business category (wedding hall,
/// salon, catering, ...) reuses this exact same form; only the vendor's
/// own text differs.
class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key, this.initial, required this.onSubmit});

  final Business? initial;
  final ValueChanged<Business> onSubmit;

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  late final _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
  late final _priceCtrl = TextEditingController(text: widget.initial?.basePrice?.toString() ?? '');
  late String _category = widget.initial?.category ?? businessCategories.first;
  late int _photoCount = widget.initial?.photoCount ?? 0;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a business name.')),
      );
      return;
    }
    final business = widget.initial ?? Business(name: '', category: _category);
    business
      ..name = _nameCtrl.text.trim()
      ..category = _category
      ..description = _descriptionCtrl.text.trim()
      ..basePrice = double.tryParse(_priceCtrl.text.trim())
      ..photoCount = _photoCount;
    widget.onSubmit(business);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Business' : 'Add Business')),
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
                  _label('Business Name'),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(hintText: 'Example: Nissan Hall'),
                  ),
                  const SizedBox(height: 20),
                  _label('Category'),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    items: [
                      for (final category in businessCategories)
                        DropdownMenuItem(value: category, child: Text(category)),
                    ],
                    onChanged: (value) => setState(() => _category = value ?? _category),
                  ),
                  const SizedBox(height: 20),
                  _label('Description'),
                  TextField(
                    controller: _descriptionCtrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: 'Describe your business'),
                  ),
                  const SizedBox(height: 20),
                  _label('Base Price (Optional)'),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: '4000 ILS'),
                  ),
                  const SizedBox(height: 20),
                  UploadPhotosBox(
                    label: 'Business Photos',
                    count: _photoCount,
                    onUpload: () => setState(() => _photoCount += 1),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                    child: Text(_isEditing ? 'Save' : 'Next'),
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
}
