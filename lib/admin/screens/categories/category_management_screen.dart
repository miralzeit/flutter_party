import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin_category.dart';
import '../../providers/admin_providers.dart';
import '../../theme/admin_colors.dart';
import '../../theme/admin_text_styles.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_empty_state.dart';
import 'add_edit_category_screen.dart';

/// Screen — "Category Management". The taxonomy shown in search filters and
/// listing forms platform-wide: reorderable, each togglable active/inactive,
/// with an Add/Edit form (§5.6) for the rest.
class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {AdminCategory? initial}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditCategoryScreen(initial: initial)),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved successfully.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = [...ref.watch(categoriesProvider)]..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AdminSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Main Categories', style: AdminTextStyles.headlineMd()),
            const SizedBox(height: 4),
            Text('Drag to reorder. Order determines position in the public menu.', style: AdminTextStyles.bodyMd()),
            const SizedBox(height: 16),
            Expanded(
              child: categories.isEmpty
                  ? const AdminEmptyState(icon: Icons.category_outlined, message: 'No categories yet.')
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: categories.length,
                      onReorder: (oldIndex, newIndex) => ref.read(categoriesProvider.notifier).reorder(oldIndex, newIndex),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Container(
                          key: ValueKey(category.id),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AdminColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AdminRadius.sm),
                            border: Border.all(color: AdminColors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              ReorderableDragHandle(index: index, child: const Icon(Icons.drag_indicator, color: AdminColors.outline)),
                              const SizedBox(width: 12),
                              Icon(iconForKey(category.icon), color: AdminColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(category.name, style: AdminTextStyles.labelMd()),
                                    if (category.description.isNotEmpty)
                                      Text(category.description, style: AdminTextStyles.labelSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _openForm(context, ref, initial: category),
                              ),
                              Switch(
                                value: category.isActive,
                                activeThumbColor: AdminColors.tertiary,
                                onChanged: (_) => ref.read(categoriesProvider.notifier).toggleActive(category.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [ReorderableListView] requires its drag handle to come from
/// [ReorderableDragStartListener] when not dragging the whole row (here we
/// want the checkbox/switch/edit button to stay tappable, so only the
/// handle icon initiates the drag).
class ReorderableDragHandle extends StatelessWidget {
  const ReorderableDragHandle({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => ReorderableDragStartListener(index: index, child: child);
}
