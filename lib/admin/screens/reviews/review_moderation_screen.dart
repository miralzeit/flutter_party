import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin_review.dart';
import '../../providers/admin_providers.dart';
import '../../theme/admin_colors.dart';
import '../../theme/admin_text_styles.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_empty_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/report_reason_chip.dart';

enum _ReviewFilter { all, reported, recent, highestRated, lowestRated }

extension on _ReviewFilter {
  String get label {
    switch (this) {
      case _ReviewFilter.all:
        return 'All Reviews';
      case _ReviewFilter.reported:
        return 'Reported';
      case _ReviewFilter.recent:
        return 'Recent';
      case _ReviewFilter.highestRated:
        return 'Highest Rated';
      case _ReviewFilter.lowestRated:
        return 'Lowest Rated';
    }
  }
}

const _pageSize = 4;

/// Screen — "Review Moderation". Queue for handling user-submitted reviews,
/// with Reported surfaced first by default. Keep/Hide/Delete are all
/// timestamped and attributed via [AuditLogNotifier].
class ReviewModerationScreen extends ConsumerStatefulWidget {
  const ReviewModerationScreen({super.key});

  @override
  ConsumerState<ReviewModerationScreen> createState() => _ReviewModerationScreenState();
}

class _ReviewModerationScreenState extends ConsumerState<ReviewModerationScreen> {
  _ReviewFilter _filter = _ReviewFilter.all;
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    if (ref.read(reviewsShowReportedOnlyProvider)) {
      _filter = _ReviewFilter.reported;
      Future.microtask(() => ref.read(reviewsShowReportedOnlyProvider.notifier).state = false);
    }
  }

  /// Same caveat as VendorsScreen: this screen lives inside the shell's
  /// [IndexedStack], so `initState` only runs once ever — later deep links
  /// from Overview must be applied reactively via [ref.listen] in `build`.
  void _applyDeepLink(bool showReportedOnly) {
    if (!showReportedOnly) return;
    setState(() {
      _filter = _ReviewFilter.reported;
      _visibleCount = _pageSize;
    });
    Future.microtask(() => ref.read(reviewsShowReportedOnlyProvider.notifier).state = false);
  }

  Future<void> _keep(AdminReview review) async {
    ref.read(reviewsProvider.notifier).setModerationStatus(review.id, ModerationStatus.published);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review kept and published.')));
  }

  void _hide(AdminReview review) {
    ref.read(reviewsProvider.notifier).setModerationStatus(review.id, ModerationStatus.hidden);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review hidden from the public site.')));
  }

  Future<void> _delete(AdminReview review) async {
    final confirmed = await showAdminConfirmDialog(
      context,
      title: 'Delete Review',
      message: 'This permanently removes ${review.reviewerName}\'s review of ${review.vendorName}. This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed) ref.read(reviewsProvider.notifier).setModerationStatus(review.id, ModerationStatus.deleted);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(reviewsShowReportedOnlyProvider, (previous, next) => _applyDeepLink(next));
    var reviews = ref.watch(reviewsProvider).where((r) => r.moderationStatus != ModerationStatus.deleted).toList();

    switch (_filter) {
      case _ReviewFilter.all:
        reviews.sort((a, b) => b.date.compareTo(a.date));
      case _ReviewFilter.reported:
        reviews = reviews.where((r) => r.isReported).toList()..sort((a, b) => b.date.compareTo(a.date));
      case _ReviewFilter.recent:
        reviews.sort((a, b) => b.date.compareTo(a.date));
      case _ReviewFilter.highestRated:
        reviews.sort((a, b) => b.rating.compareTo(a.rating));
      case _ReviewFilter.lowestRated:
        reviews.sort((a, b) => a.rating.compareTo(b.rating));
    }

    final visible = reviews.take(_visibleCount).toList();
    final hasMore = _visibleCount < reviews.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Moderation')),
      body: Padding(
        padding: const EdgeInsets.all(AdminSpacing.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final filter in _ReviewFilter.values)
                  ChoiceChip(
                    label: Text(filter.label),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() {
                      _filter = filter;
                      _visibleCount = _pageSize;
                    }),
                    selectedColor: AdminColors.primary.withValues(alpha: 0.15),
                    labelStyle: AdminTextStyles.labelSm(color: _filter == filter ? AdminColors.primary : AdminColors.onSurfaceVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AdminRadius.full),
                      side: BorderSide(color: _filter == filter ? AdminColors.primary : AdminColors.outlineVariant),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: visible.isEmpty
                  ? const AdminEmptyState(icon: Icons.star_outline, message: 'No reviews match this filter.')
                  : ListView.separated(
                      itemCount: visible.length + (hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == visible.length) {
                          return Center(
                            child: TextButton(
                              onPressed: () => setState(() => _visibleCount += _pageSize),
                              child: const Text('Load more reviews'),
                            ),
                          );
                        }
                        final review = visible[index];
                        return _ReviewCard(review: review, onKeep: () => _keep(review), onHide: () => _hide(review), onDelete: () => _delete(review));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onKeep, required this.onHide, required this.onDelete});

  final AdminReview review;
  final VoidCallback onKeep;
  final VoidCallback onHide;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isHidden = review.moderationStatus == ModerationStatus.hidden;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AdminRadius.sm),
        border: Border.all(color: review.isReported ? AdminColors.error.withValues(alpha: 0.35) : AdminColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(review.reviewerName, style: AdminTextStyles.labelMd()),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: review.reviewerType == ReviewerType.verifiedGuest ? AdminColors.tertiaryContainer.withValues(alpha: 0.5) : AdminColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AdminRadius.full),
                      ),
                      child: Text(
                        review.reviewerType.label,
                        style: AdminTextStyles.labelSm(color: review.reviewerType == ReviewerType.verifiedGuest ? AdminColors.tertiary : AdminColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              if (isHidden)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AdminColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(AdminRadius.full)),
                  child: Text('Hidden', style: AdminTextStyles.labelSm()),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('on ${review.vendorName}', style: AdminTextStyles.bodyMd()),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < 5; i++) Icon(i < review.rating ? Icons.star : Icons.star_border, size: 16, color: AdminColors.tertiary),
              const SizedBox(width: 8),
              Text(_formatDate(review.date), style: AdminTextStyles.labelSm()),
            ],
          ),
          if (review.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.body, style: AdminTextStyles.bodyLg()),
          ],
          if (review.reportReasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [for (final reason in review.reportReasons) ReportReasonChip(reason: reason)]),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onKeep, child: const Text('Keep')),
              TextButton(onPressed: onHide, child: const Text('Hide')),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(foregroundColor: AdminColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
