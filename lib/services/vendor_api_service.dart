import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/marketplace_vendor.dart';

const String defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

const String defaultVendorsEndpoint = String.fromEnvironment(
  'VENDORS_ENDPOINT',
  defaultValue: '/get vendors',
);

class VendorApiException implements Exception {
  const VendorApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VendorApiService {
  VendorApiService({
    this.baseUrl = defaultApiBaseUrl,
    this.vendorsEndpoint = defaultVendorsEndpoint,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String vendorsEndpoint;
  final http.Client _httpClient;

  Future<PaginatedVendors> getVendors({
    required int page,
    int limit = 10,
    String? location,
  }) async {
    final uri = _buildUri(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (location != null && location.trim().isNotEmpty)
          'location': location.trim(),
      },
    );

    try {
      final response = await _httpClient
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw VendorApiException(
          'Vendor request failed with status ${response.statusCode}.',
        );
      }

      final decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      final pageResult = PaginatedVendors.fromJson(decoded);
      return pageResult.copyWithVendors(
        pageResult.vendors.map(_withAbsoluteImageUrl).toList(),
      );
    } on TimeoutException {
      throw const VendorApiException('Vendor request timed out.');
    } on FormatException {
      throw const VendorApiException('Vendor response was not valid JSON.');
    } on http.ClientException {
      throw const VendorApiException(
        'Could not connect to the vendor backend.',
      );
    }
  }

  Uri _buildUri({required Map<String, String> queryParameters}) {
    final base = Uri.parse(baseUrl);
    final endpoint = vendorsEndpoint.startsWith('/')
        ? vendorsEndpoint
        : '/$vendorsEndpoint';
    final path = '${_trimTrailingSlash(base.path)}$endpoint';

    return base.replace(
      path: path,
      queryParameters: {...base.queryParameters, ...queryParameters},
    );
  }

  MarketplaceVendor _withAbsoluteImageUrl(MarketplaceVendor vendor) {
    if (vendor.imageUrl.isEmpty) return vendor;

    final imageUri = Uri.tryParse(vendor.imageUrl);
    if (imageUri == null || imageUri.hasScheme) return vendor;

    return vendor.copyWith(
      imageUrl: Uri.parse(baseUrl).resolve(vendor.imageUrl).toString(),
    );
  }
}

String _trimTrailingSlash(String value) {
  if (value.endsWith('/')) return value.substring(0, value.length - 1);
  return value;
}
