import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Upload control for a vendor's work ID photo, shown on registration forms
/// when "Vendor" is selected as the account role.
class VendorIdUploadSection extends StatelessWidget {
  const VendorIdUploadSection({
    super.key,
    required this.fileName,
    required this.onUpload,
    this.title = 'Business Verification',
  });

  final String? fileName;
  final VoidCallback onUpload;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(title, style: AppTextStyles.labelMd()),
        ),
        InkWell(
          onTap: onUpload,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.outlineVariant, width: 2, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                const Icon(Icons.upload_file, color: AppColors.primary, size: 32),
                const SizedBox(height: 12),
                Text('Upload Work ID Photo', style: AppTextStyles.labelMd()),
                const SizedBox(height: 4),
                Text('JPG, PNG or PDF (max. 5MB)', style: AppTextStyles.labelSm()),
                if (fileName != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.dflt),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName!,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSm(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
