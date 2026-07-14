import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business.dart';
import '../models/vendor.dart';

/// The signed-in vendor. Null until Set Up Profile completes.
final vendorProvider = StateProvider<Vendor?>((ref) => null);

/// All businesses the vendor owns.
class BusinessesNotifier extends Notifier<List<Business>> {
  @override
  List<Business> build() => [];

  void add(Business business) => state = [...state, business];

  void remove(Business business) => state = state.where((b) => b.id != business.id).toList();

  /// Business fields (and their services/packages/features lists) are
  /// mutated in place by the existing Add/Edit screens. Riverpod only
  /// notifies watchers when a provider's *state* changes, so anything that
  /// mutates a business in place must call this afterwards to bump the
  /// list's identity and trigger a rebuild.
  void touch() => state = [...state];

  void clear() => state = [];
}

final businessesProvider = NotifierProvider<BusinessesNotifier, List<Business>>(BusinessesNotifier.new);

/// Which business is currently in focus across the Dashboard/Services/
/// Analytics tabs. Null means "use the first business" (see
/// [activeBusinessOf]).
final activeBusinessIdProvider = StateProvider<String?>((ref) => null);

/// Resolves the active business out of [businesses] given [activeId],
/// falling back to the first business. Deliberately a plain function (not a
/// derived `Provider<Business?>`): a derived provider would compare the
/// *returned Business instance* for equality, and since businesses are
/// mutated in place rather than replaced, it would never see a "change" to
/// notify — calling this directly inside each tab's build() (which already
/// watches businessesProvider) rebuilds correctly instead.
Business? activeBusinessOf(List<Business> businesses, String? activeId) {
  if (businesses.isEmpty) return null;
  for (final business in businesses) {
    if (business.id == activeId) return business;
  }
  return businesses.first;
}
