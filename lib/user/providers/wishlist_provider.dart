import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/wishlist_api_service.dart';

final wishlistApiServiceProvider = Provider<WishlistApiService>((ref) {
  return WishlistApiService();
});

class SavedWishlist {
  const SavedWishlist({
    required this.name,
    required this.items,
    required this.isPrivate,
  });

  final String name;
  final List<WishlistItem> items;
  final bool isPrivate;

  SavedWishlist copyWith({
    String? name,
    List<WishlistItem>? items,
    bool? isPrivate,
  }) {
    return SavedWishlist(
      name: name ?? this.name,
      items: items ?? this.items,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}

final savedWishlistProvider = StateProvider<SavedWishlist?>((ref) => null);
