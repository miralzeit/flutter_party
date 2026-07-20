import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/user_profile_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'checklist_screen.dart';
import 'event_flow_home_screen.dart';
import 'profile_screen.dart';

const bool _skipProfileBackend = bool.fromEnvironment(
  'SKIP_PROFILE_BACKEND',
  defaultValue: false,
);
const bool _skipCreateEventBackend = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  var _isSaving = false;

  bool get _useLocalProfileData =>
      _skipProfileBackend || _skipCreateEventBackend;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _locationController = TextEditingController(text: profile.location);
    _bioController = TextEditingController(text: profile.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updated = UserProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (updated.fullName.isEmpty || updated.email.isEmpty) {
      _showMessage('Name and email are required.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final saved = _useLocalProfileData
          ? updated
          : await ref
                .read(userProfileApiServiceProvider)
                .updateProfile(updated);
      ref.read(userProfileProvider.notifier).state = saved;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDeactivate() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deactivate Account?'),
          content: const Text(
            'This will disable your account access. You can cancel and keep editing your profile.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('common.cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('common.deactivate_account')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            const _EditProfileHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back to Profile'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.eventMutedForeground,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Edit Profile',
                        style:
                            AppTextStyles.headlineLgMobile(
                              color: AppColors.eventBlack,
                            ).copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Update your personal details and account settings.',
                        style: AppTextStyles.bodyMd(
                          color: AppColors.eventMutedForeground,
                        ).copyWith(letterSpacing: 0),
                      ),
                      const SizedBox(height: 18),
                      const _PhotoCard(),
                      const SizedBox(height: 16),
                      _FormCard(
                        nameController: _nameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        locationController: _locationController,
                        bioController: _bioController,
                        isSaving: _isSaving,
                        onSave: _saveChanges,
                        onDeactivate: _confirmDeactivate,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _EditProfileBottomNav(),
    );
  }
}

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.eventBackground,
        border: Border(bottom: BorderSide(color: AppColors.eventBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.eventPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.park_rounded,
              color: AppColors.onPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Evergreen Events',
              style: AppTextStyles.headlineMd(
                color: AppColors.eventBlack,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.eventDarkIcon,
          ),
          const SizedBox(width: 4),
          const _UserAvatar(size: 38),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.eventMapGreen,
              shape: BoxShape.circle,
            ),
            child: const _UserAvatar(size: 102),
          ),
          const SizedBox(height: 13),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo picker coming soon.')),
              );
            },
            child: Text(
              'Change Profile Photo',
              style: AppTextStyles.labelMd(
                color: AppColors.eventBlack,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
          ),
          Text(
            'JPG, GIF or PNG. Max size 2MB.',
            style: AppTextStyles.labelSm(
              color: AppColors.eventMutedForeground,
            ).copyWith(letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.locationController,
    required this.bioController,
    required this.isSaving,
    required this.onSave,
    required this.onDeactivate,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController bioController;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileField(label: 'Full Name', controller: nameController),
          const SizedBox(height: 14),
          _ProfileField(
            label: 'Email Address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icons.edit_rounded,
            helperText: 'Verified on Oct 2023',
            helperItalic: true,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            label: 'Phone Number',
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            label: 'Primary Location',
            controller: locationController,
            suffixIcon: Icons.keyboard_arrow_down_rounded,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            label: 'Professional Bio',
            controller: bioController,
            maxLines: 5,
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.eventBorder),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onDeactivate,
              child: Text(
                'Deactivate Account',
                style: AppTextStyles.labelMd(
                  color: const Color(0xFFD34B4B),
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.eventPrimary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.onPrimary,
                        strokeWidth: 2.3,
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: AppTextStyles.labelMd(
                        color: AppColors.onPrimary,
                      ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.helperText,
    this.helperItalic = false,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? suffixIcon;
  final String? helperText;
  final bool helperItalic;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd(
            color: AppColors.eventBlack,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.bodyMd(
            color: AppColors.eventBlack,
          ).copyWith(fontSize: 15, letterSpacing: 0),
          decoration: InputDecoration(
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, color: AppColors.eventMutedForeground),
            filled: true,
            fillColor: AppColors.eventMutedBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.eventBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.eventBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.eventPrimary,
                width: 1.4,
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: AppTextStyles.labelSm(color: AppColors.eventMutedForeground)
                .copyWith(
                  fontStyle: helperItalic ? FontStyle.italic : FontStyle.normal,
                  letterSpacing: 0,
                ),
          ),
        ],
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFBFD8D1), Color(0xFF577C75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.onPrimary,
        size: size * 0.58,
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

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

class _EditProfileBottomNav extends ConsumerWidget {
  const _EditProfileBottomNav();

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
