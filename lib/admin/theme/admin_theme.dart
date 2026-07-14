import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_colors.dart';
import 'admin_text_styles.dart';

/// Shape tokens: 8px buttons/inputs, 16px cards/modals, 24px max large
/// containers, full-pill chips.
class AdminRadius {
  AdminRadius._();
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double full = 999;
}

/// Spacing tokens: 8px base unit, 16px gutters, 24px outer margin.
class AdminSpacing {
  AdminSpacing._();
  static const double unit = 8;
  static const double gutter = 16;
  static const double margin = 24;
}

/// Width above which the sidebar is permanently docked; below it, the admin
/// shell collapses to a top bar + drawer.
const double kAdminSidebarBreakpoint = 1024;

class AdminTheme {
  AdminTheme._();

  static ThemeData get theme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AdminColors.primary,
      onPrimary: AdminColors.onPrimary,
      primaryContainer: AdminColors.primaryContainer,
      onPrimaryContainer: AdminColors.onPrimaryContainer,
      secondary: AdminColors.primary,
      onSecondary: AdminColors.onPrimary,
      secondaryContainer: AdminColors.primaryContainer,
      onSecondaryContainer: AdminColors.onPrimaryContainer,
      tertiary: AdminColors.tertiary,
      onTertiary: AdminColors.onTertiary,
      tertiaryContainer: AdminColors.tertiaryContainer,
      onTertiaryContainer: AdminColors.onTertiaryContainer,
      error: AdminColors.error,
      onError: AdminColors.onError,
      errorContainer: AdminColors.errorContainer,
      onErrorContainer: AdminColors.onErrorContainer,
      surface: AdminColors.surface,
      onSurface: AdminColors.onSurface,
      surfaceContainerLowest: AdminColors.surfaceContainerLowest,
      surfaceContainerLow: AdminColors.surfaceContainerLow,
      surfaceContainerHigh: AdminColors.surfaceContainerHigh,
      onSurfaceVariant: AdminColors.onSurfaceVariant,
      outline: AdminColors.outline,
      outlineVariant: AdminColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AdminColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AdminColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AdminTextStyles.headlineMd(),
        iconTheme: const IconThemeData(color: AdminColors.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: AdminColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminRadius.sm)),
          textStyle: AdminTextStyles.labelMd(color: AdminColors.onPrimary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: AdminTextStyles.bodyMd(color: AdminColors.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminRadius.sm),
          borderSide: const BorderSide(color: AdminColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminRadius.sm),
          borderSide: const BorderSide(color: AdminColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminRadius.sm),
          borderSide: const BorderSide(color: AdminColors.primary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AdminColors.outlineVariant, thickness: 1, space: 1),
    );
  }
}
