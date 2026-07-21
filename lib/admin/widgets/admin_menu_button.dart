import 'package:flutter/material.dart';

/// Exposes the [AdminShell]'s drawer opener down the tree so each section's
/// own AppBar can render a hamburger in the narrow (drawer) layout — avoiding
/// a second, redundant shell-level AppBar stacked on top of the screen's.
///
/// In the wide (docked-sidebar) layout no drawer exists, so [openDrawer] is
/// null and [AdminMenuButton.of] returns null — the AppBar then shows its
/// title with no menu affordance.
class AdminDrawerScope extends InheritedWidget {
  const AdminDrawerScope({super.key, required this.openDrawer, required super.child});

  final VoidCallback? openDrawer;

  static VoidCallback? _openerOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdminDrawerScope>()?.openDrawer;

  @override
  bool updateShouldNotify(AdminDrawerScope oldWidget) => oldWidget.openDrawer != openDrawer;
}

/// Leading widget for a root section's AppBar: a menu button when the shell is
/// in drawer mode, or null (no leading) when the sidebar is docked. Assign
/// directly to `AppBar(leading: AdminMenuButton.of(context))`.
class AdminMenuButton {
  const AdminMenuButton._();

  static Widget? of(BuildContext context) {
    final open = AdminDrawerScope._openerOf(context);
    if (open == null) return null;
    return IconButton(icon: const Icon(Icons.menu), tooltip: 'Menu', onPressed: open);
  }
}
