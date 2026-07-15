import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../analytics_screen.dart';
import '../dashboard_screen.dart';
import '../services_screen.dart';
import '../settings/profile_screen.dart';

/// Persistent bottom-nav shell: four tabs, each with its own nested
/// [Navigator] kept alive inside an [IndexedStack] so switching tabs never
/// loses the other tabs' navigation stacks. No router package — plain
/// Navigator.push everywhere, matching the rest of the app.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  static const _railBreakpoint = 840.0;
  int _index = 0;

  final _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  static const _tabs = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    (Icons.inventory_2_outlined, Icons.inventory_2, 'Services'),
    (Icons.analytics_outlined, Icons.analytics, 'Analytics'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  Widget _tabNavigator(int index, Widget root) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => root),
    );
  }

  Future<void> _onWillPop() async {
    final currentTabNavigator = _navigatorKeys[_index].currentState;
    if (currentTabNavigator != null && currentTabNavigator.canPop()) {
      currentTabNavigator.pop();
    } else if (_index != 0) {
      setState(() => _index = 0);
    }
  }

  void _selectTab(int tapped) {
    if (tapped == _index) {
      _navigatorKeys[tapped].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _index = tapped);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onWillPop();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = IndexedStack(
            index: _index,
            children: [
              _tabNavigator(0, const DashboardScreen()),
              _tabNavigator(1, const ServicesPackagesScreen()),
              _tabNavigator(2, const AnalyticsScreen()),
              _tabNavigator(3, const ProfileScreen()),
            ],
          );
          final useRail = constraints.maxWidth >= _railBreakpoint;

          return Scaffold(
            body: useRail
                ? Row(
                    children: [
                      SafeArea(
                        child: NavigationRail(
                          selectedIndex: _index,
                          onDestinationSelected: _selectTab,
                          labelType: NavigationRailLabelType.all,
                          leading: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryContainer,
                              child: const Icon(Icons.event_available, color: AppColors.onPrimaryContainer),
                            ),
                          ),
                          destinations: [
                            for (final tab in _tabs)
                              NavigationRailDestination(
                                icon: Icon(tab.$1),
                                selectedIcon: Icon(tab.$2),
                                label: Text(tab.$3),
                              ),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: content),
                    ],
                  )
                : content,
            bottomNavigationBar: useRail
                ? null
                : NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: _selectTab,
                    destinations: [
                      for (final tab in _tabs)
                        NavigationDestination(
                          icon: Icon(tab.$1),
                          selectedIcon: Icon(tab.$2),
                          label: tab.$3,
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
