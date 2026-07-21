import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// One tappable card in a [QuickActionGrid].
class QuickAction {
  QuickAction({required this.icon, required this.label, this.subtitle, required this.onTap});

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
}

/// Dashboard "Quick Actions" as a grid of large cards rather than a row of
/// chips — matches the size/weight of the rest of the dashboard's cards.
class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth >= 760 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (context, index) => _QuickActionTile(action: actions[index]),
      ),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({required this.action});

  final QuickAction action;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // Avoid attaching a MouseRegion when this tile has no layout size —
    // on web this can trigger "Cannot hit test a render box with no size".
    return LayoutBuilder(builder: (context, constraints) {
      final hasSize = constraints.maxWidth > 0 && constraints.maxHeight > 0;

      Widget tile = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: _hovered ? 1.02 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.action.onTap,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _hovered ? AppColors.primaryContainer.withValues(alpha: .14) : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: _hovered ? AppColors.primary.withValues(alpha: .45) : AppColors.outlineVariant.withValues(alpha: .65)),
                ),
                child: Row(
                  children: [
                    Icon(widget.action.icon, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.action.label, style: AppTextStyles.labelMd()),
                          if (widget.action.subtitle != null) ...[
                            const SizedBox(height: 6),
                            Text(widget.action.subtitle!, style: AppTextStyles.bodyMd()),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      if (!hasSize) return tile;

      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: tile,
      );
    });
  }
}
