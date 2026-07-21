import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_register_screen.dart';
import 'user/user.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: EventProApp()));
}

class EventProApp extends ConsumerWidget {
  const EventProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp(
      title: 'EventFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) return const Locale('en');
        return supportedLocales.firstWhere(
          (locale) => locale.languageCode == deviceLocale.languageCode,
          orElse: () => const Locale('en'),
        );
      },
      builder: (context, child) {
        return Directionality(
          textDirection: AppLocalizations.isRtl(locale)
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const LoginRegisterScreen(),
      routes: {
        '/home': (_) => const EventFlowHomeScreen(),
        '/plan-event': (_) => const PlanYourEventScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/edit-profile': (_) => const EditProfileScreen(),
        '/security-settings': (_) => const SecuritySettingsScreen(),
        '/help-center': (_) => const HelpCenterScreen(),
        '/notification-settings': (_) => const NotificationSettingsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/create-wishlist': (_) => const CreateWishlistScreen(),
        '/chat': (_) => const ChatScreen(),
        '/checklist': (_) => const ChecklistScreen(),
        '/wedding-registry': (_) => const WeddingRegistryScreen(),
      },
    );
  }
}
