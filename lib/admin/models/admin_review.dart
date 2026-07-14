/// Whether a reviewer is a platform-verified guest or an unverified guest
/// account — shown as a trust badge next to their name.
enum ReviewerType { verifiedGuest, guest }

extension ReviewerTypeX on ReviewerType {
  String get label => this == ReviewerType.verifiedGuest ? 'Verified Guest' : 'Guest';
}

/// Why a review was reported. Multiple reasons can stack on one review.
enum ReportReason { spam, fakeReview, hateSpeech, newAccount, onlyReview }

extension ReportReasonX on ReportReason {
  String get label {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.fakeReview:
        return 'Fake Review';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.newAccount:
        return 'New Account';
      case ReportReason.onlyReview:
        return 'Only Review';
    }
  }
}

/// Keep = stays published, flag cleared. Hide = unpublished but retained
/// (reversible). Delete = permanently removed.
enum ModerationStatus { published, hidden, deleted }

/// A single customer review of a vendor, as seen by the moderation queue.
class AdminReview {
  AdminReview({
    required this.id,
    required this.vendorName,
    required this.reviewerName,
    required this.reviewerType,
    required this.rating,
    required this.date,
    this.body = '',
    List<ReportReason>? reportReasons,
    this.moderationStatus = ModerationStatus.published,
    this.moderatedBy,
    this.moderatedAt,
  }) : reportReasons = reportReasons ?? [];

  final String id;
  String vendorName;
  String reviewerName;
  ReviewerType reviewerType;
  int rating;
  DateTime date;
  String body;
  List<ReportReason> reportReasons;
  ModerationStatus moderationStatus;
  String? moderatedBy;
  DateTime? moderatedAt;

  bool get isReported => reportReasons.isNotEmpty;
}
