import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/event_provider.dart';
import '../providers/security_provider.dart';
import '../services/security_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'checklist_screen.dart';
import 'event_flow_home_screen.dart';

const bool _skipSecurityBackend = bool.fromEnvironment(
  'SKIP_SECURITY_BACKEND',
  defaultValue: false,
);
const bool _skipCreateEventBackend = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _currentPasswordController = TextEditingController(text: 'password');
  final _newPasswordController = TextEditingController(text: 'newpassword');
  final _confirmPasswordController = TextEditingController(text: 'newpassword');
  var _authenticatorEnabled = true;
  var _smsEnabled = false;
  var _isUpdatingPassword = false;
  var _isUpdatingTwoFactor = false;
  var _isRevoking = false;

  bool get _useLocalSecurityData =>
      _skipSecurityBackend || _skipCreateEventBackend;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showMessage('New passwords do not match.');
      return;
    }
    setState(() => _isUpdatingPassword = true);
    try {
      if (!_useLocalSecurityData) {
        await ref
            .read(securityApiServiceProvider)
            .updatePassword(
              UpdatePasswordRequest(
                currentPassword: _currentPasswordController.text,
                newPassword: _newPasswordController.text,
                confirmPassword: _confirmPasswordController.text,
              ),
            );
      }
      if (!mounted) return;
      _showMessage('Password updated.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isUpdatingPassword = false);
    }
  }

  Future<void> _updateTwoFactor({bool? authenticator, bool? sms}) async {
    final previousAuthenticator = _authenticatorEnabled;
    final previousSms = _smsEnabled;
    setState(() {
      _authenticatorEnabled = authenticator ?? _authenticatorEnabled;
      _smsEnabled = sms ?? _smsEnabled;
      _isUpdatingTwoFactor = true;
    });
    try {
      if (!_useLocalSecurityData) {
        await ref
            .read(securityApiServiceProvider)
            .updateTwoFactor(
              authenticatorEnabled: _authenticatorEnabled,
              smsEnabled: _smsEnabled,
            );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _authenticatorEnabled = previousAuthenticator;
        _smsEnabled = previousSms;
      });
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isUpdatingTwoFactor = false);
    }
  }

  Future<void> _revokeSessions({String? sessionId}) async {
    setState(() => _isRevoking = true);
    try {
      if (!_useLocalSecurityData) {
        await ref
            .read(securityApiServiceProvider)
            .revokeSessions(sessionId: sessionId);
      }
      if (!mounted) return;
      _showMessage(
        sessionId == null ? 'Signed out all sessions.' : 'Session signed out.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isRevoking = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _SecurityHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      Text(
                        'Manage your account protection, authentication methods, and monitor active sessions.',
                        style: AppTextStyles.bodyMd(
                          color: AppColors.eventMutedForeground,
                        ).copyWith(letterSpacing: 0),
                      ),
                      const SizedBox(height: 16),
                      _PasswordCard(
                        currentController: _currentPasswordController,
                        newController: _newPasswordController,
                        confirmController: _confirmPasswordController,
                        isUpdating: _isUpdatingPassword,
                        onUpdate: _updatePassword,
                      ),
                      const SizedBox(height: 16),
                      _TwoFactorCard(
                        authenticatorEnabled: _authenticatorEnabled,
                        smsEnabled: _smsEnabled,
                        isUpdating: _isUpdatingTwoFactor,
                        onAuthenticatorChanged: (value) =>
                            _updateTwoFactor(authenticator: value),
                        onSmsChanged: (value) => _updateTwoFactor(sms: value),
                      ),
                      const SizedBox(height: 16),
                      _LoginActivityCard(
                        isRevoking: _isRevoking,
                        onRevokeAll: () => _revokeSessions(),
                        onRevokeSession: (sessionId) =>
                            _revokeSessions(sessionId: sessionId),
                      ),
                      const SizedBox(height: 16),
                      const _SecurityAuditCard(),
                      const SizedBox(height: 16),
                      const _DangerZoneCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _SecurityBottomNav(),
    );
  }
}

