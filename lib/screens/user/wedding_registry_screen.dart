import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/wishlist_provider.dart';
import '../../services/wishlist_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

const bool _skipWishlistBackend = bool.fromEnvironment(
  'SKIP_WISHLIST_BACKEND',
  defaultValue: false,
);
const bool _skipCreateEventBackend = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class WeddingRegistryScreen extends ConsumerStatefulWidget {
  const WeddingRegistryScreen({
    super.key,
    this.wishlistName = 'Wedding Registry',
    this.initialItems = const [],
    this.initialIsPrivate = false,
    this.showDemoItems = true,
  });

  final String wishlistName;
  final List<WishlistItem> initialItems;
  final bool initialIsPrivate;
  final bool showDemoItems;

  @override
  ConsumerState<WeddingRegistryScreen> createState() =>
      _WeddingRegistryScreenState();
}

class _WeddingRegistryScreenState extends ConsumerState<WeddingRegistryScreen> {
  final _urlController = TextEditingController();
  late final List<WishlistItem> _items;
  late bool _isPrivate;
  var _isAddingItem = false;

  bool get _useLocalWishlistData =>
      _skipWishlistBackend || _skipCreateEventBackend;

  @override
  void initState() {
    super.initState();
    _items = widget.showDemoItems && widget.initialItems.isEmpty
        ? List<WishlistItem>.of(_demoRegistryItems)
        : List<WishlistItem>.of(widget.initialItems);
    _isPrivate = widget.initialIsPrivate;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addItemByUrl() async {
    final url = _urlController.text.trim();
    if (!_isValidUrl(url)) {
      _showMessage('Paste a valid item URL first.');
      return;
    }

    setState(() => _isAddingItem = true);

    try {
      final item = _useLocalWishlistData
          ? WishlistItem.demoFromUrl(url)
          : await ref.read(wishlistApiServiceProvider).addItemByUrl(url);

      if (!mounted) return;
      setState(() {
        _items.insert(0, item);
        _urlController.clear();
      });
      _syncSavedWishlist();
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isAddingItem = false);
    }
  }

