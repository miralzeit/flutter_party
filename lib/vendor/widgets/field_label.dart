import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// The small label text above a plain (non-[LabeledTextField]) form field —
/// used by screens that lay out their own [TextField]s directly (Business
/// Details, Create Package, Set Up Profile, onboarding steps, Change
/// Password, Add/Edit Service).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text, style: AppTextStyles.labelMd()),
    );
  }
}
