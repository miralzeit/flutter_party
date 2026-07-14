import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vendor/theme/app_theme.dart';
import 'vendor/screens/login_register_screen.dart';

void main() {
  runApp(const ProviderScope(child: EventProApp()));
}

class EventProApp extends StatelessWidget {
  const EventProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginRegisterScreen(),
    );
  }
}
