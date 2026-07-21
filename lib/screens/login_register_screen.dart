import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../vendor/widgets/app_top_bar.dart';
import '../vendor/widgets/role_toggle.dart';
import '../vendor/widgets/social_buttons.dart';
import '../vendor/widgets/vendor_id_upload.dart';
import '../vendor/screens/account_under_review_screen.dart';
import '../user/user.dart';

/// Screen 1 — "login_registration" export.
/// A single card with a brand mark, a Login/Register tab switcher, and an
/// animated cross-fade + slide between the two forms.
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

enum _AuthMode { login, register }

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  _AuthMode _mode = _AuthMode.login;
  bool _obscureLoginPass = true;
  UserRole _regRole = UserRole.user;
  String? _uploadedFileName;

  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    super.dispose();
  }

  void _setMode(_AuthMode mode) => setState(() => _mode = mode);

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == _AuthMode.login;

    return Scaffold(
      appBar: const AppTopBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                children: [
                  _BrandMark(),
                  const SizedBox(height: 32),
                  _TabSwitcher(isLogin: isLogin, onChanged: _setMode),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: Offset(
                          child.key == const ValueKey('login') ? -0.08 : 0.08,
                          0,
                        ),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: isLogin ? _buildLoginForm() : _buildRegisterForm(),
                  ),
                  const OrDivider(),
                  GoogleAuthButton(onPressed: () {}),
                  const SizedBox(height: 16),
                  AppleAuthButton(onPressed: () {}),
                  const SizedBox(height: 32),
                  _SwitchPrompt(
                    isLogin: isLogin,
                    onTap: () => _setMode(
                      isLogin ? _AuthMode.register : _AuthMode.login,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(
          'Email Address',
          'name@company.com',
          _loginEmailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _field(
          'Password',
          '••••••••',
          _loginPassCtrl,
          obscure: _obscureLoginPass,
          suffix: IconButton(
            icon: Icon(
              _obscureLoginPass ? Icons.visibility_off : Icons.visibility,
              color: AppColors.outline,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscureLoginPass = !_obscureLoginPass),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.labelMd(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
          ),
          child: const Text('Log In'),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RoleTogglePill(
          selected: _regRole,
          onChanged: (r) => setState(() => _regRole = r),
        ),
        const SizedBox(height: 16),
        _field('Full Name', 'John Doe', _regNameCtrl),
        const SizedBox(height: 16),
        _field(
          'Email Address',
          'name@company.com',
          _regEmailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _field(
          'Phone Number',
          '+1 (555) 000-0000',
          _regPhoneCtrl,
          keyboardType: TextInputType.phone,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _regRole == UserRole.vendor
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: VendorIdUploadSection(
                    fileName: _uploadedFileName,
                    onUpload: () =>
                        setState(() => _uploadedFileName = 'work_id.jpg'),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
          ),
          child: const Text('Create Account'),
        ),
      ],
    );
  }

  void _handleRegister() {
    if (_regRole == UserRole.vendor) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AccountUnderReviewScreen()),
      );
      return;
    }
    _goToEventFlow();
  }

  void _handleLogin() {
    _goToEventFlow();
  }

  void _goToEventFlow() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const EventFlowHomeScreen()),
    );
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.forest, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        Text('Evergreen Events', style: AppTextStyles.headlineLgMobile()),
        const SizedBox(height: 8),
        Text(
          'Professional planning for sustainable experiences.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd(),
        ),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.isLogin, required this.onChanged});

  final bool isLogin;
  final ValueChanged<_AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tab('Login', isLogin, () => onChanged(_AuthMode.login)),
          ),
          Expanded(
            child: _tab(
              'Register',
              !isLogin,
              () => onChanged(_AuthMode.register),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.dflt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.dflt),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd(
            color: active
                ? AppColors.onPrimaryContainer
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SwitchPrompt extends StatefulWidget {
  const _SwitchPrompt({required this.isLogin, required this.onTap});

  final bool isLogin;
  final VoidCallback onTap;

  @override
  State<_SwitchPrompt> createState() => _SwitchPromptState();
}

class _SwitchPromptState extends State<_SwitchPrompt> {
  late TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = widget.onTap;
  }

  @override
  void didUpdateWidget(covariant _SwitchPrompt oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recognizer.onTap = widget.onTap;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.bodyMd(),
        children: [
          TextSpan(
            text: widget.isLogin
                ? "Don't have an account? "
                : 'Already have an account? ',
          ),
          TextSpan(
            text: widget.isLogin ? 'Register' : 'Log in',
            style: AppTextStyles.labelMd(color: AppColors.primary),
            recognizer: _recognizer,
          ),
        ],
      ),
    );
  }
}