class _SecurityHeader extends StatelessWidget {
  const _SecurityHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.eventBackground,
      child: Column(
        children: [
          SizedBox(
            height: 58,
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.eventBlack,
                ),
                Expanded(
                  child: Text(
                    'Security Settings',
                    style: AppTextStyles.headlineMd(
                      color: AppColors.eventBlack,
                    ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                  color: AppColors.eventBlack,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.eventBorder),
        ],
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  const _PasswordCard({
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.isUpdating,
    required this.onUpdate,
  });

  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final bool isUpdating;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return _SecurityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.lock_rounded, title: 'Password'),
          const SizedBox(height: 14),
          _PasswordField(
            label: 'Current Password',
            controller: currentController,
          ),
          const SizedBox(height: 12),
          _PasswordField(label: 'New Password', controller: newController),
          const SizedBox(height: 12),
          _PasswordField(label: 'Confirm New', controller: confirmController),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: isUpdating ? null : onUpdate,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.eventPrimary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(isUpdating ? 'Updating...' : 'Update Password'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm(
            color: AppColors.eventDarkIcon,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.eventBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.eventBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.eventBorder),
            ),
          ),
        ),
      ],
    );
  }
}

class _TwoFactorCard extends StatelessWidget {
  const _TwoFactorCard({
    required this.authenticatorEnabled,
    required this.smsEnabled,
    required this.isUpdating,
    required this.onAuthenticatorChanged,
    required this.onSmsChanged,
  });

  final bool authenticatorEnabled;
  final bool smsEnabled;
  final bool isUpdating;
  final ValueChanged<bool> onAuthenticatorChanged;
  final ValueChanged<bool> onSmsChanged;

  @override
  Widget build(BuildContext context) {
    return _SecurityCard(
      child: Column(
        children: [
          const _CardTitle(
            icon: Icons.verified_user_rounded,
            title: 'Two-Factor Auth',
          ),
          const SizedBox(height: 14),
          _SwitchRow(
            title: 'Authenticator App',
            subtitle:
                'Use Google Authenticator or Authy to generate secure codes.',
            value: authenticatorEnabled,
            onChanged: isUpdating ? null : onAuthenticatorChanged,
          ),
          const Divider(height: 24, color: AppColors.eventBorder),
          _SwitchRow(
            title: 'SMS Verification',
            subtitle:
                'Receive login codes via text to your phone number ending in **82.',
            value: smsEnabled,
            onChanged: isUpdating ? null : onSmsChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMd(
                  color: AppColors.eventBlack,
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.labelSm(
                  color: AppColors.eventMutedForeground,
                ).copyWith(letterSpacing: 0),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.eventPrimary,
          activeTrackColor: AppColors.eventSelectedBackground,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LoginActivityCard extends StatelessWidget {
  const _LoginActivityCard({
    required this.isRevoking,
    required this.onRevokeAll,
    required this.onRevokeSession,
  });

  final bool isRevoking;
  final VoidCallback onRevokeAll;
  final ValueChanged<String> onRevokeSession;

  @override
  Widget build(BuildContext context) {
    const sessions = [
      _SessionData(
        'current',
        'MacBook Pro 16"',
        'San Francisco, CA • Chrome Browser',
        true,
      ),
      _SessionData(
        'iphone',
        'iPhone 15 Pro',
        'San Francisco, CA • Evergreen App • 2h ago',
        false,
      ),
      _SessionData(
        'ipad',
        'iPad Air',
        'Los Angeles, CA • Safari • Dec 12, 2023',
        false,
      ),
    ];

    return _SecurityCard(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _CardTitle(
                  icon: Icons.devices_rounded,
                  title: 'Login Activity',
                ),
              ),
              TextButton(
                onPressed: isRevoking ? null : onRevokeAll,
                child: Text(
                  'Sign out all',
                  style: AppTextStyles.labelSm(
                    color: AppColors.eventMutedForeground,
                  ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < sessions.length; index++) ...[
            _SessionRow(
              session: sessions[index],
              onRevoke: sessions[index].isCurrent || isRevoking
                  ? null
                  : () => onRevokeSession(sessions[index].id),
            ),
            if (index != sessions.length - 1)
              const Divider(height: 1, color: AppColors.eventBorder),
          ],
        ],
      ),
    );
  }
}

class _SessionData {
  const _SessionData(this.id, this.device, this.details, this.isCurrent);

  final String id;
  final String device;
  final String details;
  final bool isCurrent;
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.onRevoke});

  final _SessionData session;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.eventMutedBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.computer_rounded,
              color: AppColors.eventPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.device,
                  style: AppTextStyles.labelMd(
                    color: AppColors.eventBlack,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
                const SizedBox(height: 3),
                Text(
                  session.details,
                  style: AppTextStyles.labelSm(
                    color: AppColors.eventMutedForeground,
                  ).copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
          if (session.isCurrent) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.eventPrimary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'CURRENT',
                style: AppTextStyles.labelSm(color: AppColors.onPrimary)
                    .copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            const SizedBox(width: 7),
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.eventAccent,
              size: 19,
            ),
          ] else
            IconButton(
              onPressed: onRevoke,
              icon: const Icon(Icons.more_horiz_rounded),
              color: AppColors.eventMutedForeground,
            ),
        ],
      ),
    );
  }
}

