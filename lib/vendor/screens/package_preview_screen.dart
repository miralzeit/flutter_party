import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../widgets/package_card_customer_view.dart';

/// Wraps [PackageCardCustomerView] in its own screen so a vendor can preview
/// exactly what a customer would see for one package.
class PackagePreviewScreen extends StatelessWidget {
  const PackagePreviewScreen({super.key, required this.package});

  final Package package;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: PackageCardCustomerView(
                package: package,
                onCta: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a preview — no action taken.')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
