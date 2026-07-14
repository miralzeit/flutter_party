import 'package:flutter/material.dart';

/// Admin Panel palette — matches the vendor app's [AppColors] exactly
/// (same "Professional Trust" teal/emerald palette) so both halves of the
/// product read as one system. Kept as its own token set rather than a
/// direct import so the two modules stay independently buildable, not
/// because the colors themselves differ.
class AdminColors {
  AdminColors._();

  static const Color primary = Color(0xFF2F6467);
  static const Color primaryContainer = Color(0xFF497D80);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFF3FFFF);

  static const Color tertiary = Color(0xFF006A3C);
  static const Color tertiaryContainer = Color(0xFF00864D);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFF6FFF5);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  /// Warning accent — neither palette defines one, but the "ACTION REQ" /
  /// pending-review states need something distinct from both tertiary
  /// (success) and error (destructive).
  static const Color warning = Color(0xFFB25E00);
  static const Color warningContainer = Color(0xFFFFDDB3);

  static const Color background = Color(0xFFF9F9FF);
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE6E8F1);

  static const Color outline = Color(0xFF717785);
  static const Color outlineVariant = Color(0xFFC1C6D5);

  static const Color onSurface = Color(0xFF181C22);
  static const Color onSurfaceVariant = Color(0xFF414753);
}
