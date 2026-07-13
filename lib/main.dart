import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_register_screen.dart';

void main() {
  runApp(const EventProApp());
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
