import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Dashed-style upload box for business/service photos. There is no image
/// picker wired up yet, so [onUpload] simply simulates adding a photo and
/// the box reflects how many have been "added" so far.
class UploadPhotosBox extends StatelessWidget {
  const UploadPhotosBox({
    super.key,
    required this.label,
    required this.count,
    required this.onUpload,
    this.buttonLabel = 'Upload Photos',
  });

  final String label;
  final int count;
  final VoidCallback onUpload;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: AppTextStyles.labelMd()),
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
              border: Border.all(color: AppColors.outlineVariant, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 32),
                const SizedBox(height: 12),
                Text(buttonLabel, style: AppTextStyles.labelMd()),
                if (count > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$count photo${count == 1 ? '' : 's'} added',
                    style: AppTextStyles.labelSm(color: AppColors.primary),
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

/// Grid of square photo tiles plus a trailing "add" tile. Same simulated
/// upload as [UploadPhotosBox] — [onAdd] just increments the count — but
/// laid out as a picker grid for forms that support multiple photos.
class PhotoGridPicker extends StatelessWidget {
  const PhotoGridPicker({super.key, required this.label, required this.count, required this.onAdd});

  final String label;
  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: AppTextStyles.labelMd()),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (index == count) {
              return InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.outlineVariant, width: 2),
                  ),
                  child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.photo_outlined, color: AppColors.primary),
            );
          },
        ),
      ],
    );
  }
}

/// Circular profile-picture placeholder + "Upload Photo" button used on the
/// vendor profile setup screen.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({super.key, required this.hasPhoto, required this.onUpload});

  final bool hasPhoto;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant, width: 2),
          ),
          child: Icon(
            hasPhoto ? Icons.check_circle : Icons.person,
            color: hasPhoto ? AppColors.primary : AppColors.outline,
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onUpload,
          icon: const Icon(Icons.add_a_photo_outlined, size: 18),
          label: const Text('Upload Photo'),
        ),
      ],
    );
  }
}
