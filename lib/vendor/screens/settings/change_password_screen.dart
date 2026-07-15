import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/field_label.dart';

/// "Change Password" — no auth backend exists yet, so like every other form
/// in this app (photo upload, account creation) this just simulates success.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated (demo).')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
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
                    const FieldLabel('Current Password'),
                    TextFormField(
                      controller: _currentCtrl,
                      obscureText: _obscure,
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter your current password.' : null,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('New Password'),
                    TextFormField(
                      controller: _newCtrl,
                      obscureText: _obscure,
                      validator: (v) => (v == null || v.length < 8) ? 'Use at least 8 characters.' : null,
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel('Confirm New Password'),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure,
                      validator: (v) => (v != _newCtrl.text) ? 'Passwords do not match.' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                      child: const Text('Save'),
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
