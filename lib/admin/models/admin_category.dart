import 'package:flutter/material.dart';

/// Named icon options offered in the category icon picker. Stored as a
/// string key (matching the seed data's icon names) rather than an
/// [IconData] directly, so categories stay plain data.
const Map<String, IconData> adminCategoryIcons = {
  'restaurant': Icons.restaurant,
  'celebration': Icons.celebration,
  'apartment': Icons.apartment,
  'camera': Icons.camera_alt,
  'cake': Icons.cake,
  'brush': Icons.brush,
  'redeem': Icons.redeem,
  'history': Icons.history,
  'info': Icons.info_outline,
  'sync': Icons.sync,
  'sort': Icons.sort,
  'save': Icons.save_outlined,
};

IconData iconForKey(String key) => adminCategoryIcons[key] ?? Icons.category_outlined;

/// A vendor-facing category (Venues, Catering, ...) — the taxonomy shown in
/// search filters and listing forms across the platform.
class AdminCategory {
  AdminCategory({
    required this.id,
    required this.name,
    this.description = '',
    required this.icon,
    required this.displayOrder,
    this.isActive = true,
  });

  final String id;
  String name;
  String description;
  String icon;
  int displayOrder;
  bool isActive;

  AdminCategory copyWith({String? name, String? description, String? icon, int? displayOrder, bool? isActive}) {
    return AdminCategory(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
