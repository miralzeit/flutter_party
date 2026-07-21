import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin_category.dart';
import '../../providers/admin_providers.dart';
import '../../theme/admin_colors.dart';
import '../../theme/admin_text_styles.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/field_label.dart';

enum _SaveState { idle, saving, saved }

/// Screen — "Add / Edit Category". Same form for both; pre-filled when
/// [initial] is supplied. Pops `true` once the category is actually saved so
/// Category Management can show the "Changes saved successfully." toast.
class AddEditCategoryScreen extends ConsumerStatefulWidget {
  const AddEditCategoryScreen({super.key, this.initial});

  final AdminCategory? initial;

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
  late final _orderCtrl = TextEditingController(text: widget.initial?.displayOrder.toString() ?? '');
  late String _icon = widget.initial?.icon ?? adminCategoryIcons.keys.first;
  late bool _isActive = widget.initial?.isActive ?? true;
  _SaveState _saveState = _SaveState.idle;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saveState = _SaveState.saving);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final category = AdminCategory(
      id: widget.initial?.id ?? 'cat_${DateTime.now().microsecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      icon: _icon,
      displayOrder: int.parse(_orderCtrl.text.trim()),
      isActive: _isActive,
    );
    ref.read(categoriesProvider.notifier).upsert(category);

    setState(() => _saveState = _SaveState.saved);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.of(context).pop(true);
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Category name is required.';
    final categories = ref.read(categoriesProvider);
    final duplicate = categories.any((c) => c.id != widget.initial?.id && c.name.toLowerCase() == value.trim().toLowerCase());
    if (duplicate) return 'A category with this name already exists.';
    return null;
  }

  String? _validateOrder(String? value) {
    if (value == null || value.trim().isEmpty) return 'Display order is required.';
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) return 'Enter a non-negative whole number.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Category' : 'Add Category')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AdminSpacing.margin),
                children: [
                  _SectionCard(
                    title: 'Category Details',
                    children: [
                      const AdminFieldLabel('Category Name'),
                      TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Example: Catering'), validator: _validateName),
                      const SizedBox(height: 16),
                      const AdminFieldLabel('Description'),
                      TextFormField(
                        controller: _descriptionCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(hintText: 'Shown as helper copy to end users'),
                      ),
                      const SizedBox(height: 16),
                      const AdminFieldLabel('Select Icon'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final entry in adminCategoryIcons.entries)
                            InkWell(
                              onTap: () => setState(() => _icon = entry.key),
                              borderRadius: BorderRadius.circular(AdminRadius.sm),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _icon == entry.key ? AdminColors.primary : AdminColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(AdminRadius.sm),
                                  border: Border.all(color: _icon == entry.key ? AdminColors.primary : AdminColors.outlineVariant),
                                ),
                                child: Icon(entry.value, color: _icon == entry.key ? Colors.white : AdminColors.onSurfaceVariant, size: 20),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const AdminFieldLabel('Display Order'),
                      TextFormField(
                        controller: _orderCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Determines position in the main menu'),
                        validator: _validateOrder,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Secure Configuration',
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Active Status', style: AdminTextStyles.labelMd()),
                        subtitle: Text('Controls visibility on the public site.', style: AdminTextStyles.bodyMd()),
                        value: _isActive,
                        activeThumbColor: AdminColors.tertiary,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveState == _SaveState.idle ? _save : null,
                      child: _buildButtonChild(),
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

  Widget _buildButtonChild() {
    switch (_saveState) {
      case _SaveState.idle:
        return const Text('Save Category');
      case _SaveState.saving:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('Saving…'),
          ],
        );
      case _SaveState.saved:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text('Saved Successfully'),
          ],
        );
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AdminRadius.md),
        border: Border.all(color: AdminColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AdminTextStyles.headlineMd()),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
