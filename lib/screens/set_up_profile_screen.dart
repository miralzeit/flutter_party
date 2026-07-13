import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/photo_upload.dart';
import 'my_businesses_screen.dart';

/// Screen 4 — "Set Up Your Profile". Shown once after a vendor's account
/// clears verification, before they can start adding businesses.
class SetUpProfileScreen extends StatefulWidget {
  const SetUpProfileScreen({super.key});

  @override
  State<SetUpProfileScreen> createState() => _SetUpProfileScreenState();
}

class _SetUpProfileScreenState extends State<SetUpProfileScreen> {
  final _fullNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  bool _hasPhoto = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (_fullNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'my_businesses'),
        builder: (_) => const MyBusinessesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Your Profile')),
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
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                    child: const Text('Continue'),
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
