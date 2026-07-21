import 'package:flutter/material.dart';
import '../models/business.dart';
import 'field_label.dart';
import 'photo_upload.dart';

/// The business form's fields, extracted out of a Scaffold/AppBar/submit-
/// button shell so it can be embedded two places with the same logic and
/// validation: [AddBusinessScreen] (its own screen, own Save button) and the
/// onboarding wizard's "Your business" step (wizard chrome, "Next" button).
///
/// Callers hold a `GlobalKey<BusinessFormFieldsState>` and call
/// [BusinessFormFieldsState.validateAndApply] from their own submit action.
class BusinessFormFields extends StatefulWidget {
  const BusinessFormFields({super.key, this.initial});

  /// Existing business to prefill from, when editing.
  final Business? initial;

  @override
  State<BusinessFormFields> createState() => BusinessFormFieldsState();
}

class BusinessFormFieldsState extends State<BusinessFormFields> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
  late final _descriptionCtrl = TextEditingController(text: widget.initial?.description ?? '');
  late final _priceCtrl = TextEditingController(text: widget.initial?.basePrice?.toString() ?? '');
  late final _cityCtrl = TextEditingController(text: widget.initial?.location ?? '');
  late final _addressCtrl = TextEditingController(text: widget.initial?.address ?? '');
  late final _hoursCtrl = TextEditingController(text: widget.initial?.businessHours ?? '');
  late final _capacityCtrl = TextEditingController(text: widget.initial?.capacity?.toString() ?? '');
  // business-level WhatsApp removed — prefer vendor personal WhatsApp
  late final _instagramCtrl = TextEditingController(text: widget.initial?.instagram ?? '');
  late final _facebookCtrl = TextEditingController(text: widget.initial?.facebook ?? '');
  late String _category = widget.initial?.category ?? businessCategories.first;
  late int _photoCount = widget.initial?.photoCount ?? 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _hoursCtrl.dispose();
    _capacityCtrl.dispose();
    // no whatsapp controller to dispose
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    super.dispose();
  }

  /// Validates the form and, if valid, writes the entered values onto
  /// [target] (mutated in place, matching how every other form in this app
  /// applies its edits). Returns whether the form was valid.
  bool validateAndApply(Business target) {
    if (!_formKey.currentState!.validate()) return false;
    target
      ..name = _nameCtrl.text.trim()
      ..category = _category
      ..description = _descriptionCtrl.text.trim()
      ..basePrice = double.tryParse(_priceCtrl.text.trim())
      ..location = _cityCtrl.text.trim()
      ..address = _addressCtrl.text.trim()
      ..businessHours = _hoursCtrl.text.trim()
      ..capacity = int.tryParse(_capacityCtrl.text.trim())
      ..instagram = _instagramCtrl.text.trim()
      ..facebook = _facebookCtrl.text.trim()
      ..photoCount = _photoCount;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldLabel('Business Name'),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Example: Nissan Hall'),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a business name.' : null,
          ),
          const SizedBox(height: 20),
          const FieldLabel('Category'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: [
              for (final category in businessCategories) DropdownMenuItem(value: category, child: Text(category)),
            ],
            onChanged: (value) => setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: 20),
          const FieldLabel('City'),
          TextFormField(
            controller: _cityCtrl,
            decoration: const InputDecoration(hintText: 'Bethlehem'),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Address (Optional)'),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(hintText: 'Street, building, floor...'),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Business Hours (Optional)'),
          TextFormField(
            controller: _hoursCtrl,
            decoration: const InputDecoration(hintText: 'Example: Mon–Sat, 9am–9pm'),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Capacity — Guests (Optional)'),
          TextFormField(
            controller: _capacityCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Example: 400'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              return int.tryParse(value.trim()) == null ? 'Enter a whole number.' : null;
            },
          ),
          const SizedBox(height: 20),
          // Business WhatsApp moved to vendor profile; omit duplicate field.
          const FieldLabel('Description'),
          TextFormField(
            controller: _descriptionCtrl,
            minLines: 3,
            maxLines: 5,
            maxLength: 300,
            decoration: const InputDecoration(hintText: 'Describe your business'),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Base Price (Optional)'),
          TextFormField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: '4000 ILS'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              return double.tryParse(value.trim()) == null ? 'Enter a valid number.' : null;
            },
          ),
          const SizedBox(height: 20),
          const FieldLabel('Instagram Handle (Optional)'),
          TextFormField(
            controller: _instagramCtrl,
            decoration: const InputDecoration(hintText: '@yourbusiness'),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Facebook Page (Optional)'),
          TextFormField(
            controller: _facebookCtrl,
            decoration: const InputDecoration(hintText: 'facebook.com/yourbusiness'),
          ),
          const SizedBox(height: 20),
          UploadPhotosBox(
            label: 'Business Photos',
            count: _photoCount,
            onUpload: () => setState(() => _photoCount += 1),
          ),
        ],
      ),
    );
  }
}
