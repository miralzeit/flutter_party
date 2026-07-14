import 'dart:math';
import '../models/business.dart';

/// Where a checklist/suggestion item's "complete it" action should navigate.
/// Kept as an enum (rather than a closure) so this service stays a pure,
/// testable data layer — the Dashboard maps each value to a real
/// `Navigator.push` in one place.
enum QualityAction { editProfile, addService, createPackage, uploadPhotos, manageFeatures, businessDetails }

/// One row of the "Business Quality" checklist — done or missing, worth a
/// number of points, with a plain-language reason a vendor would actually
/// care about. [searchRelevant] items also show up in AI Search
/// Optimization with their own [matchCaption].
class ChecklistItem {
  ChecklistItem({
    required this.label,
    required this.done,
    required this.points,
    required this.whyItMatters,
    required this.action,
    this.searchRelevant = false,
    this.matchCaption,
  });

  final String label;
  final bool done;
  final int points;
  final String whyItMatters;
  final QualityAction action;
  final bool searchRelevant;
  final String? matchCaption;
}

/// The vendor's overall "Business Quality Score" — a checklist scored out
/// of its own max (so every business category can reach 100%, since not
/// every item applies to every category).
class QualityScoreResult {
  QualityScoreResult({required this.items});

  final List<ChecklistItem> items;

  int get score => items.where((i) => i.done).fold(0, (sum, i) => sum + i.points);
  int get maxScore => items.fold(0, (sum, i) => sum + i.points);
  int get percentage => maxScore == 0 ? 100 : (score / maxScore * 100).round();
  List<ChecklistItem> get done => items.where((i) => i.done).toList();
  List<ChecklistItem> get missing => items.where((i) => !i.done).toList();

  String get tierLabel {
    final p = percentage;
    if (p >= 90) return 'Excellent';
    if (p >= 70) return 'Great';
    if (p >= 50) return 'Almost There';
    return 'Getting Started';
  }

  int get starCount {
    final p = percentage;
    if (p >= 90) return 5;
    if (p >= 70) return 4;
    if (p >= 50) return 3;
    if (p >= 25) return 2;
    return 1;
  }

  /// A mocked "more complete than N% of vendors" figure — monotonic in
  /// [percentage] rather than random, so it always tracks the score.
  int get percentileBeatsVendors => (percentage * 0.97).round().clamp(1, 99);
}

/// AI Search Optimization — how many of the AI-matching-relevant checklist
/// items (capacity, parking, hours, ...) are filled in, plus a mocked
/// "you currently appear in N searches" figure.
class AiSearchOptimization {
  AiSearchOptimization({required this.percentage, required this.searchAppearances, required this.missing});

  final int percentage;
  final int searchAppearances;
  final List<ChecklistItem> missing;
}

/// A single "complete this to grow" recommendation with a mocked expected
/// impact (profile visibility / views / clicks).
class Suggestion {
  Suggestion({required this.title, required this.expectedImpact, required this.action, this.pointsLabel});

  final String title;
  final String? pointsLabel;
  final String expectedImpact;
  final QualityAction action;
}

/// The single highest-value "customers are searching for X but can't find
/// you" spotlight card.
class AiInsight {
  AiInsight({required this.searchPhrase, required this.missingLabel, required this.searchCount, required this.action});

  final String searchPhrase;
  final String missingLabel;
  final int searchCount;
  final QualityAction action;
}

const _venueLikeCategories = {'Wedding Hall', 'Catering', 'Decoration'};

QualityScoreResult computeQualityScore(Business business) {
  final isVenueLike = _venueLikeCategories.contains(business.category);
  bool hasFeature(String keyword) => business.features.any((f) => f.toLowerCase().contains(keyword));

  final items = [
    ChecklistItem(
      label: 'Business Information',
      points: 15,
      action: QualityAction.editProfile,
      done: business.description.trim().isNotEmpty,
      whyItMatters: 'A complete description helps customers understand what makes your business unique.',
    ),
    ChecklistItem(
      label: 'Services',
      points: 15,
      action: QualityAction.addService,
      done: business.services.isNotEmpty,
      whyItMatters: "Customers can't book what they can't see — list every service you offer.",
    ),
    ChecklistItem(
      label: 'Photos',
      points: 15,
      action: QualityAction.uploadPhotos,
      done: business.photoCount > 0,
      whyItMatters: 'Listings with photos get far more clicks than listings without.',
    ),
    ChecklistItem(
      label: 'Contact Information',
      points: 10,
      action: QualityAction.editProfile,
      done: business.whatsapp.isNotEmpty || business.instagram.isNotEmpty || business.facebook.isNotEmpty,
      whyItMatters: "Customers need an easy way to reach you once they're interested.",
    ),
    ChecklistItem(
      label: 'Pricing',
      points: 10,
      action: QualityAction.editProfile,
      done: business.basePrice != null,
      whyItMatters: 'Upfront pricing builds trust and filters in customers who can afford you.',
    ),
    ChecklistItem(
      label: 'Packages',
      points: 8,
      action: QualityAction.createPackage,
      done: business.packages.isNotEmpty,
      whyItMatters: 'Bundled packages raise average order value and give customers an easy default choice.',
    ),
    ChecklistItem(
      label: 'Business Hours',
      points: 3,
      action: QualityAction.businessDetails,
      done: business.businessHours.trim().isNotEmpty,
      whyItMatters: 'Customers can search for vendors available on specific days.',
      searchRelevant: true,
      matchCaption: 'Match customers searching by availability',
    ),
    ChecklistItem(
      label: 'Cover Video',
      points: 5,
      action: QualityAction.businessDetails,
      done: business.hasCoverVideo,
      whyItMatters: 'A short video builds more trust than photos alone and keeps customers on your profile longer.',
    ),
    ChecklistItem(
      label: 'FAQs',
      points: 4,
      action: QualityAction.businessDetails,
      done: business.faqs.isNotEmpty,
      whyItMatters: 'Answering common questions upfront reduces back-and-forth before a booking.',
    ),
    if (isVenueLike)
      ChecklistItem(
        label: 'Capacity',
        points: 5,
        action: QualityAction.businessDetails,
        done: business.capacity != null,
        whyItMatters: "Customers search by guest count — without it, you won't appear in those results.",
        searchRelevant: true,
        matchCaption: 'Increase discoverability',
      ),
    if (isVenueLike)
      ChecklistItem(
        label: 'Parking Information',
        points: 3,
        action: QualityAction.manageFeatures,
        done: hasFeature('parking'),
        whyItMatters: 'Customers often search for venues with parking.',
        searchRelevant: true,
        matchCaption: 'Match customers who need parking',
      ),
    if (isVenueLike)
      ChecklistItem(
        label: 'Outdoor Area',
        points: 2,
        action: QualityAction.manageFeatures,
        done: hasFeature('outdoor'),
        whyItMatters: 'Needed to match outdoor wedding searches.',
        searchRelevant: true,
        matchCaption: 'Match outdoor wedding searches',
      ),
    if (isVenueLike)
      ChecklistItem(
        label: 'Generator',
        points: 2,
        action: QualityAction.manageFeatures,
        done: hasFeature('generator'),
        whyItMatters: 'A popular search during summer weddings, when power cuts are a concern.',
        searchRelevant: true,
        matchCaption: 'Match customers requesting backup electricity',
      ),
    ChecklistItem(
      label: 'Accessibility Features',
      points: 3,
      action: QualityAction.manageFeatures,
      done: hasFeature('access'),
      whyItMatters: 'Helps you match customers who specifically need accessible venues.',
      searchRelevant: true,
      matchCaption: 'Match more customers',
    ),
  ];

  return QualityScoreResult(items: items);
}

