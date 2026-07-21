import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/event_api_service.dart';

final eventApiServiceProvider = Provider<EventApiService>((ref) {
  return EventApiService();
});

class ActiveEvent {
  const ActiveEvent({
    required this.eventType,
    required this.eventName,
    required this.eventDate,
    required this.location,
    this.completedTasks = 0,
    this.totalTasks = 0,
  });

  final String eventType;
  final String eventName;
  final DateTime eventDate;
  final String location;
  final int completedTasks;
  final int totalTasks;
}

final activeEventProvider = StateProvider<ActiveEvent?>((ref) => null);
