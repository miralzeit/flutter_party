import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/vendor_api_service.dart';

final vendorApiServiceProvider = Provider<VendorApiService>((ref) {
  return VendorApiService();
});
