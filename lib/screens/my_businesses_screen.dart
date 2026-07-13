import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'add_business_screen.dart';
import 'add_services_screen.dart';
import 'business_details_screen.dart';

/// Screen 5 — "My Businesses". The vendor's home base: empty state until
/// they add their first business, then a list of business cards. Owns the
/// in-memory list of businesses for the whole vendor session and drives the
/// Add Business -> Add Services -> Business Dashboard wizard.
class MyBusinessesScreen extends StatefulWidget {
  const MyBusinessesScreen({super.key});

  @override
  State<MyBusinessesScreen> createState() => _MyBusinessesScreenState();
}

class _MyBusinessesScreenState extends State<MyBusinessesScreen> {
  final List<Business> _businesses = [];

  void _addBusiness() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBusinessScreen(
          onSubmit: (business) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddServicesScreen(
                  business: business,
                  onFinish: () {
                    setState(() => _businesses.add(business));
                    Navigator.of(context).popUntil(ModalRoute.withName('my_businesses'));
                    _openBusiness(business);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openBusiness(Business business) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => BusinessDetailsScreen(
              business: business,
              onDelete: () => setState(() => _businesses.remove(business)),
            ),
          ),
        )
        .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Businesses')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _businesses.isEmpty ? _emptyState() : _businessList(),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.apartment, color: AppColors.primary, size: 48),
          ),
          const SizedBox(height: 24),
          Text('You haven\'t added any businesses yet.', textAlign: TextAlign.center, style: AppTextStyles.bodyLg()),
          const SizedBox(height: 12),
          Text(
            'Each business can have its own services, prices, photos and gallery.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd(),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addBusiness,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
            icon: const Icon(Icons.add),
            label: const Text('Add Business'),
          ),
        ],
      ),
    );
  }

  Widget _businessList() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _businesses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final business = _businesses[index];
              return _BusinessCard(business: business, onTap: () => _openBusiness(business));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: ElevatedButton.icon(
            onPressed: _addBusiness,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
            icon: const Icon(Icons.add),
            label: const Text('Add Another Business'),
          ),
        ),
      ],
    );
  }
}

class _BusinessCard extends StatelessWidget {
  const _BusinessCard({required this.business, required this.onTap});

  final Business business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.dflt),
              ),
              child: Icon(businessCategoryIcon(business.category), color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(business.name, style: AppTextStyles.labelMd()),
                  const SizedBox(height: 2),
                  Text(business.category, style: AppTextStyles.bodyMd()),
                  const SizedBox(height: 2),
                  Text('${business.services.length} Services', style: AppTextStyles.labelSm()),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}
