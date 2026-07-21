import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// "Manage Features" — a simple tag list (e.g. Garden, Swimming Pool,
/// Parking) attached to a [Business], edited straight off its live list.
class ManageFeaturesScreen extends StatefulWidget {
  const ManageFeaturesScreen({super.key, required this.business});

  final Business business;

  @override
  State<ManageFeaturesScreen> createState() => _ManageFeaturesScreenState();
}

class _ManageFeaturesScreenState extends State<ManageFeaturesScreen> {
  final _featureCtrl = TextEditingController();

  @override
  void dispose() {
    _featureCtrl.dispose();
    super.dispose();
  }

  void _addFeature() {
    final feature = _featureCtrl.text.trim();
    if (feature.isEmpty) return;
    setState(() => widget.business.features.add(feature));
    _featureCtrl.clear();
  }

  void _removeFeature(String feature) => setState(() => widget.business.features.remove(feature));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Features')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _featureCtrl,
                          onSubmitted: (_) => _addFeature(),
                          decoration: const InputDecoration(hintText: 'Example: Garden'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: _addFeature,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (widget.business.features.isEmpty)
                    Text('No features added yet.', style: AppTextStyles.bodyMd())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final feature in widget.business.features)
                          Chip(
                            label: Text(feature, style: AppTextStyles.labelMd()),
                            backgroundColor: AppColors.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.dflt),
                              side: BorderSide(color: AppColors.outlineVariant),
                            ),
                            onDeleted: () => _removeFeature(feature),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
