import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/business.dart';
import '../../providers/business_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_pill.dart';
import '../shell/business_flow.dart';

enum _BusinessAction { rename, toggleActive, delete }

/// Full business management view opened from Settings > "Manage Businesses"
/// — unlike the Dashboard's switcher sheet (pick which business is active),
/// this one can rename, pause/reactivate, or permanently delete a business.
class ManageBusinessesScreen extends ConsumerWidget {
  const ManageBusinessesScreen({super.key});

  Future<void> _rename(BuildContext context, WidgetRef ref, Business business) async {
    final controller = TextEditingController(text: business.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Business'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Business name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      business.name = newName;
      ref.read(businessesProvider.notifier).touch();
    }
  }

  void _toggleActive(WidgetRef ref, Business business) {
    business.isPaused = !business.isPaused;
    ref.read(businessesProvider.notifier).touch();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Business business) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${business.name}?'),
        content: const Text('All services, packages, photos and information will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final wasActive = ref.read(activeBusinessIdProvider) == business.id;
    ref.read(businessesProvider.notifier).remove(business);
    if (wasActive) {
      final remaining = ref.read(businessesProvider);
      ref.read(activeBusinessIdProvider.notifier).state = remaining.isEmpty ? null : remaining.first.id;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Businesses'),
        actions: [
          IconButton(
            onPressed: () => startAddBusinessFlow(context, ref),
            icon: const Icon(Icons.add),
            tooltip: 'Add Business',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: businesses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('No businesses yet.', style: AppTextStyles.bodyMd()),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: businesses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final business = businesses[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Icon(businessCategoryIcon(business.category), color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(business.name, style: AppTextStyles.labelMd()),
                                  const SizedBox(height: 4),
                                  StatusPill(status: business.status),
                                ],
                              ),
                            ),
                            PopupMenuButton<_BusinessAction>(
                              icon: const Icon(Icons.more_vert, color: AppColors.outline),
                              onSelected: (action) {
                                switch (action) {
                                  case _BusinessAction.rename:
                                    _rename(context, ref, business);
                                  case _BusinessAction.toggleActive:
                                    _toggleActive(ref, business);
                                  case _BusinessAction.delete:
                                    _delete(context, ref, business);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: _BusinessAction.rename, child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Rename'))),
                                PopupMenuItem(
                                  value: _BusinessAction.toggleActive,
                                  child: ListTile(
                                    leading: Icon(business.isPaused ? Icons.play_circle_outline : Icons.pause_circle_outline),
                                    title: Text(business.isPaused ? 'Reactivate' : 'Deactivate'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: _BusinessAction.delete,
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                                    title: Text('Delete', style: TextStyle(color: AppColors.error)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
