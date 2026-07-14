import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_colors.dart';

/// Admin Panel typography — Inter throughout. The spec only enumerates
/// headline-lg/md, body-lg and label-md; label-sm/body-md are a small,
/// necessary extension for a "tight, information-dense" table-heavy UI
/// (secondary table text, chip labels), sized on the same scale.
class AdminTextStyles {
  AdminTextStyles._();

  static TextStyle _inter({required double fontSize, required FontWeight weight, required double height, Color color = AdminColors.onSurface}) {
    return GoogleFonts.inter(fontSize: fontSize, fontWeight: weight, height: height / fontSize, color: color);
  }

  static TextStyle headlineLg({Color color = AdminColors.onSurface}) => _inter(fontSize: 32, weight: FontWeight.w700, height: 40, color: color);

  static TextStyle headlineMd({Color color = AdminColors.onSurface}) => _inter(fontSize: 24, weight: FontWeight.w600, height: 32, color: color);

  static TextStyle bodyLg({Color color = AdminColors.onSurface}) => _inter(fontSize: 16, weight: FontWeight.w400, height: 24, color: color);

  static TextStyle bodyMd({Color color = AdminColors.onSurfaceVariant}) => _inter(fontSize: 14, weight: FontWeight.w400, height: 20, color: color);

  static TextStyle labelMd({Color color = AdminColors.onSurface}) => _inter(fontSize: 14, weight: FontWeight.w500, height: 20, color: color);

  static TextStyle labelSm({Color color = AdminColors.onSurfaceVariant}) => _inter(fontSize: 12, weight: FontWeight.w500, height: 16, color: color);

  /// The large number on a stat card.
  static TextStyle statValue({Color color = AdminColors.onSurface}) => _inter(fontSize: 28, weight: FontWeight.w700, height: 34, color: color);
}
