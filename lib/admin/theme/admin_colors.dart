import 'package:flutter/material.dart';

/// Admin Panel palette — matches the vendor app's [AppColors] exactly
/// (same "Professional Trust" teal/emerald palette) so both halves of the
/// product read as one system. Kept as its own token set rather than a
/// direct import so the two modules stay independently buildable, not
/// because the colors themselves differ.
class AdminColors {
  AdminColors._();

  static const Color primary = Color(0xFF002C2F);
  static const Color primaryContainer = Color(0xFF054447);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF7DB0B4);

  // Tertiary (success / positive status – emerald). The export's vivid
  // accent green lives at the "on-tertiary-container" token (#00c071) and is
  // used directly throughout the reference screens, so it's mapped to both
  // tertiary and onTertiaryContainer here to match usage 1:1.
  static const Color tertiary = Color(0xFF00C071);
  static const Color tertiaryContainer = Color(0xFF004726);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF00C071);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  /// Warning accent — neither palette defines one, but the "ACTION REQ" /
  /// pending-review states need something distinct from both tertiary
  /// (success) and error (destructive).
  static const Color warning = Color(0xFFB25E00);
  static const Color warningContainer = Color(0xFFFFDDB3);

  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLow = Color(0xFFF3F4F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E8);

  static const Color outline = Color(0xFF707979);
  static const Color outlineVariant = Color(0xFFBFC8C8);

  static const Color onSurface = Color(0xFF191C1C);
  static const Color onSurfaceVariant = Color(0xFF404849);
}
