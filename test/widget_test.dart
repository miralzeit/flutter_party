import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_party/main.dart';
import 'package:flutter_party/models/marketplace_vendor.dart';
import 'package:flutter_party/providers/event_provider.dart';
import 'package:flutter_party/providers/vendor_marketplace_provider.dart';
import 'package:flutter_party/services/wishlist_api_service.dart';
import 'package:flutter_party/providers/wishlist_provider.dart';
import 'package:flutter_party/services/event_api_service.dart';
import 'package:flutter_party/services/vendor_api_service.dart';

void main() {
  testWidgets('EventFlow home screen renders', (WidgetTester tester) async {
    final fakeEventApiService = _FakeEventApiService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorApiServiceProvider.overrideWithValue(_FakeVendorApiService()),
          eventApiServiceProvider.overrideWithValue(fakeEventApiService),
          wishlistApiServiceProvider.overrideWithValue(
            _FakeWishlistApiService(),
          ),
        ],
        child: const EventProApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
    await tester.ensureVisible(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('EventFlow'), findsOneWidget);
    expect(find.text('Your Dream Event Starts Here'), findsOneWidget);
    expect(find.text('Browse Categories'), findsOneWidget);
    expect(find.text('Nearby Vendors'), findsOneWidget);
    expect(find.text('The Evergreen Pavilion'), findsOneWidget);
    expect(find.text('Petal & Brush Artistry'), findsOneWidget);

    await tester.tap(find.text('Start Planning Your Event'));
    await tester.pumpAndSettle();

    expect(find.text('Plan your event'), findsOneWidget);
    expect(find.text('Wedding'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).first,
      'Smith & Co. Wedding',
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -420));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).last, 'San Francisco, CA');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -420));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(fakeEventApiService.createdEvent?.eventType, 'Wedding');
    expect(fakeEventApiService.createdEvent?.eventName, 'Smith & Co. Wedding');
    expect(fakeEventApiService.createdEvent?.location, 'San Francisco, CA');
    expect(fakeEventApiService.createdEvent?.eventDate, isNotNull);
    expect(find.textContaining('days left'), findsOneWidget);
    expect(find.text('View Checklist'), findsOneWidget);
    expect(find.text('Create Wishlist'), findsOneWidget);
    expect(find.text('Add Event'), findsOneWidget);

    await tester.tap(find.text('Create Wishlist'));
    await tester.pumpAndSettle();

    expect(find.text('Create Wishlist'), findsOneWidget);
    expect(find.text('Name your wishlist'), findsOneWidget);
    expect(find.text('Add item by URL'), findsOneWidget);
    expect(find.text('Privacy Settings'), findsOneWidget);
    expect(find.text('Save & Create Wishlist'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).at(0), 'Wedding Registry');
    await tester.enterText(
      find.byType(EditableText).at(1),
      'https://etsy.com/listing/demo-lamp',
    );
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('Add Items'), findsOneWidget);
    expect(find.text('Demo Registry Lamp'), findsOneWidget);
    expect(find.textContaining('etsy.com'), findsOneWidget);

    await tester.tap(find.text('Save & Create Wishlist'));
    await tester.pumpAndSettle();

    expect(find.text('Wedding Registry'), findsOneWidget);
    expect(find.text('Wishlist Saved Successfully'), findsOneWidget);
    expect(find.text('Your 1 item is now ready for sharing.'), findsOneWidget);
    expect(find.text('Demo Registry Lamp'), findsOneWidget);
    expect(find.text('View Store'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('EventFlow'), findsOneWidget);
    expect(find.text('View Wishlist'), findsOneWidget);
    expect(find.text('Create Wishlist'), findsNothing);

    await tester.tap(find.text('View Wishlist'));
    await tester.pumpAndSettle();

    expect(find.text('Wedding Registry'), findsOneWidget);
    expect(find.text('Demo Registry Lamp'), findsOneWidget);
  });
}

class _FakeVendorApiService extends VendorApiService {
  @override
  Future<PaginatedVendors> getVendors({
    required int page,
    int limit = 10,
    String? location,
  }) async {
    return const PaginatedVendors(
      vendors: [
        MarketplaceVendor(
          id: 'vendor_1',
          name: 'The Evergreen Pavilion',
          rating: 4.9,
          priceLevel: '\$\$\$',
          description:
              'Premium banquet hall with forest-themed decor and full catering services.',
          imageUrl: '',
          phone: '',
          whatsapp: '',
        ),
        MarketplaceVendor(
          id: 'vendor_2',
          name: 'Petal & Brush Artistry',
          rating: 4.7,
          priceLevel: '\$\$',
          description:
              'Expert bridal makeup and hair styling for a timeless, natural look.',
          imageUrl: '',
          phone: '',
          whatsapp: '',
        ),
      ],
      page: 1,
      limit: 10,
      hasNextPage: false,
    );
  }
}

class _FakeEventApiService extends EventApiService {
  CreateEventRequest? createdEvent;

  @override
  Future<void> createEvent(CreateEventRequest event) async {
    createdEvent = event;
  }
}

class _FakeWishlistApiService extends WishlistApiService {
  String? addedUrl;
  SaveWishlistRequest? savedWishlist;

  @override
  Future<WishlistItem> addItemByUrl(String url) async {
    addedUrl = url;
    return WishlistItem(
      url: url,
      title: 'Demo Registry Lamp',
      imageUrl: '',
      price: '\$49',
      sourceDomain: 'etsy.com',
      category: 'HOME DECOR',
    );
  }

  @override
  Future<void> saveWishlist(SaveWishlistRequest wishlist) async {
    savedWishlist = wishlist;
  }
}
