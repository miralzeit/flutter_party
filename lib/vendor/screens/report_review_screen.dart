import 'package:flutter/material.dart';
import '../services/mock_business_stats.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

const _reportReasons = [
  'Spam',
  'Fake Review',
  'Offensive Language',
  'Harassment',
  'Incorrect Information',
  'Hate Speech',
  'Not Related to My Business',
  'Other',
];

/// Screen — "Report Review". Pushed from Analytics' Reviews section with a
/// single [Review]; pops `true` once the vendor's report has been submitted
/// so the caller can mark that review as reported.
class ReportReviewScreen extends StatefulWidget {
  const ReportReviewScreen({super.key, required this.review});

  final Review review;

  @override
  State<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends State<ReportReviewScreen> {
  String? _selectedReason;
  final _otherCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  String? _reasonError;
  String? _otherError;

  @override
  void dispose() {
    _otherCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _reasonError = _selectedReason == null ? 'Please select a reason.' : null;
      _otherError = _selectedReason == 'Other' && _otherCtrl.text.trim().isEmpty ? 'Please describe the issue.' : null;
    });
    if (_reasonError != null || _otherError != null) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Submitted'),
        content: const Text('Thank you. Our moderation team will review this report.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Review')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        for (var i = 0; i < 5; i++)
                          Icon(i < review.rating ? Icons.star : Icons.star_border, color: AppColors.tertiary, size: 18),
                      ]),
                      const SizedBox(height: 8),
                      Text(review.customerName, style: AppTextStyles.labelMd()),
                      const SizedBox(height: 6),
                      Text('"${review.text}"', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                      const SizedBox(height: 8),
                      Text(formatLongDate(review.date), style: AppTextStyles.labelSm()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Why are you reporting this review?', style: AppTextStyles.labelMd()),
                for (final reason in _reportReasons)
                  RadioListTile<String>(
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: (value) => setState(() {
                      _selectedReason = value;
                      _reasonError = null;
                    }),
                    title: Text(reason, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                if (_reasonError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_reasonError!, style: AppTextStyles.labelSm(color: AppColors.error)),
                  ),
                if (_selectedReason == 'Other') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otherCtrl,
                    onChanged: (_) {
                      if (_otherError != null) setState(() => _otherError = null);
                    },
                    decoration: InputDecoration(hintText: 'Please specify', errorText: _otherError),
                  ),
                ],
                const SizedBox(height: 24),
                Text('Tell us more about the issue', style: AppTextStyles.labelMd()),
                const SizedBox(height: 8),
                TextField(
                  controller: _detailsCtrl,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Please explain why you believe this review violates our guidelines...',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Submit Report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
