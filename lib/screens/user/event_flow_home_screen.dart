import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/marketplace_vendor.dart';
import '../../providers/checklist_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/vendor_marketplace_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'checklist_screen.dart';
import 'create_wishlist_screen.dart';
import 'plan_your_event_screen.dart';
import 'wedding_registry_screen.dart';

class EventFlowHomeScreen extends StatelessWidget {
  const EventFlowHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.eventBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: const [
            _HeaderBar(),
            SizedBox(height: 20),
            _HeroBanner(),
            SizedBox(height: 18),
            _SearchBar(),
            SizedBox(height: 28),
            _CategorySection(),
            SizedBox(height: 28),
            _VendorSection(),
          ],
        ),
      ),
      bottomNavigationBar: const _EventFlowBottomNav(),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'EventFlow',
            style: AppTextStyles.headlineLgMobile(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
        ),
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          semanticLabel: 'Notifications',
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
          icon: Icons.menu_rounded,
          semanticLabel: 'Menu',
          onTap: () {},
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.eventDarkIcon, size: 26),
        ),
      ),
    );
  }
}

class _HeroBanner extends ConsumerWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(activeEventProvider);
    if (activeEvent == null) {
      return const _EmptyHeroCard();
    }

    return Column(
      children: [
        _ActiveEventHeroCard(event: activeEvent),
        const SizedBox(height: 14),
        _AddEventButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlanYourEventScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _EmptyHeroCard extends StatelessWidget {
  const _EmptyHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.eventPrimary, AppColors.eventPrimaryLight],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Dream Event Starts Here',
            style: AppTextStyles.headlineLgMobile(
              color: AppColors.onPrimary,
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
          const SizedBox(height: 10),
          Text(
            "No events scheduled. Let's create your first one.",
            style: AppTextStyles.labelMd(
              color: AppColors.eventSoftText,
            ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlanYourEventScreen()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.eventBackground,
              foregroundColor: AppColors.eventBlack,
              padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.eventPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Start Planning Your Event',
                  style: AppTextStyles.labelMd(
                    color: AppColors.eventBlack,
                  ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveEventHeroCard extends ConsumerWidget {
  const _ActiveEventHeroCard({required this.event});

  final ActiveEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysLeft = _daysUntil(event.eventDate);
    final savedWishlist = ref.watch(savedWishlistProvider);
    final checklistTasks = ref.watch(checklistTasksProvider);
    final completedTasks = checklistTasks
        .where((task) => task.isCompleted)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.eventPrimary, AppColors.eventPrimaryLight],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -22,
            child: Icon(
              Icons.event_available_rounded,
              size: 150,
              color: AppColors.onPrimary.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  _taskBadgeText(completedTasks, checklistTasks.length),
                  style: AppTextStyles.labelSm(
                    color: AppColors.eventPrimary,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _countdownText(daysLeft),
                style: AppTextStyles.headlineLg(color: AppColors.onPrimary)
                    .copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                      height: 1.05,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${event.eventType} • ${_formatEventDate(event.eventDate)}',
                style: AppTextStyles.bodyMd(
                  color: AppColors.eventSoftText,
                ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
              ),
              const SizedBox(height: 24),
              _HeroActionButton(
                label: 'View Checklist',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ChecklistScreen(eventName: event.eventName),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _HeroActionButton(
                label: savedWishlist == null
                    ? 'Create Wishlist'
                    : 'View Wishlist',
                icon: Icons.card_giftcard_rounded,
                translucent: true,
                onPressed: () {
                  if (savedWishlist == null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateWishlistScreen(),
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WeddingRegistryScreen(
                        wishlistName: savedWishlist.name,
                        initialItems: savedWishlist.items,
                        initialIsPrivate: savedWishlist.isPrivate,
                        showDemoItems: false,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.translucent = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool translucent;

  @override
  Widget build(BuildContext context) {
    final foreground = translucent
        ? AppColors.onPrimary
        : AppColors.eventPrimary;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: translucent
              ? AppColors.onPrimary.withValues(alpha: 0.18)
              : AppColors.onPrimary,
          foregroundColor: foreground,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19, color: foreground),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.labelMd(
                color: foreground,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEventButton extends StatelessWidget {
  const _AddEventButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Add Event'),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.eventBackground,
          foregroundColor: AppColors.eventBlack,
          side: const BorderSide(color: AppColors.eventBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTextStyles.labelMd(
            color: AppColors.eventBlack,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
        ),
      ),
    );
  }
}

int _daysUntil(DateTime date) {
  final eventDate = DateUtils.dateOnly(date);
  final today = DateUtils.dateOnly(DateTime.now());
  final days = eventDate.difference(today).inDays;
  return days < 0 ? 0 : days;
}

String _countdownText(int days) {
  if (days == 1) return '1 day left';
  return '$days days left';
}

String _taskBadgeText(int completedTasks, int totalTasks) {
  if (totalTasks <= 0) return '$completedTasks TASKS DONE';
  return '$completedTasks/$totalTasks TASKS DONE';
}

String _formatEventDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.eventMutedBackground,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.eventMutedForeground,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search venues, artists, or decor...',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd(
                color: AppColors.eventMutedForeground,
              ).copyWith(fontSize: 15, letterSpacing: 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  static const List<_CategoryItemData> _categories = [
    _CategoryItemData('Halls', Icons.domain_rounded),
    _CategoryItemData('Makeup', Icons.face_retouching_natural_rounded),
    _CategoryItemData('Hair', Icons.content_cut_rounded),
    _CategoryItemData('Catering', Icons.restaurant_rounded),
    _CategoryItemData('Music', Icons.music_note_rounded),
    _CategoryItemData('Decor', Icons.local_florist_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Browse Categories', trailing: 'View All'),
        const SizedBox(height: 16),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _CategoryItem(category: category);
            },
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing, this.trailingIcon});

  final String title;
  final String? trailing;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headlineMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
        ),
        if (trailing != null)
          _SectionTrailing(text: trailing!, icon: trailingIcon),
      ],
    );
  }
}

class _SectionTrailing extends StatelessWidget {
  const _SectionTrailing({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.eventAccent, size: 16),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: AppTextStyles.labelMd(
            color: AppColors.eventAccent,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
        ),
      ],
    );

    if (icon == null) {
      return child;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.eventMutedBackground,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.eventBorder),
      ),
      child: child,
    );
  }
}

class _CategoryItemData {
  const _CategoryItemData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final _CategoryItemData category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.eventMutedBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: AppColors.eventPrimary, size: 27),
          ),
          const SizedBox(height: 8),
          Text(
            category.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSm(
              color: AppColors.eventDarkIcon,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class _VendorSection extends ConsumerStatefulWidget {
  const _VendorSection();

  static const String _location = 'New York, NY';
  static const int _pageLimit = 10;

  @override
  ConsumerState<_VendorSection> createState() => _VendorSectionState();
}

class _VendorSectionState extends ConsumerState<_VendorSection> {
  final List<MarketplaceVendor> _vendors = [];
  var _page = 1;
  var _hasNextPage = false;
  var _isLoading = true;
  var _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVendors(refresh: true);
  }

  Future<void> _loadVendors({required bool refresh}) async {
    final nextPage = refresh ? 1 : _page + 1;

    setState(() {
      if (refresh) {
        _isLoading = true;
        _errorMessage = null;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final result = await ref
          .read(vendorApiServiceProvider)
          .getVendors(
            page: nextPage,
            limit: _VendorSection._pageLimit,
            location: _VendorSection._location,
          );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _vendors
            ..clear()
            ..addAll(result.vendors);
        } else {
          _vendors.addAll(result.vendors);
        }
        _page = result.page;
        _hasNextPage = result.hasNextPage;
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Nearby Vendors',
          trailing: _VendorSection._location,
          trailingIcon: Icons.location_on_rounded,
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const _VendorStatusCard.loading()
        else if (_errorMessage != null && _vendors.isEmpty)
          _VendorStatusCard.error(
            message: _errorMessage!,
            onRetry: () => _loadVendors(refresh: true),
          )
        else if (_vendors.isEmpty)
          _VendorStatusCard.empty(onRetry: () => _loadVendors(refresh: true))
        else ...[
          for (var index = 0; index < _vendors.length; index++) ...[
            _VendorCard(vendor: _vendors[index]),
            if (index != _vendors.length - 1) const SizedBox(height: 18),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineVendorError(
              message: _errorMessage!,
              onRetry: () => _loadVendors(refresh: false),
            ),
          ],
          if (_hasNextPage) ...[
            const SizedBox(height: 16),
            _LoadMoreVendorsButton(
              isLoading: _isLoadingMore,
              onPressed: _isLoadingMore
                  ? null
                  : () => _loadVendors(refresh: false),
            ),
          ],
        ],
      ],
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor});

  final MarketplaceVendor vendor;

  @override
  Widget build(BuildContext context) {
    final rating = vendor.rating == null
        ? '-'
        : vendor.rating!.toStringAsFixed(1);
    final price = vendor.priceLevel.isEmpty ? '\$\$' : vendor.priceLevel;
    final description = vendor.description.isEmpty
        ? 'Event vendor available for planning and bookings.'
        : vendor.description;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: AspectRatio(
                  aspectRatio: 1.72,
                  child: _VendorPhoto(imageUrl: vendor.imageUrl),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _RatingBadge(rating: rating),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vendor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.headlineMd(
                              color: AppColors.eventBlack,
                            ).copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      price,
                      style: AppTextStyles.labelMd(
                        color: AppColors.eventAccent,
                      ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd(
                    color: AppColors.eventMutedForeground,
                  ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _VendorActionButton(
                        label: 'Call',
                        icon: const Icon(Icons.phone_rounded, size: 19),
                        filled: true,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _VendorActionButton(
                        label: 'WhatsApp',
                        icon: const _WhatsAppGlyph(),
                        filled: false,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorPhoto extends StatelessWidget {
  const _VendorPhoto({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const _VendorPhotoPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const _VendorPhotoPlaceholder(isLoading: true);
      },
      errorBuilder: (context, error, stackTrace) {
        return const _VendorPhotoPlaceholder();
      },
    );
  }
}

class _VendorPhotoPlaceholder extends StatelessWidget {
  const _VendorPhotoPlaceholder({this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.eventMutedBackground,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.eventPrimary,
                ),
              )
            : const Icon(
                Icons.storefront_rounded,
                color: AppColors.eventMutedForeground,
                size: 40,
              ),
      ),
    );
  }
}

class _VendorStatusCard extends StatelessWidget {
  const _VendorStatusCard._({
    required this.title,
    required this.message,
    this.isLoading = false,
    this.onRetry,
  });

  const _VendorStatusCard.loading()
    : this._(
        title: 'Loading vendors',
        message: 'Finding available vendors near you.',
        isLoading: true,
      );

  const _VendorStatusCard.error({
    required String message,
    required VoidCallback onRetry,
  }) : this._(
         title: 'Could not load vendors',
         message: message,
         onRetry: onRetry,
       );

  const _VendorStatusCard.empty({required VoidCallback onRetry})
    : this._(
        title: 'No vendors found',
        message: 'Try again or choose another location.',
        onRetry: onRetry,
      );

  final String title;
  final String message;
  final bool isLoading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.eventBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.eventPrimary,
                  ),
                )
              else
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.eventAccent,
                  size: 22,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMd(
                    color: AppColors.eventBlack,
                  ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.labelMd(
              color: AppColors.eventMutedForeground,
            ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.eventAccent,
                padding: EdgeInsets.zero,
                textStyle: AppTextStyles.labelMd(
                  color: AppColors.eventAccent,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineVendorError extends StatelessWidget {
  const _InlineVendorError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSm(
              color: AppColors.eventMutedForeground,
            ).copyWith(letterSpacing: 0),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _LoadMoreVendorsButton extends StatelessWidget {
  const _LoadMoreVendorsButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.eventAccent,
          side: const BorderSide(color: AppColors.eventAccent, width: 1.4),
          shape: const StadiumBorder(),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.eventAccent,
                ),
              )
            : Text(
                'Load more vendors',
                style: AppTextStyles.labelMd(
                  color: AppColors.eventAccent,
                ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
              ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.googleYellow,
            size: 17,
          ),
          const SizedBox(width: 3),
          Text(
            rating,
            style: AppTextStyles.labelMd(
              color: AppColors.eventBlack,
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
        ],
      ),
    );
  }
}

class _VendorActionButton extends StatelessWidget {
  const _VendorActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.onPrimary : AppColors.eventAccent;
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: IconTheme(
          data: IconThemeData(color: foreground),
          child: icon,
        ),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled
              ? AppColors.eventPrimary
              : AppColors.eventBackground,
          foregroundColor: foreground,
          side: BorderSide(
            color: filled ? AppColors.eventPrimary : AppColors.eventAccent,
            width: 1.4,
          ),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelMd(
            color: foreground,
          ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
        ),
      ),
    );
  }
}

class _WhatsAppGlyph extends StatelessWidget {
  const _WhatsAppGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 21,
      height: 21,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.chat_bubble_outline_rounded, size: 21),
          Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.phone_rounded, size: 11),
          ),
        ],
      ),
    );
  }
}

