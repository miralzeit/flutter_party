import 'package:flutter/material.dart';

/// Color palette matching the Stitch "Professional Trust" design export
/// exactly — values are taken verbatim from DESIGN.md's frontmatter and the
/// tailwind.config embedded in each screen's code.html (the two agree).
///
/// A near-black deep teal primary (#002c2f) with a lighter teal primary
/// container (#054447), paired with a vibrant emerald accent (#00c071) on a
/// near-white, cool-toned background. Corporate, clean, high-contrast.
class AppColors {
  AppColors._();

  // Brand / primary
  static const Color primary = Color(0xFF002C2F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF054447);
  static const Color onPrimaryContainer = Color(0xFF7DB0B4);
  static const Color primaryFixed = Color(0xFFB7ECEF);
  static const Color primaryFixedDim = Color(0xFF9BD0D3);
  static const Color onPrimaryFixed = Color(0xFF002021);
  static const Color onPrimaryFixedVariant = Color(0xFF164E51);
  static const Color inversePrimary = Color(0xFF9BD0D3);
  static const Color surfaceTint = Color(0xFF326669);

  // Secondary (used sparingly for links / accents)
  static const Color secondary = Color(0xFF4F6263);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFCFE4E5);
  static const Color onSecondaryContainer = Color(0xFF536667);
  static const Color secondaryFixed = Color(0xFFD2E6E7);
  static const Color secondaryFixedDim = Color(0xFFB6CACB);
  static const Color onSecondaryFixed = Color(0xFF0B1E20);
  static const Color onSecondaryFixedVariant = Color(0xFF374A4B);

  // Tertiary (success / positive status – emerald). The export's vivid
  // accent green lives at the "on-tertiary-container" token (#00c071) and is
  // used directly throughout the reference screens (stars, checkmarks,
  // trend arrows), so it's mapped to both tertiary and onTertiaryContainer
  // here to match usage 1:1.
  static const Color tertiary = Color(0xFF00C071);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF004726);
  static const Color onTertiaryContainer = Color(0xFF00C071);
  static const Color tertiaryFixed = Color(0xFF63FEA6);
  static const Color tertiaryFixedDim = Color(0xFF40E18C);
  static const Color onTertiaryFixed = Color(0xFF00210F);
  static const Color onTertiaryFixedVariant = Color(0xFF00522D);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surfaces
  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF191C1C);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceBright = Color(0xFFF9F9F9);
  static const Color surfaceDim = Color(0xFFD9DADA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F3);
  static const Color surfaceContainer = Color(0xFFEDEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E2);
  static const Color onSurface = Color(0xFF191C1C);
  static const Color onSurfaceVariant = Color(0xFF404849);
  static const Color surfaceVariant = Color(0xFFE1E3E2);
  static const Color inverseSurface = Color(0xFF2E3131);
  static const Color inverseOnSurface = Color(0xFFF0F1F0);

  // Outline
  static const Color outline = Color(0xFF707979);
  static const Color outlineVariant = Color(0xFFBFC8C8);

  // Social auth brand colors (not part of the design system; kept for the
  // OAuth buttons which mirror each provider's real brand mark)
  static const Color appleBlack = Color(0xFF191C1C);
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleRed = Color(0xFFEA4335);
}
