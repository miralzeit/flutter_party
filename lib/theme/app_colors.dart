import 'package:flutter/material.dart';

/// Color palette extracted from the Stitch "Professional Trust" design
/// system (DESIGN.md) and the exported screen tailwind configs.
///
/// A deep teal primary (#2f6467 / #054447) paired with a vibrant emerald
/// tertiary (#00c473) on a near-white, cool-toned background. Corporate,
/// clean, high-contrast.
class AppColors {
  AppColors._();

  // Brand / primary
  static const Color primary = Color(0xFF2F6467);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF497D80);
  static const Color onPrimaryContainer = Color(0xFFF3FFFF);
  static const Color primaryFixedDim = Color(0xFF9BD0D3);
  static const Color surfaceTint = Color(0xFF326669);

  // Secondary (used sparingly for links / accents)
  static const Color secondary = Color(0xFF465F89);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB7CFFF);
  static const Color onSecondaryContainer = Color(0xFF405882);

  // Tertiary (success / positive status – emerald)
  static const Color tertiary = Color(0xFF006A3C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF00864D);
  static const Color onTertiaryContainer = Color(0xFFF6FFF5);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surfaces
  static const Color background = Color(0xFFF9F9FF);
  static const Color onBackground = Color(0xFF181C22);
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceBright = Color(0xFFF9F9FF);
  static const Color surfaceDim = Color(0xFFD8DAE3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FD);
  static const Color surfaceContainer = Color(0xFFECEDF7);
  static const Color surfaceContainerHigh = Color(0xFFE6E8F1);
  static const Color surfaceContainerHighest = Color(0xFFE0E2EC);
  static const Color onSurface = Color(0xFF181C22);
  static const Color onSurfaceVariant = Color(0xFF414753);
  static const Color surfaceVariant = Color(0xFFE0E2EC);

  // Outline
  static const Color outline = Color(0xFF717785);
  static const Color outlineVariant = Color(0xFFC1C6D5);

  // Social auth brand colors
  static const Color appleBlack = Color(0xFF181C22);
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleRed = Color(0xFFEA4335);

  // EventFlow home screen
  static const Color eventPrimary = Color(0xFF1F3D3A);
  static const Color eventPrimaryLight = Color(0xFF335E58);
  static const Color eventAccent = Color(0xFF2E7D32);
  static const Color eventBackground = Color(0xFFFFFFFF);
  static const Color eventMutedBackground = Color(0xFFF5F5F5);
  static const Color eventMutedForeground = Color(0xFF6E7573);
  static const Color eventDarkIcon = Color(0xFF313735);
  static const Color eventSoftText = Color(0xFFC9D7D2);
  static const Color eventBorder = Color(0xFFE4E8E6);
  static const Color eventShadow = Color(0x1A1F3D3A);
  static const Color eventBlack = Color(0xFF101412);
}