class _EventFlowBottomNav extends ConsumerWidget {
  const _EventFlowBottomNav();

  static const List<_BottomNavItemData> _items = [
    _BottomNavItemData('Home', Icons.home_rounded, true),
    _BottomNavItemData('Chat', Icons.chat_bubble_rounded, false),
    _BottomNavItemData('Checklist', Icons.fact_check_rounded, false),
    _BottomNavItemData('Profile', Icons.person_rounded, false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(activeEventProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: const BoxDecoration(
        color: AppColors.eventBackground,
        border: Border(top: BorderSide(color: AppColors.eventBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _items.map((item) {
            return _BottomNavItem(
              item: item,
              onTap: item.label == 'Chat'
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    }
                  : item.label == 'Checklist'
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChecklistScreen(
                            eventName:
                                activeEvent?.eventName ?? 'Evergreen Events',
                          ),
                        ),
                      );
                    }
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData(this.label, this.icon, this.active);

  final String label;
  final IconData icon;
  final bool active;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.item, this.onTap});

  final _BottomNavItemData item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = item.active
        ? AppColors.eventPrimary
        : AppColors.eventMutedForeground;
    final iconColor = item.active
        ? AppColors.onPrimary
        : AppColors.eventMutedForeground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: item.active ? 48 : 40,
              height: 34,
              decoration: BoxDecoration(
                color: item.active
                    ? AppColors.eventPrimary
                    : AppColors.eventBackground,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(item.icon, color: iconColor, size: 23),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm(color: itemColor).copyWith(
                fontWeight: item.active ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
