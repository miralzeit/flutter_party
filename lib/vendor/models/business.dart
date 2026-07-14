import 'package:flutter/material.dart';

/// A single label/value row shown under a service's "Additional Details"
/// (e.g. Capacity / 500 Guests, Duration / 90 Minutes).
class ServiceDetail {
  ServiceDetail({this.label = '', this.value = ''});

  String label;
  String value;
}

const List<String> serviceCategories = ['Standard', 'Premium', 'Add-on', 'Seasonal', 'Other'];

/// A single offering under a [Business] (e.g. "Bridal Makeup", "Chicken &
/// Rice Meal"). The same screen is reused for every business category, so
/// this model stays generic: name/description/price plus free-form details.
class Service {
  Service({
    required this.name,
    this.category = '',
    this.description = '',
    this.price,
    this.photoCount = 0,
    List<ServiceDetail>? details,
  }) : details = details ?? [];

  String name;
  String category;
  String description;
  double? price;
  int photoCount;
  List<ServiceDetail> details;
}

/// A bundle of a business's existing [Service]s sold together at a single
/// price (e.g. "Silver Wedding Package" = hall rental + a meal + a dessert
/// table).
class Package {
  Package({
    required this.name,
    this.description = '',
    this.price,
    List<Service>? includedServices,
  }) : includedServices = includedServices ?? [];

  String name;
  String description;
  double? price;
  List<Service> includedServices;

  /// What the included services would cost if bought individually.
  double get originalPrice => includedServices.fold(0.0, (sum, service) => sum + (service.price ?? 0));

  /// How much a customer saves by buying the package instead of each
  /// service separately. Null when there's no package price yet, or when
  /// the package isn't actually cheaper than buying separately.
  double? get savings {
    if (price == null) return null;
    final diff = originalPrice - price!;
    return diff > 0 ? diff : null;
  }
}

/// One question/answer pair in a business's FAQ list.
class Faq {
  Faq({this.question = '', this.answer = ''});

  String question;
  String answer;
}

int _businessIdCounter = 0;
String _nextBusinessId() => 'biz_${DateTime.now().microsecondsSinceEpoch}_${_businessIdCounter++}';

/// Whether a business is visible to customers yet. Derived on [Business],
/// never set directly by a screen — see [Business.status].
enum BusinessStatus { underReview, active, paused }

/// A vendor's business (e.g. a wedding hall or a salon), with its own
/// photos, base price and list of [Service]s and [Package]s.
class Business {
  Business({
    String? id,
    required this.name,
    required this.category,
    this.description = '',
    this.basePrice,
    this.location = '',
    this.address = '',
    this.whatsapp = '',
    this.instagram = '',
    this.facebook = '',
    this.photoCount = 0,
    this.isPaused = false,
    this.businessHours = '',
    this.capacity,
    this.hasCoverVideo = false,
    List<Service>? services,
    List<Package>? packages,
    List<String>? features,
    List<Faq>? faqs,
  }) : id = id ?? _nextBusinessId(),
       services = services ?? [],
       packages = packages ?? [],
       features = features ?? [],
       faqs = faqs ?? [];

  final String id;
  String name;
  String category;
  String description;
  double? basePrice;
  /// The business's city — kept as "location" for backward compatibility
  /// with existing screens; shown to vendors simply as "City".
  String location;
  String address;
  String whatsapp;
  String instagram;
  String facebook;
  int photoCount;
  bool isPaused;
  /// Free-form opening hours, e.g. "Mon–Sat, 9am–9pm".
  String businessHours;
  /// Guest capacity, mainly relevant for venues (halls, catering).
  int? capacity;
  bool hasCoverVideo;
  List<Service> services;
  List<Package> packages;
  List<String> features;
  List<Faq> faqs;

  /// Paused is a vendor choice; otherwise a business only goes live once it
  /// has at least one service and one photo — until then it reads as
  /// "Under Review" rather than a hardcoded always-pending badge.
  BusinessStatus get status {
    if (isPaused) return BusinessStatus.paused;
    if (services.isNotEmpty && photoCount > 0) return BusinessStatus.active;
    return BusinessStatus.underReview;
  }
}

const List<String> businessCategories = [
  'Wedding Hall',
  'Salon',
  'Catering',
  'Photography',
  'Decoration',
  'DJ & Music',
  'Other',
];

IconData businessCategoryIcon(String category) {
  switch (category) {
    case 'Wedding Hall':
      return Icons.account_balance;
    case 'Salon':
      return Icons.face_retouching_natural;
    case 'Catering':
      return Icons.restaurant;
    case 'Photography':
      return Icons.camera_alt;
    case 'Decoration':
      return Icons.local_florist;
    case 'DJ & Music':
      return Icons.music_note;
    default:
      return Icons.storefront;
  }
}
