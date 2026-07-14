class MarketplaceVendor {
  const MarketplaceVendor({
    required this.id,
    required this.name,
    required this.description,
    required this.priceLevel,
    required this.rating,
    required this.imageUrl,
    required this.phone,
    required this.whatsapp,
  });

  final String id;
  final String name;
  final String description;
  final String priceLevel;
  final double? rating;
  final String imageUrl;
  final String phone;
  final String whatsapp;

  factory MarketplaceVendor.fromJson(Map<String, dynamic> json) {
    return MarketplaceVendor(
      id: _stringValue(json, ['id', '_id', 'vendorId']),
      name: _stringValue(json, ['name', 'businessName', 'vendorName', 'title']),
      description: _stringValue(json, ['description', 'bio', 'summary']),
      priceLevel: _stringValue(json, ['priceLevel', 'price', 'priceRange']),
      rating: _doubleValue(json, ['rating', 'averageRating', 'stars']),
      imageUrl: _stringValue(json, [
        'imageUrl',
        'photoUrl',
        'coverImage',
        'coverPhoto',
        'image',
        'photo',
      ]),
      phone: _stringValue(json, ['phone', 'phoneNumber', 'mobile']),
      whatsapp: _stringValue(json, ['whatsapp', 'whatsApp', 'whatsappNumber']),
    );
  }

  MarketplaceVendor copyWith({
    String? id,
    String? name,
    String? description,
    String? priceLevel,
    double? rating,
    String? imageUrl,
    String? phone,
    String? whatsapp,
  }) {
    return MarketplaceVendor(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceLevel: priceLevel ?? this.priceLevel,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
    );
  }
}

class PaginatedVendors {
  const PaginatedVendors({
    required this.vendors,
    required this.page,
    required this.limit,
    required this.hasNextPage,
  });

  final List<MarketplaceVendor> vendors;
  final int page;
  final int limit;
  final bool hasNextPage;

  factory PaginatedVendors.fromJson(Object? json) {
    if (json is List) {
      return PaginatedVendors(
        vendors: _vendorList(json),
        page: 1,
        limit: json.length,
        hasNextPage: false,
      );
    }

    if (json is! Map<String, dynamic>) {
      return const PaginatedVendors(
        vendors: [],
        page: 1,
        limit: 0,
        hasNextPage: false,
      );
    }

    final payload = _mapValue(json, ['data', 'result', 'payload']);
    final source = payload.isEmpty ? json : payload;
    final pagination = _mapValue(source, ['pagination', 'meta', 'pageInfo']);
    final items = _listValue(source, ['vendors', 'data', 'items', 'results']);
    final page =
        _intValue(pagination, ['page', 'currentPage']) ??
        _intValue(source, ['page', 'currentPage']) ??
        1;
    final limit =
        _intValue(pagination, ['limit', 'pageSize', 'perPage']) ??
        _intValue(source, ['limit', 'pageSize', 'perPage']) ??
        items.length;
    final totalPages =
        _intValue(pagination, ['totalPages', 'pages']) ??
        _intValue(source, ['totalPages', 'pages']);
    final explicitHasNext =
        _boolValue(pagination, ['hasNextPage', 'hasNext', 'nextPage']) ??
        _boolValue(source, ['hasNextPage', 'hasNext', 'nextPage']);

    return PaginatedVendors(
      vendors: _vendorList(items),
      page: page,
      limit: limit,
      hasNextPage:
          explicitHasNext ?? (totalPages == null ? false : page < totalPages),
    );
  }

  PaginatedVendors copyWithVendors(List<MarketplaceVendor> vendors) {
    return PaginatedVendors(
      vendors: vendors,
      page: page,
      limit: limit,
      hasNextPage: hasNextPage,
    );
  }
}

List<MarketplaceVendor> _vendorList(List<Object?> items) {
  return items
      .whereType<Map>()
      .map(
        (item) => MarketplaceVendor.fromJson(Map<String, dynamic>.from(item)),
      )
      .where((vendor) => vendor.name.isNotEmpty)
      .toList();
}

String _stringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

double? _doubleValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

int? _intValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

bool? _boolValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value > 0;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
  }
  return null;
}

Map<String, dynamic> _mapValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const {};
}

List<Object?> _listValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value;
  }
  return const [];
}
