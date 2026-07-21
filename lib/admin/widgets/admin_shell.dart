import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/admin_providers.dart';
import '../screens/analytics/analytics_home_screen.dart';
import '../screens/categories/category_management_screen.dart';
import '../screens/overview_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/reviews/review_moderation_screen.dart';
import '../screens/vendors/vendors_screen.dart';
import '../theme/admin_colors.dart';
import '../theme/admin_text_styles.dart';
import '../theme/admin_theme.dart';
import 'admin_menu_button.dart';
import 'confirm_dialog.dart';

const _navItems = [
  (AdminSection.overview, Icons.dashboard_outlined, Icons.dashboard, 'Overview'),
  (AdminSection.vendors, Icons.storefront_outlined, Icons.storefront, 'Vendors'),
  (AdminSection.categories, Icons.category_outlined, Icons.category, 'Categories'),
  (AdminSection.reviews, Icons.star_outline, Icons.star, 'Reviews'),
  (AdminSection.analytics, Icons.analytics_outlined, Icons.analytics, 'Analytics'),
  (AdminSection.checklists, Icons.checklist_outlined, Icons.checklist, 'Checklists'),
  (AdminSection.broadcast, Icons.campaign_outlined, Icons.campaign, 'Broadcast'),
  (AdminSection.settings, Icons.settings_outlined, Icons.settings, 'Settings'),
];

/// Persistent left sidebar (docked at [kAdminSidebarBreakpoint]+, collapsing
/// to a top bar + drawer below it) present on every admin screen. Each
/// destination keeps its own nested [Navigator] — matching the vendor app's
/// tab-shell convention — so pushed sub-screens (e.g. Application Detail)
/// don't lose the other sections' state.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  final _navigatorKeys = {for (final item in _navItems) item.$1: GlobalKey<NavigatorState>()};
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _roots = <AdminSection, Widget>{
    AdminSection.overview: OverviewScreen(),
    AdminSection.vendors: VendorsScreen(),
    AdminSection.categories: CategoryManagementScreen(),
    AdminSection.reviews: ReviewModerationScreen(),
    AdminSection.analytics: AnalyticsHomeScreen(),
    AdminSection.checklists: ChecklistsPlaceholderScreen(),
    AdminSection.broadcast: BroadcastPlaceholderScreen(),
    AdminSection.settings: AdminSettingsScreen(),
  };

  Widget _tabNavigator(AdminSection section) {
    return Navigator(
      key: _navigatorKeys[section],
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => _roots[section]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(adminSectionProvider);
    final content = IndexedStack(
      index: AdminSection.values.indexOf(section),
      children: [for (final item in _navItems) _tabNavigator(item.$1)],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kAdminSidebarBreakpoint;
        if (isWide) {
          return Scaffold(
            body: AdminDrawerScope(
              openDrawer: null,
              child: Row(
                children: [
                  const _AdminSidebar(),
                  const VerticalDivider(width: 1, color: AdminColors.outlineVariant),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }
        // Narrow layout: the shell owns only the drawer — each section renders
        // its own AppBar with a menu button (via [AdminMenuButton]), so there's
        // never a second bar stacked on top of it.
        return Scaffold(
          key: _scaffoldKey,
          drawer: const Drawer(child: _AdminSidebar(inDrawer: true)),
          body: AdminDrawerScope(
            openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            child: content,
          ),
        );
      },
    );
  }
}

class _AdminSidebar extends ConsumerWidget {
  const _AdminSidebar({this.inDrawer = false});

  final bool inDrawer;

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of the admin panel?',
      confirmLabel: 'Sign Out',
      destructive: false,
    );
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out (demo).')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(adminSectionProvider);
    final admin = ref.watch(currentAdminProvider);

    return Container(
      width: inDrawer ? null : 240,
      color: AdminColors.primary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.event_available, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text('EventPro', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final item in _navItems)
                    _NavTile(
                      icon: item.$2,
                      activeIcon: item.$3,
                      label: item.$4,
                      selected: section == item.$1,
                      onTap: () {
                        ref.read(adminSectionProvider.notifier).state = item.$1;
                        if (inDrawer) Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Text(admin.name.isEmpty ? '?' : admin.name[0], style: AdminTextStyles.labelMd(color: Colors.white)),
              ),
              title: Text(admin.name, style: AdminTextStyles.labelMd(color: Colors.white), overflow: TextOverflow.ellipsis),
              subtitle: Text(admin.roleLabel, style: AdminTextStyles.labelSm(color: Colors.white70)),
            ),
            InkWell(
              onTap: () => _signOut(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.white70, size: 18),
                    const SizedBox(width: 12),
                    Text('Sign Out', style: AdminTextStyles.bodyMd(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.activeIcon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AdminColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(AdminRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AdminRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(selected ? activeIcon : icon, color: Colors.white, size: 20),
                const SizedBox(width: 14),
                Text(label, style: AdminTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