AiSearchOptimization computeAiSearchOptimization(Business business, QualityScoreResult quality) {
  final relevant = quality.items.where((item) => item.searchRelevant).toList();
  final doneCount = relevant.where((item) => item.done).length;
  final percentage = relevant.isEmpty ? 100 : ((doneCount / relevant.length) * 100).round();

  final random = Random(business.id.hashCode ^ 0x9e3779b9);
  final baseAppearances = 30 + random.nextInt(70);
  final searchAppearances = (baseAppearances * (percentage / 100)).round().clamp(1, 999);

  return AiSearchOptimization(
    percentage: percentage,
    searchAppearances: searchAppearances,
    missing: relevant.where((item) => !item.done).toList(),
  );
}

List<Suggestion> computeSuggestions(Business business, QualityScoreResult quality) {
  final random = Random(business.id.hashCode ^ 0x1234567);
  final missingByValue = [...quality.missing]..sort((a, b) => b.points.compareTo(a.points));

  final suggestions = <Suggestion>[
    for (final item in missingByValue.take(2))
      Suggestion(
        title: 'Add ${item.label}',
        pointsLabel: '+${item.points} Quality Score',
        expectedImpact: '+${8 + random.nextInt(15)}% profile visibility',
        action: item.action,
      ),
  ];

  if (business.photoCount < 8) {
    suggestions.add(Suggestion(
      title: 'Upload ${8 - business.photoCount} more photos',
      expectedImpact: '+${10 + random.nextInt(15)}% more profile views',
      action: QualityAction.uploadPhotos,
    ));
  }
  if (business.packages.length < 2) {
    suggestions.add(Suggestion(
      title: 'Create another package',
      expectedImpact: '+${10 + random.nextInt(10)}% WhatsApp clicks',
      action: QualityAction.createPackage,
    ));
  }

  return suggestions.take(3).toList();
}

const _defaultSearchPhrases = {
  'Business Information': 'Trusted {category} near me',
  'Services': 'Best {category} services',
  'Photos': '{category} with real photos',
  'Contact Information': '{category} that responds fast',
  'Pricing': 'Affordable {category}',
  'Packages': 'Affordable {category} packages',
  'Business Hours': 'Vendors available on Sundays',
  'Cover Video': '{category} with a video preview',
  'FAQs': '{category} with clear details',
  'Capacity': 'Hall for 300–400 guests',
  'Parking Information': 'Venue with parking for a big wedding',
  'Outdoor Area': 'Outdoor wedding venue',
  'Generator': 'Venue with backup power',
  'Accessibility Features': 'Wheelchair-accessible {category}',
};

/// The single most valuable missing checklist item, phrased as the kind of
/// customer search it's currently blocking the business from appearing in.
AiInsight? computeAiInsight(Business business, QualityScoreResult quality) {
  if (quality.missing.isEmpty) return null;

  final missingByValue = [...quality.missing]..sort((a, b) => b.points.compareTo(a.points));
  final top = missingByValue.first;

  var phrase = _defaultSearchPhrases[top.label] ?? '{category} near me';
  if (business.category == 'Salon' && top.label == 'Packages') phrase = 'Bridal makeup under \$200';
  phrase = phrase.replaceAll('{category}', business.category.isEmpty ? 'vendors' : business.category);

  final random = Random(business.id.hashCode ^ top.label.hashCode);
  return AiInsight(
    searchPhrase: phrase,
    missingLabel: top.label,
    searchCount: 20 + random.nextInt(60),
    action: top.action,
  );
}
