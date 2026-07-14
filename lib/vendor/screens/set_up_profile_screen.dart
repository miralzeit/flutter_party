import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vendor.dart';
import '../providers/business_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/photo_upload.dart';

/// "Edit Personal Information" — reached from Settings. First-time profile
/// setup now happens on step 1 of [OnboardingFlow]; this screen only ever
/// edits an existing [Vendor].
class SetUpProfileScreen extends ConsumerStatefulWidget {
  const SetUpProfileScreen({super.key, required this.initial});

  final Vendor initial;

  @override
  ConsumerState<SetUpProfileScreen> createState() => _SetUpProfileScreenState();
}

class _SetUpProfileScreenState extends ConsumerState<SetUpProfileScreen> {
  late final _fullNameCtrl = TextEditingController(text: widget.initial.fullName);
  late final _bioCtrl = TextEditingController(text: widget.initial.bio);
  late final _phoneCtrl = TextEditingController(text: widget.initial.phone);
  late final _whatsappCtrl = TextEditingController(text: widget.initial.whatsapp);
  late final _emailCtrl = TextEditingController(text: widget.initial.email);
  late final _cityCtrl = TextEditingController(text: widget.initial.city);
  late bool _hasPhoto = widget.initial.hasPhoto;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_fullNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }
    widget.initial
      ..fullName = _fullNameCtrl.text.trim()
      ..bio = _bioCtrl.text.trim()
      ..phone = _phoneCtrl.text.trim()
      ..whatsapp = _whatsappCtrl.text.trim()
      ..email = _emailCtrl.text.trim()
      ..city = _cityCtrl.text.trim()
      ..hasPhoto = _hasPhoto;

    ref.read(vendorProvider.notifier).state = widget.initial.copy();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Personal Information')),
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
                  Center(
                    child: ProfilePhotoPicker(
                      hasPhoto: _hasPhoto,
                      onUpload: () => setState(() => _hasPhoto = true),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _label('Full Name'),
                  TextField(
                    controller: _fullNameCtrl,
                    decoration: const InputDecoration(hintText: 'Enter your full name'),
                  ),
                  const SizedBox(height: 20),
                  _label('Bio (Optional)'),
                  TextField(
                    controller: _bioCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Tell customers a bit about yourself'),
                  ),
                  const SizedBox(height: 20),
                  _label('Email'),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'you@example.com'),
                  ),
                  const SizedBox(height: 20),
                  _label('Phone Number'),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '059xxxxxxx'),
                  ),
                  const SizedBox(height: 20),
                  _label('WhatsApp'),
                  TextField(
                    controller: _whatsappCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '059xxxxxxx'),
                  ),
                  const SizedBox(height: 20),
                  _label('City'),
                  TextField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(hintText: 'Bethlehem'),
                  ),
                  const SizedBox(height: 32),
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
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(text, style: AppTextStyles.labelMd()),
      );
}
