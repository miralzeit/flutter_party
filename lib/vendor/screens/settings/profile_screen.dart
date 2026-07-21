import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vendor.dart';
import '../../providers/business_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../login_register_screen.dart';
import '../set_up_profile_screen.dart';
import 'change_password_screen.dart';
import 'language_settings_screen.dart';
import 'manage_businesses_screen.dart';

/// Tab 4 — "Profile". Everything known about the vendor — the full personal
/// profile entered during onboarding, not just account-level controls — plus
/// businesses, app settings, security and account actions, as a grouped list.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    // Profile lives inside the shell's nested tab Navigator, so the reset must
    // target the ROOT navigator — otherwise login is pushed *inside* the shell
    // and the shell's bottom NavigationBar stays on screen, overlapping it.
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
      (route) => false,
    );
  }

  void _editProfile(Vendor? vendor) {
    if (vendor == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SetUpProfileScreen(initial: vendor)));
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider);
    final businesses = ref.watch(businessesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              children: [
                _profileHeader(vendor),
                const SizedBox(height: 20),
                _sectionLabel('Personal Information'),
                _infoCard(vendor),
                const SizedBox(height: 12),
                _sectionLabel('Businesses'),
                _card([
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                    title: Text('Manage Businesses', style: AppTextStyles.labelMd()),
                    subtitle: Text('${businesses.length} business${businesses.length == 1 ? '' : 'es'}', style: AppTextStyles.bodyMd()),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageBusinessesScreen())),
                  ),
                ]),
                const SizedBox(height: 12),
                _sectionLabel('App Settings'),
                _card([
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                    title: Text('Notifications', style: AppTextStyles.labelMd()),
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                  const Divider(height: 1),
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
                ]),
                const SizedBox(height: 12),
                _sectionLabel('Security'),
                _card([
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                    title: Text('Change Password', style: AppTextStyles.labelMd()),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                  ),
                ]),
                const SizedBox(height: 12),
                _sectionLabel('Account Actions'),
                _card([
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.onSurface),
                    title: Text('Log Out', style: AppTextStyles.labelMd()),
                    onTap: _logout,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.delete_forever_outlined, color: AppColors.error),
                    title: Text('Delete Account', style: AppTextStyles.labelMd(color: AppColors.error)),
                    onTap: _deleteAccount,
                  ),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileHeader(Vendor? vendor) {
    final name = vendor?.fullName.isNotEmpty == true ? vendor!.fullName : 'Your Name';
    final bio = vendor?.bio.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: AppColors.surfaceContainerLowest, shape: BoxShape.circle),
            child: Icon(
              vendor?.hasPhoto == true ? Icons.check_circle : Icons.person,
              color: vendor?.hasPhoto == true ? AppColors.tertiary : AppColors.outline,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headlineMd()),
                const SizedBox(height: 4),
                Text(
                  bio.isNotEmpty ? bio : 'No bio added yet.',
                  style: AppTextStyles.bodyMd(color: bio.isNotEmpty ? AppColors.onSurfaceVariant : AppColors.outline),
                ),
                if (vendor?.city.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text(vendor!.city, style: AppTextStyles.labelSm()),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: vendor == null ? null : () => _editProfile(vendor),
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }

  Widget _infoCard(Vendor? vendor) {
    return _card([
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            _infoRow(Icons.badge_outlined, 'Full Name', vendor?.fullName ?? ''),
            _infoRow(Icons.email_outlined, 'Email', vendor?.email ?? ''),
            _infoRow(Icons.call_outlined, 'Phone', vendor?.phone ?? ''),
            _infoRow(Icons.chat_outlined, 'WhatsApp', vendor?.whatsapp ?? ''),
            _infoRow(Icons.location_city_outlined, 'City', vendor?.city ?? ''),
            _infoRow(Icons.info_outline, 'Bio', vendor?.bio ?? '', isLast: true),
          ],
        ),
      ),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value, {bool isLast = false}) {
    final hasValue = value.trim().isNotEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.labelSm()),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? value : 'Not added',
                      style: AppTextStyles.bodyMd(color: hasValue ? AppColors.onSurface : AppColors.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Text(text, style: AppTextStyles.labelSm(color: AppColors.primary)),
      );
}
