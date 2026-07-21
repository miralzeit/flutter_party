import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin/theme/admin_theme.dart';
import 'admin/widgets/admin_shell.dart';

/// Separate entry point for the EventPro Manager Admin Panel — run with
/// `flutter run -t lib/admin_main.dart`. Deliberately its own `main()`,
/// theme and Riverpod scope: this is a distinct internal tool (dense,
/// desktop-first, darker "Corporate Modern" palette) from the vendor-facing
/// mobile app in `lib/main.dart`, not a tab bolted onto it.
void main() {
  runApp(const ProviderScope(child: EventProAdminApp()));
}

class EventProAdminApp extends StatelessWidget {
  const EventProAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventPro Manager — Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.theme,
      home: const AdminShell(),
    );
  }
}
