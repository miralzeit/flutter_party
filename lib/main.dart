import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_register_screen.dart';
import 'screens/user/checklist_screen.dart';
import 'screens/user/create_wishlist_screen.dart';
import 'screens/user/event_flow_home_screen.dart';
import 'screens/user/plan_your_event_screen.dart';
import 'screens/user/wedding_registry_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: EventProApp()));
}

class EventProApp extends StatelessWidget {
  const EventProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginRegisterScreen(),
      routes: {
        '/home': (_) => const EventFlowHomeScreen(),
        '/plan-event': (_) => const PlanYourEventScreen(),
        '/create-wishlist': (_) => const CreateWishlistScreen(),
        '/checklist': (_) => const ChecklistScreen(),
        '/wedding-registry': (_) => const WeddingRegistryScreen(),
      },
    );
  }
}
