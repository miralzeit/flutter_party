/// Result of the automated verification pass (license validity, duplicate
/// check, ...) that runs before an application reaches human review.
enum VerificationStatus { verified, flagged, unverified }

extension VerificationStatusX on VerificationStatus {
  String get label {
    switch (this) {
      case VerificationStatus.verified:
        return 'Verified by System';
      case VerificationStatus.flagged:
        return 'Flagged for Review';
      case VerificationStatus.unverified:
        return 'Awaiting System Check';
    }
  }
}

/// Where an application sits in the approval pipeline.
enum ApplicationStage { submitted, systemVerified, adminReview, approved, rejected, infoRequested }

extension ApplicationStageX on ApplicationStage {
  String get label {
    switch (this) {
      case ApplicationStage.submitted:
        return 'Submitted';
      case ApplicationStage.systemVerified:
        return 'System Verified';
      case ApplicationStage.adminReview:
        return 'Admin Review';
      case ApplicationStage.approved:
        return 'Approved';
      case ApplicationStage.rejected:
        return 'Rejected';
      case ApplicationStage.infoRequested:
        return 'Waiting on Vendor';
    }
  }

  bool get isOpen => this != ApplicationStage.approved && this != ApplicationStage.rejected;
}

/// One entry in an application's audit trail (Submitted -> System Verified
/// -> Admin Review -> Approved/Rejected), each attributed to who did it.
class ApplicationTimelineEvent {
  ApplicationTimelineEvent({
    required this.label,
    required this.actor,
    this.note = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String label;
  final String actor;
  final String note;
  final DateTime timestamp;
}

/// A vendor's onboarding application — the record reviewed on the
/// Application Detail screen and queued on Pending Vendors.
class VendorApplication {
  VendorApplication({
    required this.id,
    required this.vendorId,
    required this.businessName,
    required this.category,
    required this.city,
    this.neighborhood = '',
    this.businessDescription = '',
    this.businessLicenseId = '',
    this.address = '',
    this.contactName = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.systemVerificationStatus = VerificationStatus.unverified,
    required this.stage,
    DateTime? submittedAt,
    this.decidedAt,
    this.decidedBy,
    this.rejectionReason,
    List<ApplicationTimelineEvent>? timeline,
  })  : submittedAt = submittedAt ?? DateTime.now(),
        timeline = timeline ?? [];

  final String id;
  final String vendorId;
  String businessName;
  String category;
  String city;
  String neighborhood;
  String businessDescription;
  String businessLicenseId;
  String address;
  String contactName;
  String contactEmail;
  String contactPhone;
  VerificationStatus systemVerificationStatus;
  ApplicationStage stage;
  DateTime submittedAt;
  DateTime? decidedAt;
  String? decidedBy;
  String? rejectionReason;
  List<ApplicationTimelineEvent> timeline;

  String get location => neighborhood.isEmpty ? city : '$city · $neighborhood';
}
