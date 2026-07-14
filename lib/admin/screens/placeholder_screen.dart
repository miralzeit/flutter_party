import 'package:flutter/material.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';

/// Shared body for the sidebar destinations the spec lists in the IA but
/// never details (Checklists, Broadcast, Settings) — kept as a plain
/// "coming soon" stub rather than inventing unrequested functionality.
class AdminPlaceholderScreen extends StatelessWidget {
  const AdminPlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AdminColors.outline),
            const SizedBox(height: 12),
            Text('$title is coming soon.', style: AdminTextStyles.bodyLg()),
          ],
        ),
      ),
    );
  }
}

class ChecklistsPlaceholderScreen extends StatelessWidget {
  const ChecklistsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) => const AdminPlaceholderScreen(title: 'Checklists', icon: Icons.checklist_outlined);
}

class BroadcastPlaceholderScreen extends StatelessWidget {
  const BroadcastPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) => const AdminPlaceholderScreen(title: 'Broadcast', icon: Icons.campaign_outlined);
}

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const AdminPlaceholderScreen(title: 'Settings', icon: Icons.settings_outlined);
}
