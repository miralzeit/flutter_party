import 'package:flutter/material.dart';

/// A single label/value row shown under a service's "Additional Details"
/// (e.g. Capacity / 500 Guests, Duration / 90 Minutes).
class ServiceDetail {
  ServiceDetail({this.label = '', this.value = ''});

  String label;
  String value;
}

/// A single offering under a [Business] (e.g. "Bridal Makeup", "Chicken &
/// Rice Meal"). The same screen is reused for every business category, so
/// this model stays generic: name/description/price plus free-form details.
class Service {
  Service({
    required this.name,
    this.description = '',
    this.price,
    List<ServiceDetail>? details,
  }) : details = details ?? [];

  String name;
  String description;
  double? price;
  List<ServiceDetail> details;
}

/// A vendor's business (e.g. a wedding hall or a salon), with its own
/// photos, base price and list of [Service]s.
class Business {
  Business({
    required this.name,
    required this.category,
    this.description = '',
    this.basePrice,
    this.photoCount = 0,
    List<Service>? services,
  }) : services = services ?? [];

  String name;
  String category;
  String description;
  double? basePrice;
  int photoCount;
  List<Service> services;
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
