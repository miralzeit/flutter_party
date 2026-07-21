import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/role_toggle.dart';
import '../widgets/social_buttons.dart';
import '../widgets/vendor_id_upload.dart';
import 'account_under_review_screen.dart';

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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7FBFA), Color(0xFFE8F1F0)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final panel = _authPanel(isLogin);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.all(isWide ? 32 : 20),
                    child: isWide
                        ? Row(
                            children: [
                              const Expanded(flex: 11, child: _AuthHero()),
                              const SizedBox(width: 64),
                              SizedBox(width: 448, child: panel),
                            ],
                          )
                        : SizedBox(width: 480, child: panel),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _authPanel(bool isLogin) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: .55),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .12),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'EventPro',
                  style: AppTextStyles.headlineMd(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Text(
              isLogin ? 'Welcome back' : 'Create your account',
              style: AppTextStyles.headlineLg(),
            ),
            const SizedBox(height: 8),
            Text(
              isLogin
                  ? 'Sign in to manage exceptional event experiences.'
                  : 'Join a more thoughtful way to plan and discover events.',
              style: AppTextStyles.bodyMd(),
            ),
            const SizedBox(height: 28),
            _TabSwitcher(isLogin: isLogin, onChanged: _setMode),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                final offset =
                    Tween<Offset>(
                      begin: Offset(
                        child.key == const ValueKey('login') ? -0.06 : 0.06,
                        0,
                      ),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: isLogin ? _buildLoginForm() : _buildRegisterForm(),
            ),
            const OrDivider(),
            GoogleAuthButton(onPressed: () {}),
            const SizedBox(height: 12),
            AppleAuthButton(onPressed: () {}),
            const SizedBox(height: 28),
            _SwitchPrompt(
              isLogin: isLogin,
              onTap: () =>
                  _setMode(isLogin ? _AuthMode.register : _AuthMode.login),
            ),
          ],
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
          prefix: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _field(
          'Password',
          '••••••••',
          _loginPassCtrl,
          prefix: Icons.lock_outline_rounded,
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
          onPressed: () {},
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
        _field(
          'Full Name',
          'John Doe',
          _regNameCtrl,
          prefix: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _field(
          'Email Address',
          'name@company.com',
          _regEmailCtrl,
          prefix: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _field(
          'Phone Number',
          '+1 (555) 000-0000',
          _regPhoneCtrl,
          prefix: Icons.phone_outlined,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account created (demo)')));
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    Widget? suffix,
    IconData? prefix,
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix == null
                ? null
                : Icon(prefix, color: AppColors.primary),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Events, made\nexceptional.',
            style: AppTextStyles.displayLg(color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text(
            'A refined workspace for event professionals who care about every detail.',
            style: AppTextStyles.bodyLg(),
          ),
          const SizedBox(height: 36),
          const _HeroPoint(
            icon: Icons.insights_rounded,
            label: 'See your business at a glance',
          ),
          const SizedBox(height: 18),
          const _HeroPoint(
            icon: Icons.verified_user_outlined,
            label: 'Build trust with a complete profile',
          ),
          const SizedBox(height: 18),
          const _HeroPoint(
            icon: Icons.bolt_rounded,
            label: 'Move from idea to action, faster',
          ),
        ],
      ),
    );
  }
}

class _HeroPoint extends StatelessWidget {
  const _HeroPoint({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.tertiary),
      const SizedBox(width: 12),
      Text(label, style: AppTextStyles.labelMd()),
    ],
  );
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
