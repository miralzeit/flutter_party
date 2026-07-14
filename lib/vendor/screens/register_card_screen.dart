import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/role_toggle.dart';
import '../widgets/social_buttons.dart';

/// Screen 2 — "user_registration" export.
/// A hero banner + a single elevated card containing a Login/Register tab
/// row (registration selected), a User/Vendor role card selector, and the
/// registration form.
class RegisterCardScreen extends StatefulWidget {
  const RegisterCardScreen({super.key});

  @override
  State<RegisterCardScreen> createState() => _RegisterCardScreenState();
}

class _RegisterCardScreenState extends State<RegisterCardScreen> {
  UserRole _role = UserRole.user;
  bool _obscurePassword = true;

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

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                children: [
                  _HeroBanner(),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _MiniTabs(),
                        const SizedBox(height: 32),
                        RoleToggleCard(selected: _role, onChanged: (r) => setState(() => _role = r)),
                        const SizedBox(height: 24),
                        LabeledTextField(
                          label: 'Full Name',
                          hint: 'John Doe',
                          icon: Icons.badge,
                          controller: _fullNameCtrl,
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Email Address',
                          hint: 'john@example.com',
                          icon: Icons.mail,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Phone Number',
                          hint: '+1 (555) 000-0000',
                          icon: Icons.call,
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        LabeledTextField(
                          label: 'Password',
                          hint: '••••••••••••',
                          icon: Icons.lock,
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          trailing: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.outline, size: 20),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Register'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                        const OrDivider(label: 'Or connect with'),
                        Row(
                          children: [
                            Expanded(child: GoogleAuthButton(onPressed: () {})),
                            const SizedBox(width: 16),
                            Expanded(child: AppleAuthButton(onPressed: () {})),
                          ],
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.labelSm(),
                            children: [
                              const TextSpan(text: 'By registering, you agree to our '),
                              TextSpan(text: 'Terms of Service', style: AppTextStyles.labelSm(color: AppColors.primary)),
                              const TextSpan(text: ' and '),
                              TextSpan(text: 'Privacy Policy', style: AppTextStyles.labelSm(color: AppColors.primary)),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ],
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
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Join Evergreen', style: AppTextStyles.headlineLgMobile(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Plan, manage, and execute flawless events with professional precision.',
            style: AppTextStyles.bodyMd(color: AppColors.onPrimaryContainer.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

class _MiniTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Login', textAlign: TextAlign.center, style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.dflt),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              child: Text('Register', textAlign: TextAlign.center, style: AppTextStyles.labelMd(color: AppColors.onPrimaryContainer)),
            ),
          ),
        ],
      ),
    );
  }
}
