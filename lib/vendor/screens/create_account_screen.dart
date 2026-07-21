import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/role_toggle.dart';
import '../widgets/social_buttons.dart';
import '../widgets/vendor_id_upload.dart';
import 'account_under_review_screen.dart';

/// Screen 3 — "registration_with_role_selection" export.
/// A full-page "Create Account" form with a User/Vendor pill toggle. When
/// "Vendor" is selected, a Business Verification upload section appears,
/// mirroring the conditional `#vendor-upload-section` in the HTML export.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  UserRole _role = UserRole.user;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  String? _uploadedFileName;

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final messenger = ScaffoldMessenger.of(context);
    if (!_agreedToTerms) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service and Privacy Policy.')),
      );
      return;
    }
    if (_role == UserRole.vendor) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AccountUnderReviewScreen()),
      );
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Account created (demo)')));
  }

  @override
  Widget build(BuildContext context) {
    final isVendor = _role == UserRole.vendor;

    return Scaffold(
      appBar: const AppTopBar(),
      bottomNavigationBar: AppBottomNav(
        isLoginActive: false,
        onLoginTap: () => Navigator.of(context).maybePop(),
        onRegisterTap: () {},
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create Account', style: AppTextStyles.headlineLgMobile()),
                  const SizedBox(height: 8),
                  Text(
                    'Join Evergreen Events to start planning your next professional gathering.',
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 32),
                  RoleTogglePill(selected: _role, onChanged: (r) => setState(() => _role = r)),
                  const SizedBox(height: 32),
                  LabeledTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.person,
                    controller: _fullNameCtrl,
                  ),
                  const SizedBox(height: 20),
                  LabeledTextField(
                    label: 'Email Address',
                    hint: 'email@example.com',
                    icon: Icons.mail,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  LabeledTextField(
                    label: 'Phone Number',
                    hint: '+1 (555) 000-0000',
                    icon: Icons.call,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  LabeledTextField(
                    label: 'Password',
                    hint: '••••••••',
                    icon: Icons.lock,
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    trailing: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.outlineVariant, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: isVendor
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: VendorIdUploadSection(
                              fileName: _uploadedFileName,
                              onUpload: () => setState(() => _uploadedFileName = 'business_license.pdf'),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.labelSm(),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(text: 'Terms of Service', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.w700)),
                                const TextSpan(text: ' and '),
                                TextSpan(text: 'Privacy Policy', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.w700)),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text('Register'),
                  ),
                  const OrDivider(),
                  Row(
                    children: [
                      Expanded(child: GoogleAuthButton(onPressed: () {})),
                      const SizedBox(width: 16),
                      Expanded(child: AppleAuthButton(onPressed: () {})),
                    ],
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
