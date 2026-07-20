import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/currency_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/wishlist_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import 'wedding_registry_screen.dart';

const bool _skipWishlistBackend = bool.fromEnvironment(
  'SKIP_WISHLIST_BACKEND',
  defaultValue: false,
);
const bool _skipCreateEventBackend = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class CreateWishlistScreen extends ConsumerStatefulWidget {
  const CreateWishlistScreen({super.key});

  @override
  ConsumerState<CreateWishlistScreen> createState() =>
      _CreateWishlistScreenState();
}

class _CreateWishlistScreenState extends ConsumerState<CreateWishlistScreen> {
  final _wishlistNameController = TextEditingController();
  final _urlController = TextEditingController();
  final List<WishlistItem> _items = [];
  var _isPrivate = false;
  var _isAddingItem = false;
  var _isSaving = false;

  bool get _useLocalWishlistData =>
      _skipWishlistBackend || _skipCreateEventBackend;

  @override
  void dispose() {
    _wishlistNameController.dispose();
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
          : await ref
                .read(wishlistApiServiceProvider)
                .addItemByUrl(url, currencyCode: ref.read(currencyProvider));

      if (!mounted) return;

      setState(() {
        _items.insert(0, item);
        _urlController.clear();
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isAddingItem = false);
      }
    }
  }

  Future<void> _saveWishlist() async {
    final name = _wishlistNameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Name your wishlist before saving.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (!_useLocalWishlistData) {
        await ref
            .read(wishlistApiServiceProvider)
            .saveWishlist(
              SaveWishlistRequest(
                name: name,
                isPrivate: _isPrivate,
                items: _items,
              ),
            );
      }

      ref.read(savedWishlistProvider.notifier).state = SavedWishlist(
        name: name,
        items: List<WishlistItem>.of(_items),
        isPrivate: _isPrivate,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WeddingRegistryScreen(
            wishlistName: name,
            initialItems: List<WishlistItem>.of(_items),
            initialIsPrivate: _isPrivate,
            showDemoItems: false,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _copyLink() {
    Clipboard.setData(
      const ClipboardData(text: 'https://eventflow.app/wishlist'),
    );
    _showMessage('Wishlist link copied.');
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
            const _WishlistHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    children: [
                      _WishlistNameCard(controller: _wishlistNameController),
                      const SizedBox(height: 16),
                      _AddUrlCard(
                        controller: _urlController,
                        isLoading: _isAddingItem,
                        onAdd: _isAddingItem ? null : _addItemByUrl,
                      ),
                      if (_items.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _AddedItemsSection(items: _items),
                      ],
                      const SizedBox(height: 16),
                      _PrivacyCard(
                        isPrivate: _isPrivate,
                        onPrivateChanged: (value) {
                          setState(() => _isPrivate = value);
                        },
                        onCopyLink: _copyLink,
                        onWhatsApp: () =>
                            _showMessage('WhatsApp sharing coming soon.'),
                      ),
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ),
            _BottomSaveBar(
              isSaving: _isSaving,
              onPressed: _isSaving ? null : _saveWishlist,
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistHeader extends StatelessWidget {
  const _WishlistHeader();

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
                    'Create Wishlist',
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

class _WishlistNameCard extends StatelessWidget {
  const _WishlistNameCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _WishlistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Name your wishlist'),
          const SizedBox(height: 12),
          _WishlistInput(
            controller: controller,
            hint: 'e.g., Dream Wedding Decor',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          const _HelperText(
            'Give your collection a memorable name for easy sharing.',
          ),
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
    return _WishlistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Add item by URL'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _WishlistInput(
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

class _AddedItemsSection extends StatelessWidget {
  const _AddedItemsSection({required this.items});

  final List<WishlistItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Items',
          style: AppTextStyles.headlineMd(
            color: AppColors.eventBlack,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) =>
              _WishlistItemCard(item: items[index]),
        ),
      ],
    );
  }
}

class _WishlistItemCard extends StatelessWidget {
  const _WishlistItemCard({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.eventBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.dflt),
                    child: item.imageUrl.isEmpty
                        ? const _ItemImageFallback()
                        : Image.network(
                            item.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const _ItemImageFallback();
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd(
                    color: AppColors.eventBlack,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatWishlistItemMeta(context, item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm(
                    color: AppColors.eventMutedForeground,
                  ).copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.eventPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.onPrimary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemImageFallback extends StatelessWidget {
  const _ItemImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.eventMutedBackground,
      child: const Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          color: AppColors.eventMutedForeground,
          size: 36,
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
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
    return _WishlistCard(
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

class _BottomSaveBar extends StatelessWidget {
  const _BottomSaveBar({required this.isSaving, required this.onPressed});

  final bool isSaving;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(color: AppColors.eventPageBackground),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2.4,
                  ),
                )
              : const Icon(Icons.save_rounded, size: 20),
          label: Text(isSaving ? 'Saving...' : 'Save & Create Wishlist'),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.eventPrimary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            textStyle: AppTextStyles.labelMd(
              color: AppColors.onPrimary,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
          ),
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.child});

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

String _formatWishlistItemMeta(BuildContext context, WishlistItem item) {
  final price = _formatWishlistItemPrice(context, item);
  return price == null ? item.sourceDomain : '$price • ${item.sourceDomain}';
}

String? _formatWishlistItemPrice(BuildContext context, WishlistItem item) {
  if (item.priceAmount != null &&
      item.priceCurrency != null &&
      item.priceCurrency!.trim().isNotEmpty) {
    return formatMoney(
      Money(amount: item.priceAmount!, currencyCode: item.priceCurrency!),
      context,
    );
  }

  return item.price.trim().isEmpty ? null : item.price;
}

class _WishlistInput extends StatelessWidget {
  const _WishlistInput({
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
