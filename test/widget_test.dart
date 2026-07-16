import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_party/main.dart';
import 'package:flutter_party/models/marketplace_vendor.dart';
import 'package:flutter_party/services/chat_api_service.dart';
import 'package:flutter_party/providers/chat_provider.dart';
import 'package:flutter_party/services/checklist_api_service.dart';
import 'package:flutter_party/providers/checklist_provider.dart';
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
          chatApiServiceProvider.overrideWithValue(_FakeChatApiService()),
          checklistApiServiceProvider.overrideWithValue(
            _FakeChecklistApiService(),
          ),
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

    await tester.tap(find.text('View Checklist'));
    await tester.pumpAndSettle();

    expect(find.text('Smith & Co. Wedding'), findsOneWidget);
    expect(find.text('EVENT MILESTONE'), findsOneWidget);
    expect(find.text('0 / 0 Tasks\nCompleted'), findsOneWidget);
    expect(find.text('Upcoming: 0'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);

    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(EditableText).last,
      'Confirm florist booking',
    );
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm florist booking'), findsOneWidget);
    expect(find.text('0 / 1 Tasks\nCompleted'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Upcoming: 1'), findsOneWidget);

    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(EditableText).last,
      'Book ceremony music',
    );
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.text('1 / 2 Tasks\nCompleted'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Upcoming: 1'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Book ceremony music')).dy,
      lessThan(tester.getTopLeft(find.text('Confirm florist booking')).dy),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('1/2 TASKS DONE'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Evergreen Assistant'), findsOneWidget);
    expect(find.text('ONLINE'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).last,
      'Suggest a venue in Bethlehem',
    );
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Suggest a venue in Bethlehem'), findsWidgets);
    expect(
      find.text('AI reply for: Suggest a venue in Bethlehem'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Checklist'));
    await tester.pumpAndSettle();

    expect(find.text('Smith & Co. Wedding'), findsOneWidget);
    expect(find.text('Book ceremony music'), findsOneWidget);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Evergreen Assistant'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Evergreen User'), findsOneWidget);
    expect(find.text('user@evergreen.events'), findsOneWidget);
    expect(find.text('1 Active Events'), findsOneWidget);
    expect(find.text('Tasks Pending'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('ACCOUNT SETTINGS'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('ACCOUNT SETTINGS'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('PREFERENCES'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('PREFERENCES'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('MY EVENTS'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('MY EVENTS'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('SUPPORT'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('SUPPORT'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

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

class _FakeChatApiService extends ChatApiService {
  String? lastMessage;

  @override
  Future<ChatReply> sendMessage(String message) async {
    lastMessage = message;
    return ChatReply(message: 'AI reply for: $message');
  }
}

class _FakeChecklistApiService extends ChecklistApiService {
  CreateChecklistTaskRequest? createdTask;
  var _nextId = 0;

  @override
  Future<ChecklistTask> createTask(CreateChecklistTaskRequest task) async {
    createdTask = task;
    _nextId += 1;
    return ChecklistTask(
      id: 'task_$_nextId',
      name: task.name,
      dueDate: task.dueDate,
    );
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
