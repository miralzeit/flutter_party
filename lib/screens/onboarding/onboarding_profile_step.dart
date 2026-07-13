import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/photo_upload.dart';
import '../../widgets/wizard_bottom_bar.dart';

/// Step 1 — "Your Profile". Personal info only (name/phone/whatsapp/email);
/// bio and city stay in Settings' fuller profile editor, not onboarding.
class OnboardingProfileStep extends ConsumerStatefulWidget {
  const OnboardingProfileStep({super.key});

  @override
  ConsumerState<OnboardingProfileStep> createState() => _OnboardingProfileStepState();
}

class _OnboardingProfileStepState extends ConsumerState<OnboardingProfileStep> {
  final _formKey = GlobalKey<FormState>();
  late final _draft = ref.read(onboardingProvider).vendor;
  late final _nameCtrl = TextEditingController(text: _draft.fullName);
  late final _phoneCtrl = TextEditingController(text: _draft.phone);
  late final _whatsappCtrl = TextEditingController(text: _draft.whatsapp);
  late final _emailCtrl = TextEditingController(text: _draft.email);
  late bool _hasPhoto = _draft.hasPhoto;
  bool _autovalidate = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _isValid => _nameCtrl.text.trim().isNotEmpty && _phoneCtrl.text.trim().isNotEmpty;

  void _next() {
    setState(() => _autovalidate = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _draft
      ..fullName = _nameCtrl.text.trim()
      ..phone = _phoneCtrl.text.trim()
      ..whatsapp = _whatsappCtrl.text.trim()
      ..email = _emailCtrl.text.trim()
      ..hasPhoto = _hasPhoto;
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.touch();
    notifier.next();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
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
                  TextFormField(
                    controller: _nameCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(hintText: 'Enter your full name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required.' : null,
                  ),
                  const SizedBox(height: 20),
                  _label('Phone Number'),
                  TextFormField(
                    controller: _phoneCtrl,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '059xxxxxxx'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required.' : null,
                  ),
                  const SizedBox(height: 20),
                  _label('WhatsApp Number (Optional)'),
                  TextField(
                    controller: _whatsappCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '059xxxxxxx'),
                  ),
                  const SizedBox(height: 20),
                  _label('Email (Optional)'),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'you@example.com'),
                  ),
                ],
              ),
            ),
          ),
        ),
        WizardBottomBar(primaryLabel: 'Next', onPrimary: _isValid ? _next : null),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(text, style: AppTextStyles.labelMd()),
      );
}
