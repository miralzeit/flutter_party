import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// "Or continue with" divider used above social auth buttons.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'Or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSm().copyWith(letterSpacing: 1.2),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.outlineVariant)),
        ],
      ),
    );
  }
}

/// Google social auth button — outlined, white, with brand "G" mark.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({super.key, required this.onPressed, this.expanded = true});

  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.surfaceContainerLowest,
        side: const BorderSide(color: AppColors.outlineVariant),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _GoogleMark(),
          const SizedBox(width: 10),
          Text('Google', style: AppTextStyles.labelMd(color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

/// Apple social auth button — solid black/on-surface with apple glyph.
class AppleAuthButton extends StatelessWidget {
  const AppleAuthButton({super.key, required this.onPressed, this.expanded = true});

  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.onSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.apple, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text('Apple', style: AppTextStyles.labelMd(color: Colors.white)),
        ],
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    // Simple 4-color "G" chip approximation built from shapes (avoids
    // bundling brand image assets while keeping the four brand colors).
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GoogleGPainter()),
          ),
        ],
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;

    // Quarter-circle quadrants approximating the Google "G" brand colors.
    paint.color = AppColors.googleBlue;
    canvas.drawArc(rect, -0.3, 1.6, true, paint);
    paint.color = AppColors.googleGreen;
    canvas.drawArc(rect, 1.3, 1.6, true, paint);
    paint.color = AppColors.googleYellow;
    canvas.drawArc(rect, 2.9, 1.6, true, paint);
    paint.color = AppColors.googleRed;
    canvas.drawArc(rect, 4.5, 1.6, true, paint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.28, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
