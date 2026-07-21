import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'package_card_customer_view.dart';
import 'service_card_customer_view.dart';
import 'status_pill.dart';

/// Read-only, "how customers see me" rendering of an entire [Business] —
/// header (name/category/status/location), the business blurb, key facts
/// (hours, capacity, price, contacts), features, services, packages and
/// FAQs, all in one scroll. Standalone and stateless so it can back both the
/// Dashboard "Preview" screen and the onboarding Review step from a single
/// source of truth.
///
/// Empty sections simply don't render — a bare-bones draft shows only what it
/// actually has, never empty scaffolding.
class BusinessListingView extends StatelessWidget {
  const BusinessListingView({super.key, required this.business, this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24)});

  final Business business;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final services = business.services;
    final packages = business.packages;
    final features = business.features;
    final faqs = business.faqs;

    return ListView(
      padding: padding,
      children: [
        _Header(business: business),
        if (business.description.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(business.description, style: AppTextStyles.bodyLg()),
        ],
        const SizedBox(height: 20),
        _KeyFacts(business: business),
        if (features.isNotEmpty) ...[
          const SizedBox(height: 28),
          _SectionTitle('Features & Amenities'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final feature in features) _FeatureChip(label: feature)],
          ),
        ],
        const SizedBox(height: 28),
        _SectionTitle('Services', count: services.length),
        const SizedBox(height: 12),
        if (services.isEmpty)
          _EmptyLine('No services listed yet.')
        else
          for (final service in services) ...[
            ServiceCardCustomerView(service: service),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 16),
        _SectionTitle('Packages', count: packages.length),
        const SizedBox(height: 12),
        if (packages.isEmpty)
          _EmptyLine('No packages listed yet.')
        else
          for (final package in packages) ...[
            PackageCardCustomerView(package: package),
            const SizedBox(height: 12),
          ],
        if (faqs.isNotEmpty) ...[
          const SizedBox(height: 28),
          _SectionTitle('FAQs'),
          const SizedBox(height: 12),
          for (final faq in faqs) ...[
            _FaqTile(faq: faq),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

/// Name, category icon, live status pill and city.
class _Header extends StatelessWidget {
  const _Header({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(businessCategoryIcon(business.category), color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(business.name.isEmpty ? 'Your Business' : business.name, style: AppTextStyles.headlineMd()),
              const SizedBox(height: 4),
              Text(business.category, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusPill(status: business.status),
                  if (business.location.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.place_outlined, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              business.location,
                              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact grid of the at-a-glance facts a customer scans first: starting
/// price, hours, capacity and contact channels. Each row only appears when
/// the business actually has that value.
class _KeyFacts extends StatelessWidget {
  const _KeyFacts({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String)>[
      if (business.basePrice != null) (Icons.attach_money_rounded, 'Starting from ${business.basePrice!.toStringAsFixed(0)} ILS'),
      if (business.businessHours.isNotEmpty) (Icons.schedule_outlined, business.businessHours),
      if (business.capacity != null) (Icons.groups_outlined, 'Up to ${business.capacity} guests'),
      if (business.address.isNotEmpty) (Icons.location_on_outlined, business.address),
      if (business.whatsapp.isNotEmpty) (Icons.chat_outlined, 'WhatsApp: ${business.whatsapp}'),
      if (business.instagram.isNotEmpty) (Icons.camera_alt_outlined, business.instagram),
      if (business.facebook.isNotEmpty) (Icons.facebook_outlined, business.facebook),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(rows[i].$1, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(rows[i].$2, style: AppTextStyles.bodyMd(color: AppColors.onSurface))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.headlineMd()),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text('$count', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
          ),
        ],
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.tertiary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelSm(color: AppColors.tertiary)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final Faq faq;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(faq.question, style: AppTextStyles.labelMd()),
          const SizedBox(height: 6),
          Text(faq.answer, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant));
}
