import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../widgets/photo_upload.dart';

/// "Manage Photos" — reuses [UploadPhotosBox] to add photos to a [Business].
/// There's no real image picker wired up yet (see [UploadPhotosBox]), so
/// this simply tracks a running count like everywhere else photos are used.
class ManagePhotosScreen extends StatefulWidget {
  const ManagePhotosScreen({super.key, required this.business});

  final Business business;

  @override
  State<ManagePhotosScreen> createState() => _ManagePhotosScreenState();
}

class _ManagePhotosScreenState extends State<ManagePhotosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Photos')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: UploadPhotosBox(
                label: 'Business Photos',
                count: widget.business.photoCount,
                onUpload: () => setState(() => widget.business.photoCount += 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