class _SecurityAuditCard extends StatelessWidget {
  const _SecurityAuditCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.eventPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: AppColors.onPrimary,
              ),
              const SizedBox(width: 9),
              Text(
                'Security Audit',
                style: AppTextStyles.labelMd(
                  color: AppColors.onPrimary,
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your current security score is 85%. To reach 100%, we recommend enabling SMS backup and updating your recovery email.',
            style: AppTextStyles.bodyMd(
              color: AppColors.eventSoftText,
            ).copyWith(fontSize: 14, letterSpacing: 0),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: 0.85,
              backgroundColor: AppColors.onPrimary.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.eventSelectedBackground,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.onPrimary,
                foregroundColor: AppColors.eventPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                'Improve My Score',
                style: AppTextStyles.labelMd(
                  color: AppColors.eventPrimary,
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFE46A6A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD34B4B)),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: AppTextStyles.labelMd(
                  color: const Color(0xFFD34B4B),
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Deactivate Account',
            style: AppTextStyles.labelMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
          const SizedBox(height: 6),
          Text(
            'Temporarily disable your account. Your profile and events will be hidden from the community until you reactivate.',
            style: AppTextStyles.labelSm(
              color: AppColors.eventMutedForeground,
            ).copyWith(letterSpacing: 0),
          ),
          const SizedBox(height: 13),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD34B4B),
              side: const BorderSide(color: Color(0xFFD34B4B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(context.tr('common.deactivate_account')),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.eventPrimary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
        ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.eventBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SecurityBottomNav extends ConsumerWidget {
  const _SecurityBottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(activeEventProvider);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
        decoration: const BoxDecoration(
          color: AppColors.eventBackground,
          border: Border(top: BorderSide(color: AppColors.eventBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: context.tr('nav.home'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const EventFlowHomeScreen(),
                  ),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.chat_bubble_rounded,
              label: context.tr('nav.chat'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.fact_check_rounded,
              label: context.tr('nav.checklist'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ChecklistScreen(
                      eventName: activeEvent?.eventName ?? 'Evergreen Events',
                    ),
                  ),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
              label: context.tr('nav.profile'),
              active: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.eventPrimary
        : AppColors.eventMutedForeground;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.eventSelectedBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm(color: color).copyWith(
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
