import 'package:flutter/material.dart';
import '../models/business.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/business_listing_view.dart';

/// "Listing Preview" — the whole business as a customer sees it: info,
/// features, services, packages and FAQs on one page. Read-only by design;
/// editing lives in the dedicated editors reached from the Dashboard. Opened
/// from the Dashboard status card's Preview button.
class ListingPreviewScreen extends StatelessWidget {
  const ListingPreviewScreen({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Preview'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('How customers see your business', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: BusinessListingView(business: business),
          ),
        ),
      ),
    );
  }
}
