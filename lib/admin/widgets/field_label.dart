import 'package:flutter/material.dart';
import '../theme/admin_text_styles.dart';

/// The small label text above a form field on admin edit screens (e.g. Add/
/// Edit Category).
class AdminFieldLabel extends StatelessWidget {
  const AdminFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AdminTextStyles.labelMd()),
    );
  }
}
