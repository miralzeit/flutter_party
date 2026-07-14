import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../widgets/business_form_fields.dart';

/// Screen 6 — "Add Business". Every business category (wedding hall,
/// salon, catering, ...) reuses this exact same form; only the vendor's
/// own text differs. The fields themselves live in [BusinessFormFields] so
/// the onboarding wizard's "Your business" step can reuse them too.
class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key, this.initial, required this.onSubmit});

  final Business? initial;
  final ValueChanged<Business> onSubmit;

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _fieldsKey = GlobalKey<BusinessFormFieldsState>();

  bool get _isEditing => widget.initial != null;

  void _submit() {
    final business = widget.initial ?? Business(name: '', category: businessCategories.first);
    if (_fieldsKey.currentState!.validateAndApply(business)) {
      widget.onSubmit(business);
    }
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
                  BusinessFormFields(key: _fieldsKey, initial: widget.initial),
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
}
