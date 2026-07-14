import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography scale matching the Stitch "Professional Trust" design system.
/// Font family: Inter. Sizes/weights mirror the exported tailwind config
/// (label-sm/md, body-md/lg, headline-md/lg, headline-lg-mobile, display-lg).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _inter({
    required double fontSize,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    Color color = AppColors.onSurface,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: weight,
      height: height / fontSize,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle displayLg({Color color = AppColors.onSurface}) => _inter(
        fontSize: 48,
        weight: FontWeight.w700,
        height: 56,
        letterSpacing: -0.02 * 48,
        color: color,
      );

  static TextStyle headlineLg({Color color = AppColors.onSurface}) => _inter(
        fontSize: 32,
        weight: FontWeight.w700,
        height: 40,
        letterSpacing: -0.01 * 32,
        color: color,
      );

  static TextStyle headlineLgMobile({Color color = AppColors.onSurface}) =>
      _inter(fontSize: 24, weight: FontWeight.w700, height: 32, color: color);

  static TextStyle headlineMd({Color color = AppColors.onSurface}) => _inter(
        fontSize: 20,
        weight: FontWeight.w600,
        height: 28,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onSurface}) => _inter(
        fontSize: 18,
        weight: FontWeight.w400,
        height: 28,
        color: color,
      );

  static TextStyle bodyMd({Color color = AppColors.onSurfaceVariant}) =>
      _inter(fontSize: 16, weight: FontWeight.w400, height: 24, color: color);

  static TextStyle labelMd({Color color = AppColors.onSurface}) => _inter(
        fontSize: 14,
        weight: FontWeight.w600,
        height: 20,
        letterSpacing: 0.01 * 14,
        color: color,
      );

  static TextStyle labelSm({Color color = AppColors.onSurfaceVariant}) =>
      _inter(fontSize: 12, weight: FontWeight.w500, height: 16, color: color);

  /// The large number on a [MetricCard] (Dashboard / Analytics grids).
  static TextStyle statValue({Color color = AppColors.onSurface}) =>
      _inter(fontSize: 24, weight: FontWeight.w500, height: 32, color: color);
}
