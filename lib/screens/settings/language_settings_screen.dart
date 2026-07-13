import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

const List<String> _languages = ['English', 'Arabic', 'Hebrew'];

/// "Language" drill-in — picks a language and pops it back to Settings.
/// Cosmetic only: there's no i18n behind the app yet.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key, required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              children: [
                for (final language in _languages)
                  RadioListTile<String>(
                    title: Text(language, style: AppTextStyles.labelMd()),
                    value: language,
                    groupValue: current,
                    activeColor: AppColors.primary,
                    onChanged: (value) => Navigator.of(context).pop(value),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
