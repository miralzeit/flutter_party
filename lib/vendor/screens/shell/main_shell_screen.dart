import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../analytics_screen.dart';
import '../dashboard_screen.dart';
import '../services_screen.dart';
import '../settings/settings_screen.dart';

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
  int _index = 0;

  final _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  static const _tabs = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    (Icons.inventory_2_outlined, Icons.inventory_2, 'Services'),
    (Icons.analytics_outlined, Icons.analytics, 'Analytics'),
    (Icons.settings_outlined, Icons.settings, 'Settings'),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            _tabNavigator(0, const DashboardScreen()),
            _tabNavigator(1, const ServicesPackagesScreen()),
            _tabNavigator(2, const AnalyticsScreen()),
            _tabNavigator(3, const SettingsScreen()),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.outline,
          onTap: (tapped) {
            if (tapped == _index) {
              _navigatorKeys[tapped].currentState?.popUntil((route) => route.isFirst);
            } else {
              setState(() => _index = tapped);
            }
          },
          items: [
            for (final tab in _tabs)
              BottomNavigationBarItem(icon: Icon(tab.$1), activeIcon: Icon(tab.$2), label: tab.$3),
          ],
        ),
      ),
    );
  }
}
