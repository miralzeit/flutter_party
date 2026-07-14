import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../widgets/service_card_customer_view.dart';

/// Wraps [ServiceCardCustomerView] in its own screen so a vendor can preview
/// exactly what a customer would see for one service.
class ServicePreviewScreen extends StatelessWidget {
  const ServicePreviewScreen({super.key, required this.service});

  final Service service;

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
              child: ServiceCardCustomerView(
                service: service,
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
