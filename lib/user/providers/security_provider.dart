import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/security_api_service.dart';

final securityApiServiceProvider = Provider<SecurityApiService>((ref) {
  return SecurityApiService();
});
