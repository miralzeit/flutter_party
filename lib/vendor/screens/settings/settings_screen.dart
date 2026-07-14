import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/business_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../login_register_screen.dart';
import '../set_up_profile_screen.dart';
import 'change_password_screen.dart';
import 'language_settings_screen.dart';
import 'manage_businesses_screen.dart';

/// Tab 4 — "Settings". Everything the vendor entered during registration
/// plus account-level controls, as a grouped list — not a form.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'English';

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Log Out')),
        ],
      ),
    );
    if (confirmed == true) _resetAndGoToLogin();
  }

  void _deleteAccount() async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: TextStyle(color: AppColors.error)),
        content: const Text(
          'This permanently deletes your account, all businesses, services and packages. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Continue', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (firstConfirm != true || !mounted) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you absolutely sure?', style: TextStyle(color: AppColors.error)),
        content: const Text('Type nothing needed for this demo — confirming here deletes your account immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete My Account', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (secondConfirm == true) _resetAndGoToLogin();
  }

  void _resetAndGoToLogin() {
    ref.read(vendorProvider.notifier).state = null;
    ref.read(businessesProvider.notifier).clear();
    ref.read(activeBusinessIdProvider.notifier).state = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider);
    final businesses = ref.watch(businessesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              children: [
                _sectionLabel('Account'),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: AppColors.surfaceContainerLow, shape: BoxShape.circle),
                    child: Icon(vendor?.hasPhoto == true ? Icons.check_circle : Icons.person, color: AppColors.outline),
                  ),
                  title: Text(vendor?.fullName.isNotEmpty == true ? vendor!.fullName : 'Your Name', style: AppTextStyles.labelMd()),
                  subtitle: Text(
                    [
                      if (vendor?.phone.isNotEmpty == true) vendor!.phone,
                      if (vendor?.whatsapp.isNotEmpty == true) 'WhatsApp: ${vendor!.whatsapp}',
                      if (vendor?.email.isNotEmpty == true) vendor!.email,
                    ].join(' · '),
                    style: AppTextStyles.bodyMd(),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                  onTap: vendor == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SetUpProfileScreen(initial: vendor)),
                          ),
                ),
                const Divider(),
                _sectionLabel('Businesses'),
                ListTile(
                  leading: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                  title: Text('Manage Businesses', style: AppTextStyles.labelMd()),
                  subtitle: Text('${businesses.length} business${businesses.length == 1 ? '' : 'es'}', style: AppTextStyles.bodyMd()),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageBusinessesScreen())),
                ),
                const Divider(),
                _sectionLabel('App Settings'),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                  title: Text('Notifications', style: AppTextStyles.labelMd()),
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined, color: AppColors.primary),
                  title: Text('Language', style: AppTextStyles.labelMd()),
                  subtitle: Text(_language, style: AppTextStyles.bodyMd()),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                  onTap: () async {
                    final selected = await Navigator.of(context).push<String>(
                      MaterialPageRoute(builder: (_) => LanguageSettingsScreen(current: _language)),
                    );
                    if (selected != null) setState(() => _language = selected);
                  },
                ),
                const Divider(),
                _sectionLabel('Security'),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                  title: Text('Change Password', style: AppTextStyles.labelMd()),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                ),
                const Divider(),
                _sectionLabel('Account Actions'),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.onSurface),
                  title: Text('Log Out', style: AppTextStyles.labelMd()),
                  onTap: _logout,
                ),
                ListTile(
                  leading: Icon(Icons.delete_forever_outlined, color: AppColors.error),
                  title: Text('Delete Account', style: AppTextStyles.labelMd(color: AppColors.error)),
                  onTap: _deleteAccount,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text, style: AppTextStyles.labelSm(color: AppColors.primary)),
      );
}