  Future<void> _openStore(WishlistItem item) async {
    final uri = Uri.tryParse(item.url);
    if (uri == null) {
      _showMessage('Store link is not available.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showMessage('Could not open store link.');
    }
  }

  void _copyLink() {
    Clipboard.setData(
      const ClipboardData(text: 'https://eventflow.app/wishlist'),
    );
    _showMessage('Wishlist link copied.');
  }

  void _syncSavedWishlist() {
    final existing = ref.read(savedWishlistProvider);
    if (existing == null) return;
    ref.read(savedWishlistProvider.notifier).state = existing.copyWith(
      items: List<WishlistItem>.of(_items),
      isPrivate: _isPrivate,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _RegistryHeader(title: widget.wishlistName),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      _SuccessBanner(itemCount: _items.length),
                      const SizedBox(height: 18),
                      for (final item in _items) ...[
                        _RegistryItemCard(
                          item: item,
                          onViewStore: () => _openStore(item),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _AddUrlCard(
                        controller: _urlController,
                        isLoading: _isAddingItem,
                        onAdd: _isAddingItem ? null : _addItemByUrl,
                      ),
                      const SizedBox(height: 16),
                      _SharingCard(
                        isPrivate: _isPrivate,
                        onPrivateChanged: (value) {
                          setState(() => _isPrivate = value);
                          _syncSavedWishlist();
                        },
                        onCopyLink: _copyLink,
                        onWhatsApp: () =>
                            _showMessage('WhatsApp sharing coming soon.'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistryHeader extends StatelessWidget {
  const _RegistryHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.eventBackground,
      child: Column(
        children: [
          SizedBox(
            height: 58,
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.eventBlack,
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineMd(
                      color: AppColors.eventBlack,
                    ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                  color: AppColors.eventBlack,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.eventBorder),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final itemWord = itemCount == 1 ? 'item is' : 'items are';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.eventPrimary, AppColors.eventPrimaryLight],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.onPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.eventPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wishlist Saved Successfully',
                  style: AppTextStyles.labelMd(
                    color: AppColors.onPrimary,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
                const SizedBox(height: 5),
                Text(
                  'Your $itemCount $itemWord now ready for sharing.',
                  style: AppTextStyles.labelSm(
                    color: AppColors.eventSoftText,
                  ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistryItemCard extends StatelessWidget {
  const _RegistryItemCard({required this.item, required this.onViewStore});

  final WishlistItem item;
  final VoidCallback onViewStore;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.eventBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 18,
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
                child: SizedBox(
                  height: 176,
                  width: double.infinity,
                  child: item.imageUrl.isEmpty
                      ? _RegistryImageFallback(category: item.category)
                      : Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _RegistryImageFallback(
                              category: item.category,
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
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
                  child: Text(
                    item.price.isEmpty ? 'Price pending' : item.price,
                    style: AppTextStyles.labelMd(
                      color: AppColors.eventBlack,
                    ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.toUpperCase(),
                  style: AppTextStyles.labelSm(
                    color: AppColors.eventMutedForeground,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                ),
                const SizedBox(height: 7),
                Text(
                  item.title,
                  style: AppTextStyles.headlineMd(
                    color: AppColors.eventBlack,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.sourceDomain,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd(
                          color: AppColors.eventMutedForeground,
                        ).copyWith(letterSpacing: 0),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onViewStore,
                      icon: const Icon(Icons.open_in_new_rounded, size: 17),
                      label: const Text('View Store'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.eventPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle:
                            AppTextStyles.labelMd(
                              color: AppColors.eventPrimary,
                            ).copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
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

class _RegistryImageFallback extends StatelessWidget {
  const _RegistryImageFallback({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final icon = switch (category.toUpperCase()) {
      'KITCHEN ESSENTIALS' => Icons.coffee_maker_rounded,
      'HOME DECOR' => Icons.local_florist_rounded,
      'BEDROOM' => Icons.bed_rounded,
      _ => Icons.card_giftcard_rounded,
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF1EE), Color(0xFFF8FAF9)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -24,
            child: Icon(
              icon,
              size: 128,
              color: AppColors.eventPrimaryLight.withValues(alpha: 0.12),
            ),
          ),
          Center(child: Icon(icon, size: 54, color: AppColors.eventPrimary)),
        ],
      ),
    );
  }
}

class _AddUrlCard extends StatelessWidget {
  const _AddUrlCard({
    required this.controller,
    required this.isLoading,
    required this.onAdd,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return _RegistryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Add item by URL'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RegistryInput(
                  controller: controller,
                  hint: 'Paste Amazon, Etsy, or any',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 52,
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.eventPrimary,
                    foregroundColor: AppColors.onPrimary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.onPrimary,
                            strokeWidth: 2.4,
                          ),
                        )
                      : const Icon(Icons.add_rounded, size: 27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _HelperText("We'll try to fetch the image and price for you."),
        ],
      ),
    );
  }
}

class _SharingCard extends StatelessWidget {
  const _SharingCard({
    required this.isPrivate,
    required this.onPrivateChanged,
    required this.onCopyLink,
    required this.onWhatsApp,
  });

  final bool isPrivate;
  final ValueChanged<bool> onPrivateChanged;
  final VoidCallback onCopyLink;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return _RegistryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _CardTitle('Privacy Settings'),
                    SizedBox(height: 5),
                    _HelperText('Make your wishlist discoverable'),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Private',
                    style: AppTextStyles.labelMd(
                      color: AppColors.eventMutedForeground,
                    ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: isPrivate,
                    activeThumbColor: AppColors.eventAccent,
                    activeTrackColor: AppColors.eventSelectedBackground,
                    onChanged: onPrivateChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.eventBorder),
          const SizedBox(height: 16),
          const _CardTitle('Share With Collaborators'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ShareButton(
                  label: 'Copy Link',
                  icon: Icons.link_rounded,
                  onPressed: onCopyLink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShareButton(
                  label: 'WhatsApp',
                  icon: Icons.share_rounded,
                  filled: true,
                  onPressed: onWhatsApp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.eventAccent : AppColors.eventBlack;
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled
              ? AppColors.eventSelectedBackground
              : AppColors.eventBackground,
          foregroundColor: foreground,
          side: BorderSide(
            color: filled
                ? AppColors.eventSelectedBackground
                : AppColors.eventBorder,
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

class _RegistryCard extends StatelessWidget {
  const _RegistryCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.eventBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RegistryInput extends StatelessWidget {
  const _RegistryInput({
    required this.controller,
    required this.hint,
    required this.textInputAction,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: AppTextStyles.bodyMd(
        color: AppColors.eventBlack,
      ).copyWith(fontSize: 15, letterSpacing: 0),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMd(
          color: AppColors.eventMutedForeground,
        ).copyWith(fontSize: 14, letterSpacing: 0),
        filled: true,
        fillColor: AppColors.eventMutedBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.eventPrimary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMd(
        color: AppColors.eventBlack,
      ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
    );
  }
}

class _HelperText extends StatelessWidget {
  const _HelperText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelSm(
        color: AppColors.eventMutedForeground,
      ).copyWith(fontWeight: FontWeight.w500, letterSpacing: 0),
    );
  }
}

const _demoRegistryItems = [
  WishlistItem(
    url: 'https://www.amazon.com/',
    title: 'Smart Precision Coffee Maker',
    imageUrl:
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=900&q=80',
    price: r'$249.00',
    sourceDomain: 'Amazon.com',
    category: 'KITCHEN ESSENTIALS',
  ),
  WishlistItem(
    url: 'https://www.williams-sonoma.com/',
    title: 'Artisan Crystal Vase Set',
    imageUrl:
        'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?auto=format&fit=crop&w=900&q=80',
    price: r'$120.00',
    sourceDomain: 'Williams Sonoma',
    category: 'HOME DECOR',
  ),
  WishlistItem(
    url: 'https://www.brooklinen.com/',
    title: 'Stone-Washed Linen King Set',
    imageUrl:
        'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?auto=format&fit=crop&w=900&q=80',
    price: r'$315.00',
    sourceDomain: 'Brooklinen',
    category: 'BEDROOM',
  ),
];
