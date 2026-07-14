import 'package:flutter/material.dart';
import '../theme/admin_colors.dart';

/// A vendor's live-directory status. Active/Pending/Suspended are
/// admin-reversible; Blocked and Rejected are terminal (blocked requires
/// confirmation and isn't reversible from the UI; rejected applications
/// simply never became a vendor).
enum VendorStatus { active, pending, suspended, blocked, rejected }

extension VendorStatusX on VendorStatus {
  String get label {
    switch (this) {
      case VendorStatus.active:
        return 'Active';
      case VendorStatus.pending:
        return 'Pending';
      case VendorStatus.suspended:
        return 'Suspended';
      case VendorStatus.blocked:
        return 'Blocked';
      case VendorStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case VendorStatus.active:
        return AdminColors.tertiary;
      case VendorStatus.pending:
        return AdminColors.warning;
      case VendorStatus.suspended:
        return AdminColors.warning;
      case VendorStatus.blocked:
      case VendorStatus.rejected:
        return AdminColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case VendorStatus.active:
        return Icons.check_circle;
      case VendorStatus.pending:
        return Icons.hourglass_top;
      case VendorStatus.suspended:
        return Icons.pause_circle_outlined;
      case VendorStatus.blocked:
        return Icons.block;
      case VendorStatus.rejected:
        return Icons.cancel_outlined;
    }
  }
}

/// A vendor's master directory record — the row shown in "All Vendors".
class AdminVendor {
  AdminVendor({
    required this.id,
    required this.businessName,
    required this.category,
    this.subcategory = '',
    required this.city,
    this.state = '',
    this.neighborhood = '',
    required this.status,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String businessName;
  String category;
  String subcategory;
  String city;
  String state;
  String neighborhood;
  VendorStatus status;
  double ratingAvg;
  int ratingCount;
  DateTime createdAt;
  DateTime updatedAt;

  String get location => state.isEmpty ? city : '$city, $state';
  String get categoryLabel => subcategory.isEmpty ? category : '$category / $subcategory';
}
