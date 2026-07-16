import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'vendor_api_service.dart';

const String defaultWishlistItemEndpoint = String.fromEnvironment(
  'WISHLIST_ITEM_ENDPOINT',
  defaultValue: '/api/wishlist/items',
);

const String defaultWishlistSaveEndpoint = String.fromEnvironment(
  'WISHLIST_SAVE_ENDPOINT',
  defaultValue: '/api/wishlists',
);

class WishlistItem {
  const WishlistItem({
    required this.url,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.sourceDomain,
    this.selected = true,
  });

  final String url;
  final String title;
  final String imageUrl;
  final String price;
  final String sourceDomain;
  final bool selected;

  factory WishlistItem.fromJson(Map<String, dynamic> json, String fallbackUrl) {
    final url = _stringValue(json, ['url', 'link'], fallback: fallbackUrl);
    return WishlistItem(
      url: url,
      title: _stringValue(json, ['title', 'name'], fallback: 'Wishlist item'),
      imageUrl: _stringValue(json, ['image', 'imageUrl', 'thumbnail']),
      price: _stringValue(json, ['price', 'displayPrice', 'amount']),
      sourceDomain: _stringValue(json, [
        'sourceDomain',
        'domain',
        'source',
      ], fallback: _domainFromUrl(url)),
      selected: json['selected'] is bool ? json['selected'] as bool : true,
    );
  }

  factory WishlistItem.demoFromUrl(String url) {
    final domain = _domainFromUrl(url);
    return WishlistItem(
      url: url,
      title: _titleFromDomain(domain),
      imageUrl: '',
      price: 'Price pending',
      sourceDomain: domain,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'sourceDomain': sourceDomain,
      'selected': selected,
    };
  }
}

class SaveWishlistRequest {
  const SaveWishlistRequest({
    required this.name,
    required this.isPrivate,
    required this.items,
  });

  final String name;
  final bool isPrivate;
  final List<WishlistItem> items;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isPrivate': isPrivate,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class WishlistApiException implements Exception {
  const WishlistApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WishlistApiService {
  WishlistApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.itemEndpoint = defaultWishlistItemEndpoint,
    this.saveEndpoint = defaultWishlistSaveEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String itemEndpoint;
  final String saveEndpoint;
  final http.Client _httpClient;

  Future<WishlistItem> addItemByUrl(String url) async {
    final response = await _postJson(_buildUri(itemEndpoint), {'url': url});
    final decoded = _decodeObject(response.body);
    final itemJson = decoded['item'] is Map
        ? Map<String, dynamic>.from(decoded['item'] as Map)
        : decoded;
    return WishlistItem.fromJson(itemJson, url);
  }

  Future<void> saveWishlist(SaveWishlistRequest wishlist) async {
    await _postJson(_buildUri(saveEndpoint), wishlist.toJson());
  }

  Future<http.Response> _postJson(Uri uri, Map<String, dynamic> body) async {
    try {
      final response = await _httpClient
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WishlistApiException(
          'Wishlist request failed with status ${response.statusCode}.',
        );
      }
      return response;
    } on TimeoutException {
      throw const WishlistApiException('Wishlist request timed out.');
    } on FormatException {
      throw const WishlistApiException('Wishlist response was not valid JSON.');
    } on http.ClientException {
      throw const WishlistApiException(
        'Could not connect to the wishlist backend.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const FormatException('Expected JSON object');
  }

  Uri _buildUri(String endpoint) {
    final base = Uri.parse(baseUrl);
    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final path = '${_trimTrailingSlash(base.path)}$normalizedEndpoint';
    return base.replace(path: path, queryParameters: base.queryParameters);
  }
}

String _trimTrailingSlash(String value) {
  if (value.endsWith('/')) return value.substring(0, value.length - 1);
  return value;
}

String _stringValue(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String _domainFromUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  final host = uri?.host ?? '';
  if (host.isEmpty) return 'Unknown source';
  return host.startsWith('www.') ? host.substring(4) : host;
}

String _titleFromDomain(String domain) {
  if (domain == 'Unknown source') return 'Wishlist item';
  final label = domain.split('.').first;
  return '${label[0].toUpperCase()}${label.substring(1)} find';
}
