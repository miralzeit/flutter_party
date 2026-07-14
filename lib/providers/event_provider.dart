import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/event_api_service.dart';

final eventApiServiceProvider = Provider<EventApiService>((ref) {
  return EventApiService();
});
