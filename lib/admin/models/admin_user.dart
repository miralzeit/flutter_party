/// A signed-in admin-panel user. Only one role exists in v1 — a future
/// role like "moderator" (limited to Reviews only) is out of scope for now.
class AdminUser {
  AdminUser({required this.id, required this.name, required this.email, this.role = 'platform_superuser', this.avatarUrl});

  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  String get roleLabel => role
      .split('_')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
