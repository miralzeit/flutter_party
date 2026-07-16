import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/wishlist_api_service.dart';

final wishlistApiServiceProvider = Provider<WishlistApiService>((ref) {
  return WishlistApiService();
});
