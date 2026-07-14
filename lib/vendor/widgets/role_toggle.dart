import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

enum UserRole { user, vendor }

/// Segmented "Register as User / Vendor" control used on the registration
/// screens. Two visual variants match the two Stitch exports:
/// - [RoleToggleCard]: two bordered cards with icon + label (user_registration)
/// - [RoleTogglePill]: a pill-style segmented switch (registration_with_role_selection)
class RoleToggleCard extends StatelessWidget {
  const RoleToggleCard({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('I am signing up as a...', style: AppTextStyles.labelMd(color: AppColors.outline)),
        ),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                icon: Icons.person,
                label: 'User',
                active: selected == UserRole.user,
                onTap: () => onChanged(UserRole.user),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RoleCard(
                icon: Icons.storefront,
                label: 'Vendor',
                active: selected == UserRole.vendor,
                onTap: () => onChanged(UserRole.vendor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outlineVariant,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.outline),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelMd(color: active ? AppColors.primary : AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleTogglePill extends StatelessWidget {
  const RoleTogglePill({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text('Register as', style: AppTextStyles.labelMd()),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(child: _PillOption(label: 'User', active: selected == UserRole.user, onTap: () => onChanged(UserRole.user))),
              Expanded(child: _PillOption(label: 'Vendor', active: selected == UserRole.vendor, onTap: () => onChanged(UserRole.vendor))),
            ],
          ),
        ),
      ],
    );
  }
}

class _PillOption extends StatelessWidget {
  const _PillOption({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.dflt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.dflt),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd(
            color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
